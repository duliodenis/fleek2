//
//  LocationController.m
//  fleek
//
//  Created by Dulio Denis on 5/3/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import "LocationController.h"
#import <MapKit/MapKit.h>

@interface LocationController()
@property (nonatomic) NSMutableArray *observers;
@end

@implementation LocationController

+ (LocationController *)sharedInstance {
    static LocationController *sharedLocationControllerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedLocationControllerInstance = [[self alloc] init];
    });
    return sharedLocationControllerInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        // New in iOS 8
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
            
            CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
            if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                self.locationManager.distanceFilter = 1000; // 1000 meters ~ 1/2 mile
                [self.locationManager startUpdatingLocation];
            }
        }

        self.observers = [NSMutableArray array];
    }
    
    return self;
}

- (void)addLocationCoordinatorDelegate:(id<LocationControllerDelegate>)delegate {
    if (![self.observers containsObject:delegate]) {
        [self.observers addObject:delegate];
    }
    
    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    for (id<LocationControllerDelegate> observer in self.observers) {
        if (observer) {
            [observer locationDidUpdateLocation:[locations lastObject]];
        }
    }
}


#pragma mark - Location Monitoring Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];  // in 10 seconds
    localNotification.alertBody = [NSString stringWithFormat:@"You are near the %@", region.identifier];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
