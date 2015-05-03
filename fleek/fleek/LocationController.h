//
//  LocationController.h
//  fleek
//
//  Created by Dulio Denis on 5/3/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationController : NSObject <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *location;
@property (nonatomic) id delegate;

/**
 Singleton Instance
 */
+ (LocationController *)sharedInstance;

@end
