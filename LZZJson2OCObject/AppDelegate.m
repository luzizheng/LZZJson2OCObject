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
@property (weak) IBOutlet NSMenuItem *YYModel;
@property (weak) IBOutlet NSMenuItem *MJModel;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    
    [self.YYModel setAction:@selector(changeModelType:)];
    [self.MJModel setAction:@selector(changeModelType:)];
    
    [[SingleTonInfo sharedInstance] addObserver:self forKeyPath:kSel(modelType) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:[SingleTonInfo sharedInstance]] && [kStringF(keyPath) isEqualToString:kSel(modelType)]) {
        ModelType type = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
        self.YYModel.state = type == ModelType_YY?NSControlStateValueOn:NSControlStateValueOff;
        self.MJModel.state = type == ModelType_MJ?NSControlStateValueOn:NSControlStateValueOff;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


-(void)changeModelType:(NSMenuItem *)sender
{
    if ([sender isEqual:self.YYModel]) {
        if ([SingleTonInfo sharedInstance].modelType == ModelType_MJ) {
            [SingleTonInfo sharedInstance].modelType = ModelType_YY;
        }
    }else if ([sender isEqual:self.MJModel]){
        if ([SingleTonInfo sharedInstance].modelType == ModelType_YY) {
            [SingleTonInfo sharedInstance].modelType = ModelType_MJ;
        }
    }
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
