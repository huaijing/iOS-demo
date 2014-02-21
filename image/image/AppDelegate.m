//
//  AppDelegate.m
//  image
//
//  Created by  on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController;
@synthesize viewController;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
   
    self.window.backgroundColor = [UIColor whiteColor];
    self.viewController =  [[ViewController alloc]init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController]; 
    [self.window addSubview:navController.view];
    
    [self.window makeKeyAndVisible];
    return YES;
}


@end