//
//  MainWindowController.m
//  LZZJson2OCObject
//
//  Created by https://github.com/luzizheng/LZZJson2OCObject on 2020/9/4.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import "MainWindowController.h"


@interface MainWindowController ()<NSWindowDelegate>


@end

@implementation MainWindowController



- (void)dealloc
{
    [[SingleTonInfo sharedInstance] removeObserver:self forKeyPath:kSel(modelType)];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.delegate = self;
    
    [[SingleTonInfo sharedInstance] addObserver:self forKeyPath:kSel(modelType) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];

    NSMenu * menu = [[NSMenu alloc] init];
    NSMenuItem * yy_item = [[NSMenuItem alloc] initWithTitle:@"YY Model" action:@selector(yy_click:) keyEquivalent:@""];
    NSMenuItem * mj_item = [[NSMenuItem alloc] initWithTitle:@"MJ Model" action:@selector(mj_click:) keyEquivalent:@""];
    [menu addItem:yy_item];
    [menu addItem:mj_item];
    
    NSView * tab = [self.window standardWindowButton:NSWindowCloseButton].superview;
    for (NSView * subView in tab.subviews) {
        NSLog(@"%@",NSStringFromClass([subView class]));
        if ([subView isKindOfClass:[NSTextField class]]) {
            subView.acceptsTouchEvents = YES;
            [subView setMenu:menu];
            break;
        }
    }
}

-(void)yy_click:(id)sender
{
    [SingleTonInfo sharedInstance].modelType = ModelType_YY;
}
-(void)mj_click:(id)sender
{
    [SingleTonInfo sharedInstance].modelType = ModelType_MJ;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:[SingleTonInfo sharedInstance]] && [kStringF(keyPath) isEqualToString:kSel(modelType)]) {
        ModelType modelType = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
        switch (modelType) {
            case ModelType_YY:
                {
                    self.window.title = @"Json to OC Class (YY Model)";
                }
                break;
            case ModelType_MJ:
                {
                    self.window.title = @"Json to OC Class (MJ Model)";
                }
                break;
            default:
                {
                    self.window.title = @"Json to OC Class";
                }
                break;
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



@end
