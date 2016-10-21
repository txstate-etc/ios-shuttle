//
//  ViewController.m
//  Shuttle Maps
//
//  Created by Nick Wing on 9/12/16.
//  Copyright © 2016 Texas State University. All rights reserved.
//

#import "ViewController.h"
#import "MapClient.h"
#import "SlideOutMenu.h"
#import "SearchTableMapPage.h"
#import "SettingsViewController.h"

//For ETAs
#import "StopsScrollView.h"
#import "StopMarker.h" //to get ID
#import "BusMarker.h"

//For Buildings
#import "BuildingMarker.h"
#import "TxStateUtil.h"

@interface ViewController () <GMSMapViewDelegate>

@property (strong,nonatomic) SlideOutMenu *slideOutMenu;

@property (strong,nonatomic) StopsScrollView *stopsScrollView;

@property (strong,nonatomic) MapClient *mapClient;

@property (nonatomic) BOOL viewMade;

@property (strong,nonatomic) SearchTableMapPage *mp0;
@property (strong,nonatomic) TableMapPage *mp1;
@property (strong,nonatomic) TableMapPage *mp2;
@property (strong,nonatomic) TableMapPage *mp3;

@end

@implementation ViewController

-(void)adjustMapFrame {
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _mapView.frame = _mapSpace.frame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}

-(CGFloat)spaceBetweenTopAndSlide {
    return 100.0;
}

#pragma mark - GMSMAP Delagete

-(void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay{
    NSLog(@"OverlayTaped");
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    NSLog(@"MarkerTaped");
    if ([marker isKindOfClass:[StopMarker class]]) {
        StopMarker *stopmarker = (StopMarker*)marker;
        [self.mapClient setSelectedStop:stopmarker.markersjStop];
    }
    
    self.mapView.selectedMarker = marker;
    return YES;
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    // this is only called when a marker was not tapped, so let's hide the info boxes
    [self.mapClient setSelectedStop:nil];
}

- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    if ([marker isKindOfClass:[BuildingMarker class]]) {
        BuildingMarker* bmark = (BuildingMarker*)marker;
        if ([bmark.jbuilding.buildingUrl length] > 0) {
            // TODO: open up a new viewcontroller with a UIWebView displaying bmark.jbuilding.buildingUrl
        }
    }
}
-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    return nil;
}

- (BOOL) didTapMyLocationButtonForMapView:(GMSMapView *)mapView {
    // didTapMyLocationButtonForMapView does not get called in the current version
    // maybe someday this will work
    return NO;
}

#pragma-mark Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *mapSettingsButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsPressed)];
    mapSettingsButton.tintColor = [TxStateUtil gold];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [TxStateUtil darkred];
    self.navigationItem.rightBarButtonItem = mapSettingsButton;
}

- (void)settingsPressed {
    SettingsViewController* settings = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settings.delegate = self;
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:settings];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (!self.viewMade) {
        
        self.mapClient = [[MapClient alloc]init];
        
        self.mapSpace = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 55)];
        //self.mapSpace.accessibilityActivationPoint;
        self.mapSpace.accessibilityLabel = @"Texas State MapView. Select button below to add pins to the map.";
        
        self.mapSpace.clipsToBounds = YES;
        [self.view addSubview:_mapSpace];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:29.889471054077 longitude:-97.944892883301 zoom:12];
        self.mapView = [GMSMapView mapWithFrame:_mapSpace.frame camera:camera];
        self.mapView.myLocationEnabled = YES;
        self.mapView.settings.compassButton = YES;
        self.mapView.settings.myLocationButton = YES;
        self.mapView.delegate = self;
        self.accessibilityElementsHidden = !UIAccessibilityIsVoiceOverRunning();
        [self updateMapSettings];
        [self.mapSpace addSubview:self.mapView];
        
        self.slideOutMenu = [[SlideOutMenu alloc]init];
        [self.slideOutMenu createWithDimensions:self.view.bounds spaceBetweenTopAndSlide:[self spaceBetweenTopAndSlide] hightOfMenuWhenClosed:55];
        self.slideOutMenu.mapController = self;
        //Load Pointers
        self.stopsScrollView = [[StopsScrollView alloc] init];
        [self.stopsScrollView drawSelfOnToView:self.view];
        self.mapClient.stopsScrollView = self.stopsScrollView;
        
        self.mp0 = [[SearchTableMapPage alloc]init];
        self.mp1 = [[TableMapPage alloc]init];
        self.mp2 = [[TableMapPage alloc]init];
        self.mp3 = [[TableMapPage alloc]init];
        self.mp0.pageNumber = 0;
        self.mp1.pageNumber = 1;
        self.mp2.pageNumber = 2;
        self.mp3.pageNumber = 3;
        [self.mp0 setDataClient:self.mapClient];
        [self.mp1 setDataClient:self.mapClient];
        [self.mp2 setDataClient:self.mapClient];
        [self.mp3 setDataClient:self.mapClient];
        self.mp3.mapView = self.mapView;
        self.mp2.mapView = self.mapView;
        self.mp1.mapView = self.mapView;
        self.mp0.mapView = self.mapView;
        [self.slideOutMenu addPage:self.mp0 with:@"Buildings" withIcon:[UIImage imageNamed:@"buildings_active"] andUnactiveIcon:[UIImage imageNamed:@"buildings"]];
        [self.slideOutMenu addPage:self.mp1 with:@"Routes" withIcon:[UIImage imageNamed:@"routes_active"] andUnactiveIcon:[UIImage imageNamed:@"routes"]];
        [self.slideOutMenu addPage:self.mp2 with:@"Stops" withIcon:[UIImage imageNamed:@"stops_active"] andUnactiveIcon:[UIImage imageNamed:@"stops"]];
        [self.slideOutMenu addPage:self.mp3 with:@"More" withIcon:[UIImage imageNamed:@"more"] andUnactiveIcon:[UIImage imageNamed:@"more"]];
        
        [self.slideOutMenu updateButtonBar];
        [self.slideOutMenu drawFramesWithDimensions:self.view.bounds spaceBetweenTopAndSlide:[self spaceBetweenTopAndSlide] hightOfMenuWhenClosed:55];
        
        
        //self.slideOutMenu.slideOutMenuDelegate = self;
        [self.view addSubview:self.slideOutMenu];
        
        
        self.mapClient.mapView = self.mapView;
        [self.mapClient kickOff];
        
        self.viewMade = YES;
    } else
        [_mapClient cleanUpClient];
    
    [self reDrawPage];
    
    [self activateAccessibility];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateAccessibility) name:UIAccessibilityVoiceOverStatusChanged object:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [_mapClient cleanUpClient];
}

-(void) activateAccessibility {
    _mapView.accessibilityElementsHidden = !UIAccessibilityIsVoiceOverRunning();
}

-(void)reDrawPage{
    [self.slideOutMenu drawFramesWithDimensions:self.view.bounds spaceBetweenTopAndSlide:[self spaceBetweenTopAndSlide] hightOfMenuWhenClosed:55];
    [self.slideOutMenu updateButtonBar];
    self.mapSpace.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 55);
    [self adjustMapFrame];
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView animateWithDuration:0.1
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self reDrawPage];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}


-(void)updateMapSettings {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isSat = [standardUserDefaults boolForKey:@"sat"];
    NSLog(@"sss");
    if (isSat) {
        _mapView.mapType = kGMSTypeHybrid;
    } else {
        _mapView.mapType = kGMSTypeNormal;
    }
}

@end
