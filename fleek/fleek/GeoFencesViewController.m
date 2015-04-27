//
//  GeoFencesViewController.m
//  fleek
//
//  Created by Dulio Denis on 3/5/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import "GeoFencesViewController.h"
#import "MapViewController.h"
#import "FavoritesTableViewCell.h"

@interface GeoFencesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *geofences;
@property (nonatomic) BOOL didStartMonitoringRegion;
@property (nonatomic) UIImageView *backgroundImage;
@end

@implementation GeoFencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSInteger myVCIndex = [self.navigationController.viewControllers indexOfObject:self];
    MapViewController *mapVC = [self.navigationController.viewControllers objectAtIndex:myVCIndex-1];
    
    // Set background Image
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notifyBackground.jpg"]];
    self.backgroundImage.contentMode = UIViewContentModeCenter;
    self.tableView.backgroundView = self.backgroundImage;
    [self.tableView addSubview:self.backgroundImage];
    [self.tableView sendSubviewToBack:self.backgroundImage];
    
    self.geofences = [NSMutableArray arrayWithArray:[[mapVC.locationManager monitoredRegions] allObjects]];
}


#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.geofences.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoritesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    // Fetch Geofence
    CLRegion *geofence = [self.geofences objectAtIndex:[indexPath row]];
    
    // Configure Cell
    CLLocationCoordinate2D center = [geofence center];
    NSString *text = [NSString stringWithFormat:@"%.1f | %.1f", center.latitude, center.longitude];
    [cell.textLabel setText:text];
    [cell.detailTextLabel setText:[geofence identifier]];
    
    return cell;
}

@end
