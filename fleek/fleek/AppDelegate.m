//
//  AppDelegate.m
//  fleek
//
//  Created by Dulio Denis on 1/27/15.
//  Copyright (c) 2015 ddApps. See included LICENSE file.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Parse Anonymous Usage
    [Fabric with:@[CrashlyticsKit]];
    [Parse setApplicationId:@"eSzBJHobsgvoUPKNg4iEbuZ2ce1RPFVmJdDPox1V" clientKey:@"BIicNk1hC9UNyfSjCaN51ahqSxk9LeeKF8w7EyhN"];
    [PFUser enableAutomaticUser];
    
    // Analytics Tracking App Opening
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    return YES;
}

@end
