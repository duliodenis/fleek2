//
//  LocationData.h
//  fleek
//
//  Created by Dulio Denis on 1/30/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationData : NSObject
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) MKCoordinateRegion region;
@end
