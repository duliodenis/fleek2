//
//  FriendViewController.m
//  fleek
//
//  Created by Dulio Denis on 2/20/15.
//  Copyright (c) 2015 ddApps. See included LICENSE file.
//

#import <Parse/Parse.h>
#import "FriendViewController.h"
#import "SWRevealViewController.h"

@interface FriendViewController () <SWRevealViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (weak, nonatomic) IBOutlet UITextField *friendNameText;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *pendingFriendsLabel;
@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // The Menu Bar Button
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.menuBarButton.target = self.revealViewController;
    self.menuBarButton.action = @selector(revealToggle:);
    
    self.statusLabel.text = @"";
}

- (IBAction)makeFriend:(id)sender {
    // search user class to see if there is a nickname like the one entered
    PFQuery *query = [PFUser query];
    // PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"nickname" equalTo:self.friendNameText.text];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 1) {
                // error - 2 users with the same nickname
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.statusLabel.text = @"error - Two users with the same nickname";
                });
            } else if (objects.count == 1) {
                // we found our friend set a pending friend request
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.statusLabel.text = @"Initiate Friend Request";
                });
            } else if (objects.count == 0) {
                // No users with that nickname
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.statusLabel.text = @"No users with that nickname";
                });
            }
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", errorString);
        }
    }];
}

@end
