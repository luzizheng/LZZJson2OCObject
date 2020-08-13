//
//  AppDelegate.m
//  LZZJson2OCObject
//
//  Created by Chemm_Luzz on 2020/8/10.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import "AppDelegate.h"
#import "SingleTonInfo.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    }else{
        NSWindowController * wc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"root_window"];
        [wc.window makeKeyAndOrderFront:self];
        return YES;
    }
}

@end
