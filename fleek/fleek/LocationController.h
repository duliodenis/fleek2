//
//  LocationController.h
//  fleek
//
//  Created by Dulio Denis on 5/3/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationControllerDelegate
- (void)locationDidUpdateLocation:(CLLocation *)location;
@end

@interface LocationController : NSObject <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *location;
@property (nonatomic) id delegate;

/**
 Singleton Instance
 */
+ (LocationController *)sharedInstance;
- (void)addLocationCoordinatorDelegate:(id<LocationControllerDelegate>)delegate;

@end
