//
//  LocationController.m
//  fleek
//
//  Created by Dulio Denis on 5/3/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import "LocationController.h"
#import <MapKit/MapKit.h>

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
                
                [self.locationManager startUpdatingLocation];
            }
            
            self.locationManager.distanceFilter = 1000; // 1000 meters ~ 1/2 mile
            [self.locationManager startUpdatingLocation];
        }
    }
    
    return self;
}

@end
