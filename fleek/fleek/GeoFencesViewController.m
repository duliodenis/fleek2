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

@interface GeoFencesViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>
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
    
    // Set the delegate and datasource
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
    FavoritesTableViewCell *cell = (FavoritesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    // Configure Cell
    CLRegion *region = [self.geofences objectAtIndex:[indexPath row]];
    [cell.title setText:region.identifier];
    
    // Add Utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Remove"];
    
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    return cell;
}

#pragma mark - SWTableViewCell Delegate Methods

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // Remove button is pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];

            CLRegion *region = [self.geofences objectAtIndex:index];
            NSInteger myVCIndex = [self.navigationController.viewControllers indexOfObject:self];
            MapViewController *mapVC = [self.navigationController.viewControllers objectAtIndex:myVCIndex-1];

            // Stop Monitoring Region
            [mapVC.locationManager stopMonitoringForRegion:region];
            
            // Update Table View
            [self.geofences removeObject:region];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

@end
