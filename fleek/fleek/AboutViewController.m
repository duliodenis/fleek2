//
//  AboutViewController.m
//  fleek
//
//  Created by Dulio Denis on 2/20/15.
//  Copyright (c) 2015 ddApps. See included LICENSE file.
//

#import "AboutViewController.h"
#import "SWRevealViewController.h"

@interface AboutViewController () <SWRevealViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (weak, nonatomic) IBOutlet UILabel *buildLabel;
@property (nonatomic) UIImageView *backgroundImage;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // the background image
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aboutBackground.jpg"]];
    self.backgroundImage.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.backgroundImage];
    [self.view sendSubviewToBack:self.backgroundImage];
    
    // The Menu Bar Button
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.menuBarButton.target = self.revealViewController;
    self.menuBarButton.action = @selector(revealToggle:);
    
    // set the build number from the Info.plist string key_name "ddAppBuild"
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ddAppBuild"];
    self.buildLabel.text = buildNumber;
}

@end
