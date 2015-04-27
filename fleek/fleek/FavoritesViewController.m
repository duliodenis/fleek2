//
//  FavoritesViewController.m
//  fleek
//
//  Created by Dulio Denis on 2/28/15.
//  Copyright (c) 2015 ddApps. See included LICENSE file.
//

#import <Parse/Parse.h>
#import "FavoritesViewController.h"
#import "FavoritesTableViewCell.h"

@interface FavoritesViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *favorites;
@property (nonatomic) UIImageView *backgroundImage;
@end

@implementation FavoritesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favoritesBackground.jpg"]];
    self.backgroundImage.contentMode = UIViewContentModeCenter;
    self.tableView.backgroundView = self.backgroundImage;
    [self.tableView addSubview:self.backgroundImage];
    [self.tableView sendSubviewToBack:self.backgroundImage];
    //self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    
    [self loadFavorites];
}


#pragma mark - Parse POI Update Methods
//TODO: Refactor into a Parse Utility Class - MapVC uses this too

- (void)loadFavorites {
    PFQuery *query = [PFQuery queryWithClassName:@"POI"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"user" equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // put into mutable array - each element is an NSDictionary with name & subtitle
            NSMutableArray *favoritesFromParse = [NSMutableArray new];
            for (PFObject *favorite in objects) {
                NSMutableDictionary *favoriteElement = [[NSMutableDictionary alloc] init];
                [favoriteElement setObject:[favorite objectForKey:@"name"] forKey:@"name"];
                [favoriteElement setObject:[favorite objectForKey:@"subtitle"] forKey:@"subtitle"];
                [favoriteElement setObject:favorite.objectId forKey:@"objectID"];
                [favoritesFromParse addObject:favoriteElement];
            }
            self.favorites = favoritesFromParse;
            NSLog(@"count of favorites = %lu", (unsigned long)self.favorites.count);
            [self.tableView reloadData];
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", errorString);
        }
    }];
}


- (void)removeFavoriteFromParse:(NSString *)deleteID {
    PFQuery *query = [PFQuery queryWithClassName:@"POI"];
    PFObject *place = [query getObjectWithId:deleteID];
    [place delete];
}


- (void)addNotification:(NSString *)objectID {
    PFQuery *query = [PFQuery queryWithClassName:@"POI"];
    PFObject *place = [query getObjectWithId:objectID];
    NSNumber *monitorBool = [NSNumber numberWithBool:YES];
    [place setObject:monitorBool forKey:@"monitor"];
    
    [place saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Save to Parse Successful.");
        } else {
            NSLog(@"Save to Parse Failure.");
        }
    }];
}


#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Cell";
    
    FavoritesTableViewCell *cell = (FavoritesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FavoritesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Add utility buttons
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.139 green:1.000 blue:0.190 alpha:0.700]
                                                icon:[UIImage imageNamed:@"dish"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Remove"];
    
    cell.leftUtilityButtons = leftUtilityButtons;
    cell.rightUtilityButtons = rightUtilityButtons;
    
    cell.title.text = [NSString stringWithFormat:@"%@", [self.favorites[indexPath.row] valueForKey:@"name"]];
    cell.subtitle.text = [self.favorites[indexPath.row] valueForKey:@"subtitle"];
    
    cell.delegate = self;
    return cell;
}


#pragma mark - SWTableViewCell Delegate Methods

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            UIAlertController *favoriteActionSheet = [UIAlertController alertControllerWithTitle:@"Place Notifications"
                                                                           message:@"You can be notified when you are near your favorite places."
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *notifyAction = [UIAlertAction actionWithTitle:@"Yes, Notify Me When Near"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                                                                      NSString *objectID = [self.favorites[cellIndexPath.row] valueForKey:@"objectID"];
                                                                      [self addNotification:objectID];
                                                                  }];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"No, not right now"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {}];
            
            [favoriteActionSheet addAction:notifyAction];
            [favoriteActionSheet addAction:defaultAction];
            [self presentViewController:favoriteActionSheet animated:YES completion:nil];
            
            /* Deprecated UIActionSheet in iOS 8
            UIActionSheet *favoriteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Place Notifications"
                                                                             delegate:self
                                                                    cancelButtonTitle:@"Cancel"
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Notify Me When Near", nil];
            [favoriteActionSheet showInView:self.view];
            [cell hideUtilityButtonsAnimated:YES];
             */
            break;
        }
        default:
            break;
    }
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // Remove button is pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            NSMutableArray *tempItems = [NSMutableArray arrayWithArray:self.favorites];
            [tempItems removeObjectAtIndex:cellIndexPath.row];
            [self removeFavoriteFromParse:[self.favorites[cellIndexPath.row] valueForKey:@"objectID"]];
            self.favorites = tempItems;
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}


@end
