//
//  MapSettingsViewController.m
//  TxState
//
//  Created by Jake on 7/18/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "SettingsViewController.h"
#import "TxStateUtil.h"

@interface SettingsViewController ()

@property (strong,nonatomic) UITableViewCell *satCell;
@property (strong,nonatomic) UITableViewCell *metricCell;

@end

@implementation SettingsViewController

#pragma-mark Button Actions
- (IBAction)metricSwitchChanged:(UISwitch *)sender {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:sender.isOn forKey:@"metric"];
}

- (IBAction)satelliteSwitchChanged:(UISwitch *)sender {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:sender.isOn forKey:@"sat"];
}

#pragma-mark LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Map Settings";
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(hideMenu)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [TxStateUtil darkred];
    self.navigationController.navigationBar.tintColor = [TxStateUtil gold];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[TxStateUtil gold]};    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)hideMenu {
    [self.delegate updateMapSettings];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self satCellWithTable:tableView];
    } else if (indexPath.row ==1) {
        return [self metricCellWithTable:tableView];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UISwitch* sw;
    if (indexPath.row == 0) {
        sw = (UISwitch*)_satCell.accessoryView;
    } else if (indexPath.row ==1) {
        sw = (UISwitch*)_metricCell.accessoryView;
    }
    [sw setOn:![sw isOn] animated:YES];
    [self satelliteSwitchChanged:sw];
}

#pragma-mark CellViews

-(UITableViewCell*)switchCellWithTitle:(NSString*)title isOn:(BOOL)isOn selector:(SEL)switchpressed {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:title];
    cell.textLabel.text = title;
    
    UISwitch* sv = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = sv;
    [sv setOn:isOn animated:NO];
    [sv addTarget:self action:switchpressed forControlEvents:UIControlEventValueChanged];
    return cell;
}

-(UITableViewCell *)satCellWithTable:(UITableView *)tableView {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isSat = [standardUserDefaults boolForKey:@"sat"];
    
    if (!_satCell  ) _satCell = [self switchCellWithTitle:@"Satellite View" isOn:isSat selector:@selector(satelliteSwitchChanged:)];
    return _satCell;
}

-(UITableViewCell *)metricCellWithTable:(UITableView *)tableView {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isMetric = [standardUserDefaults boolForKey:@"metric"];
    
    if (!_metricCell) _metricCell = [self switchCellWithTitle:@"Use Metric Units" isOn:isMetric selector:@selector(metricSwitchChanged:)];
    return _metricCell;
}

@end
