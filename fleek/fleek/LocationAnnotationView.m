//
//  LocationAnnotationView.m
//  fleek
//
//  Created by Dulio Denis on 2/3/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import "LocationAnnotationView.h"


@implementation LocationAnnotationView

+ (id)annotationWithCoordinate:(CLLocationCoordinate2D)coord {
    return [[[self class] alloc] initWithCoordinate:coord];
}


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ( self = [super init] ) {
        self.coordinate = coordinate;
    }
    return self;
}


- (id)initWithPlacemark:(MKPlacemark *)placemark {
    if ( self = [super init] ) {
        self.coordinate = placemark.coordinate;;
        self.title = placemark.name;
        self.subtitle = placemark.title;
    }
    return self;
}

@end
