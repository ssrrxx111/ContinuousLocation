//
//  AppDelegate.m
//  locationdemo
//
//  Created by 123不准动 on 16/6/17.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import "AppDelegate.h"
#import "LOCLocationDemoVC.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    LOCLocationDemoVC *demovc = [[LOCLocationDemoVC alloc] init];
    self.window.rootViewController = demovc;
//    self.window.backgroundColor = [UIColor grayColor];
    
   
    [self.window makeKeyAndVisible];
    return YES;
}




@end
