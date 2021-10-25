//
//  AppDelegate.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgrounTask;
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //创建一个背景任务去和系统请求后台运行的时间
    self.backgrounTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgrounTask];
        self.backgrounTask = UIBackgroundTaskInvalid;
    }];
    
    if (!self.timer.valid) {
        [self addTimerForBackgroundJob];
    }
}
- (void)addTimerForBackgroundJob {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(doBackgroundJob) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)doBackgroundJob {
    
    if ([UIApplication sharedApplication].backgroundTimeRemaining < 30.0) {//如果剩余时间小于30秒
//        [[UIApplication sharedApplication] endBackgroundTask:self.backgrounTask];
//        self.backgrounTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//            [[UIApplication sharedApplication] endBackgroundTask:self.backgrounTask];
//            self.backgrounTask = UIBackgroundTaskInvalid;
//        }];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self.timer invalidate];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppWillKill" object:nil];
    [self.timer invalidate];
}


@end
