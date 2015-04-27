//
//  NicknameViewController.m
//  fleek
//
//  Created by Dulio Denis on 2/18/15.
//  Copyright (c) 2015 ddApps. See included LICENSE file.
//

#import <Parse/Parse.h>
#import "NicknameViewController.h"
#import "SWRevealViewController.h"

@interface NicknameViewController () <SWRevealViewControllerDelegate>
@property (nonatomic) NSString* nickname;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (weak, nonatomic) IBOutlet UILabel *updateStatusLabel;
@property (nonatomic) UIImageView *backgroundImage;
@end

@implementation NicknameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBackground.jpg"] highlightedImage:nil];
    self.backgroundImage.contentMode = UIViewContentModeCenter;
    
    // Move the background to the left in order to center photo in view
    CGRect frame = self.view.frame;
    frame.origin.x = -25; // Moove it to the left to clip and center a bit
    frame.origin.y = 30; // Move it down - we have a NavBar
    self.backgroundImage.frame = frame;

    [self.view addSubview:self.backgroundImage];
    [self.view sendSubviewToBack:self.backgroundImage];
    
    self.updateStatusLabel.text = @"";
    
    // The Menu Bar Button
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.menuBarButton.target = self.revealViewController;
    self.menuBarButton.action = @selector(revealToggle:);
    
    // PFQuery *query = [PFQuery queryWithClassName:@"User"];
    PFQuery *query = [PFUser query];
    PFUser *user = [PFUser currentUser];
    
    // Anonymous users have null objectID throwing uncaught exception when comparing
    if (user.objectId) [query whereKey:@"objectId" equalTo:user.objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count) {
                PFObject *user = [objects firstObject];
                self.nickname = [user objectForKey:@"nickname"];
                NSLog(@"User has the nickname: %@", self.nickname);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.nicknameTextField.text = self.nickname;
                });
                
            }
            else NSLog(@"User has no nickname");
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", errorString);
        }
    }];
    
}

- (IBAction)updateNickname:(id)sender {
    PFUser *user = [PFUser currentUser];
    self.nickname = self.nicknameTextField.text;
    [user setObject:self.nickname forKey:@"nickname"];
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Updated nickname on Parse Successful.");
            self.updateStatusLabel.text = @"Update successful.";
        } else {
            NSLog(@"Update nickname to Parse Failure.");
            self.updateStatusLabel.text = @"Update failure.";
        }
    }];
    
}

@end
