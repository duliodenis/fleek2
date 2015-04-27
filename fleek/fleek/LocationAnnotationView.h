//
//  LocationAnnotationView.h
//  fleek
//
//  Created by Dulio Denis on 2/3/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LocationAnnotationView : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

+ (id)annotationWithCoordinate:(CLLocationCoordinate2D)coord;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithPlacemark:(MKPlacemark *)placemark;

@end
