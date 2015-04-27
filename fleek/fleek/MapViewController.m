//
//  MapViewController.m
//  fleek
//
//  Created by Dulio Denis on 2/10/15.
//  Copyright (c) 2015 ddApps. See included LICENSE file.
//

#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "MapViewController.h"
#import "LocationData.h"
#import "SearchResultsViewController.h"
#import "FavoritesViewController.h"
#import "GeoFencesViewController.h"
#import "LocationAnnotationView.h"
#import "SWRevealViewController.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, SWRevealViewControllerDelegate>
@property (nonatomic) LocationAnnotationView *currentAnnotation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (nonatomic) NSMutableArray *geofences;
@property (nonatomic) BOOL didStartMonitoringRegion;
@end

NSInteger const kFavoritePlace = 0;
NSInteger const kNotifyPlace = 1;

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentAnnotation = nil;
    self.mapView.delegate = self;
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    // The Navigation right bar button items: Favorites List, Search
    UIButton *searchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"find"] forState:UIControlStateNormal];
    [searchButton setFrame:CGRectMake(0, 0, 22, 22)];
    UIBarButtonItem *searchBarButton= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    UIButton *favoritesButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [favoritesButton setBackgroundImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    [favoritesButton setFrame:CGRectMake(0, 0, 22, 22)];
    UIBarButtonItem *favoritesBarButton= [[UIBarButtonItem alloc] initWithCustomView:favoritesButton];
    
    UIButton *geoFencesButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [geoFencesButton setBackgroundImage:[UIImage imageNamed:@"dish"] forState:UIControlStateNormal];
    [geoFencesButton setFrame:CGRectMake(0, 0, 22, 22)];
    UIBarButtonItem *geoFencesBarButton= [[UIBarButtonItem alloc] initWithCustomView:geoFencesButton];
    
    [searchButton addTarget:self
                 action:@selector(searchMap)
       forControlEvents:UIControlEventTouchUpInside];
    [favoritesButton addTarget:self
                     action:@selector(listFavorites)
           forControlEvents:UIControlEventTouchUpInside];
    [geoFencesButton addTarget:self
                        action:@selector(listGeoFences)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:searchBarButton, favoritesBarButton, geoFencesBarButton, nil];
    
    // The Left Bar Button: the Menu
    self.revealViewController.delegate = self;
    self.menuBarButton.target = self.revealViewController;
    self.menuBarButton.action = @selector(revealToggle:);
    
    // LocationManager to enable reporting the user's position
    if ( [CLLocationManager locationServicesEnabled] ) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        // New in iOS 8
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
            
            CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
            if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                [self.locationManager startUpdatingLocation];
                self.mapView.showsUserLocation = YES;
            }
            
            self.locationManager.distanceFilter = 1000;
            [self.locationManager startUpdatingLocation];
            
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.75, -73.98);
            CLLocationDistance radius = 30.0;
            
            CLCircularRegion *monitoringCheck = [[CLCircularRegion alloc] initWithCenter:center
                                                                          radius:radius
                                                                      identifier:@"userRegion"];
            
            MKCoordinateSpan span = MKCoordinateSpanMake(10, 10);
            MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
            [self.mapView setRegion:region animated:YES];
            
            if ( [CLLocationManager isMonitoringAvailableForClass:[monitoringCheck class]] ) {
                // Apple's documentation says to check authorization after determining monitoring is available.
                //            CLLocationAccuracy accuracy = 1.0;
                //            [self.locationManager startMonitoringForRegion:region desiredAccuracy:accuracy];
                NSLog(@"Region monitoring available on this device.");
                // Load Geofences
                self.geofences = [NSMutableArray arrayWithArray:[[self.locationManager monitoredRegions] allObjects]];
                NSLog(@"geofences = %@", self.geofences);
            } else {
                NSLog(@"Warning: Region monitoring not supported on this device."); }
        }
    }
    
    [self loadPOIs];
}


- (void)setMapRegion:(CLLocation *)location {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
}


- (void)monitorThisRegion {
    //
    CLLocationCoordinate2D center;
    center.latitude = self.mapView.centerCoordinate.latitude;
    center.longitude = self.mapView.centerCoordinate.longitude;
    MKCircle *circleOverlay = [MKCircle circleWithCenterCoordinate:center radius:300];
    [circleOverlay setTitle:@"Circle"];
    [self.mapView addOverlay:circleOverlay];
    
    //set the region
    static NSString *myGeoFenceName = @"exampleGeofence";
    
    CLLocationDistance radius = 300.0;
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center
                                                                 radius:radius
                                                             identifier:myGeoFenceName];
    
    [[self locationManager] startMonitoringForRegion:region];
}


#pragma mark - Parse POI Save and Load Methods

- (void)loadPOIs {
    PFQuery *query = [PFQuery queryWithClassName:@"POI"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"user" equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self makePinInMap:objects];
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", errorString);
        }
    }];
}


- (void)savePOIs {
    PFUser *user = [PFUser currentUser];
    PFObject *poi = [PFObject objectWithClassName:@"POI"];
    [poi setObject:self.currentAnnotation.title forKey:@"name"];
    [poi setObject:self.currentAnnotation.subtitle forKey:@"subtitle"];
    [poi setObject:user forKey:@"user"];

    PFGeoPoint *locationCoordinate = [PFGeoPoint new];
    locationCoordinate.longitude = self.currentAnnotation.coordinate.longitude;
    locationCoordinate.latitude = self.currentAnnotation.coordinate.latitude;
    [poi setObject:locationCoordinate forKey:@"coordinate"];
    
    [poi saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Save to Parse Successful.");
        } else {
            NSLog(@"Save to Parse Failure.");
        }
    }];
}


#pragma mark - Helper Map Methods

- (void)makePinInMap:(NSArray*)pins {
    for (PFObject *pin in pins) {
        PFGeoPoint *locationCoordinate = [pin objectForKey:@"coordinate"];
        
        CLLocationDegrees latitude = locationCoordinate.latitude;
        CLLocationDegrees longitude = locationCoordinate.longitude;
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        LocationAnnotationView *annotation = [[LocationAnnotationView alloc] initWithCoordinate:coordinate];
        annotation.title = [pin objectForKey:@"name"];
        annotation.subtitle = [pin objectForKey:@"subtitle"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addAnnotation:annotation];
        });
    }
}


#pragma mark - LocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    [self setMapRegion:newLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location Manager Error: %@", [error description]);
}


#pragma mark - Right Bar Button Methods

- (void)searchMap {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.region = self.mapView.region;
    
    LocationData *locationData = [[LocationData alloc] init];
    locationData.region = self.mapView.region;
    
    SearchResultsViewController *destinationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [destinationVC setLocationData:locationData];
    [self.navigationController pushViewController:destinationVC animated:YES];
}


- (void)listFavorites {
    FavoritesViewController *destinationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
    [self.navigationController pushViewController:destinationVC animated:YES];
}


- (void)listGeoFences {
    GeoFencesViewController *destinationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GeoFencesViewController"];
    [self.navigationController pushViewController:destinationVC animated:YES];
}


#pragma mark - Annotation Methods

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //first make sure the annotation is our custom class...
    if ([view.annotation isKindOfClass:[LocationAnnotationView class]])
    {
        //cast the object to our custom class...
        LocationAnnotationView *annotation = (LocationAnnotationView *)view.annotation;
        self.currentAnnotation = annotation;
        
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude);
        MKCoordinateSpan span = MKCoordinateSpanMake(10, 10);
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        
        // either execute the favorite saving or the notification set-up
        if (control.tag == kFavoritePlace) {
            [self favoritesActionSheetForPlace:annotation.title];
        } else if (control.tag == kNotifyPlace) {
            [self notificationActionSheetForPlace:annotation.title inRegion:region];
        }
    }
}


// show an action sheet with title set to annotation's title
// to confirm saving
- (void)favoritesActionSheetForPlace:(NSString *)place {
    UIAlertController *favoriteActionSheet = [UIAlertController alertControllerWithTitle:@"Favorite Location"
                                                                                 message:[NSString stringWithFormat:@"You can save %@ as a favorite place.", place]
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Yes, save this as a favorite"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self savePOIs];
                                                       }];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"No, not right now"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              // Canceled the Parse Save Operation
                                                              self.currentAnnotation = nil;
                                                          }];
    
    [favoriteActionSheet addAction:saveAction];
    [favoriteActionSheet addAction:defaultAction];
    [self presentViewController:favoriteActionSheet animated:YES completion:nil];
}


// TO-DO: Refactor this common code - used in FavoritesVC
- (void)notificationActionSheetForPlace:(NSString *)place inRegion:(MKCoordinateRegion)region {
    UIAlertController *notificationActionSheet = [UIAlertController alertControllerWithTitle:@"Place Notifications"
                                                                                     message:[NSString stringWithFormat:@"You can be notified when you are near %@", place]
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *notifyAction = [UIAlertAction actionWithTitle:@"Yes, Notify Me When Near"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Start Monitoring Region
                                                      //       CLRegion *regionToMonitor = [CLRegion alloc] init
                                                      //       [self.locationManager startMonitoringForRegion:<#(CLRegion *)#>];
                                                             [self monitorThisRegion];
                                                         }];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"No, not right now"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              self.currentAnnotation = nil;
                                                          }];
    
    [notificationActionSheet addAction:notifyAction];
    [notificationActionSheet addAction:defaultAction];
    [self presentViewController:notificationActionSheet animated:YES completion:nil];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *myPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
    
    UIButton *notificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    notificationButton.frame = CGRectMake(0, 0, 23, 23);
    notificationButton.tag = kNotifyPlace;
    [notificationButton setBackgroundImage:[UIImage imageNamed:@"dish"] forState:UIControlStateNormal];
    
    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteButton.frame = CGRectMake(0, 0, 23, 23);
    favoriteButton.tag = kFavoritePlace;
    [favoriteButton setBackgroundImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    
    myPin.leftCalloutAccessoryView = favoriteButton;
    myPin.rightCalloutAccessoryView = notificationButton;
    myPin.draggable = NO;
    myPin.highlighted = NO;
    myPin.animatesDrop= YES;
    myPin.canShowCallout = YES;
    myPin.pinColor = MKPinAnnotationColorPurple;
    
    return myPin;
}

@end
