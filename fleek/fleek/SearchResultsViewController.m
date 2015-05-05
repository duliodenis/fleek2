//
//  SearchResultsViewController.m
//  fleek
//
//  Created by Dulio Denis on 1/29/15.
//  Copyright (c) 2015 ddApps. See included LICENSE file.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SearchResultsViewController.h"
#import "MapViewController.h"
#import "LocationData.h"
#import "LocationAnnotationView.h"
#import "SWTableViewCell.h"
#import "FavoritesTableViewCell.h"
#import "LocationController.h"


@interface SearchResultsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SWTableViewCellDelegate>
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) UIImageView *backgroundImage;
@end

@implementation SearchResultsViewController


#pragma mark - ViewLifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchResultsBackground.jpg"]];
    self.backgroundImage.contentMode = UIViewContentModeCenter;
    self.tableView.backgroundView = self.backgroundImage;
    [self.tableView addSubview:self.backgroundImage];
    [self.tableView sendSubviewToBack:self.backgroundImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"ReloadTableNotification" object:nil];
}


- (void)reloadTable {
    [self.tableView reloadData];
}


- (void)setLocationData:(LocationData *)locationData {
    _locationData = locationData;
}


#pragma mark - UITableViewDataSource Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    FavoritesTableViewCell *cell = (FavoritesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FavoritesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    MKMapItem *mapItem = self.locationData.searchResults[indexPath.row];
    cell.title.text = mapItem.name;
    cell.subtitle.text = mapItem.placemark.title;

    // Add utility button
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.139 green:1.000 blue:0.190 alpha:0.700]
                                                icon:[UIImage imageNamed:@"pinMarker"]];
    
    cell.leftUtilityButtons = leftUtilityButtons;

    cell.delegate = self;
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locationData.searchResults.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger myVCIndex = [self.navigationController.viewControllers indexOfObject:self];
    MapViewController *mapVC = [self.navigationController.viewControllers objectAtIndex:myVCIndex-1];
    
    MKMapItem *mapItem = self.locationData.searchResults[indexPath.row];
    MKPlacemark *placemark = mapItem.placemark;
    
    LocationAnnotationView *annotation = [[LocationAnnotationView alloc] initWithPlacemark:placemark];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 2000, 2000);
    [mapVC.mapView setRegion:region animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapVC.mapView addAnnotation:annotation];
    });

    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.locationData.region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        self.locationData.searchResults = (NSMutableArray *)response.mapItems;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: // Location Multi-add
        {
            NSInteger myVCIndex = [self.navigationController.viewControllers indexOfObject:self];
            MapViewController *mapVC = [self.navigationController.viewControllers objectAtIndex:myVCIndex-1];
            
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            MKMapItem *mapItem = self.locationData.searchResults[indexPath.row];
            MKPlacemark *placemark = mapItem.placemark;
            
            LocationAnnotationView *annotation = [[LocationAnnotationView alloc] initWithPlacemark:placemark];
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 2000, 2000);
            [mapVC.mapView setRegion:region animated:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [mapVC.mapView addAnnotation:annotation];
            });
        }
        default:
            break;
    }
}

@end
