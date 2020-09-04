//
//  SingleTonInfo.m
//  LZZJson2OCObject
//
//  Created by Chemm_Luzz on 2020/8/10.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import "SingleTonInfo.h"
#import <Cocoa/Cocoa.h>

@implementation SingleTonInfo
@synthesize commonPrefix = _commonPrefix;
@synthesize rootPrefix = _rootPrefix;


+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        if ([instance respondsToSelector:@selector(updateInitialValue)]) {
            [instance performSelector:@selector(updateInitialValue)];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [[self class] sharedInstance];
}
- (id)copy {
    return [[self class] sharedInstance];
}

- (id)mutableCopy {
    return [[self class] sharedInstance];
}

-(void)updateInitialValue
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
//    NSString * dirPath = [ud valueForKey:kSel(dirPath)];
//    if (dirPath) {
//
//        self.dirPath = dirPath;
//    }
    
    NSString * commonPre = [ud valueForKey:kSel(commonPrefix)];
    if (commonPre) {
        self.commonPrefix = commonPre;
    }
    
    NSString * rootPre = [ud valueForKey:kSel(rootPrefix)];
    if (rootPre) {
        self.rootPrefix = rootPre;
    }
    
    id modelType = [ud valueForKey:kSel(modelType)];
    if (modelType) {
        self.modelType = [modelType integerValue];
    }else{
        self.modelType = ModelType_YY;
    }
    
    
}


- (void)setDirPath:(NSString *)dirPath
{
    _dirPath = dirPath;
//    kUserDefaultSave(dirPath, kSel(dirPath));
}

- (void)setCommonPrefix:(NSString *)commonPrefix
{
    _commonPrefix = commonPrefix;
    kUserDefaultSave(commonPrefix, kSel(commonPrefix));
}

- (void)setRootPrefix:(NSString *)rootPrefix
{
    _rootPrefix = rootPrefix;
    kUserDefaultSave(rootPrefix, kSel(rootPrefix));
}

- (void)setModelType:(ModelType)modelType
{
    _modelType = modelType;
    kUserDefaultSave(@(modelType), kSel(modelType));    
    
}

- (NSString *)commonPrefix
{
    if (!_commonPrefix) {
        _commonPrefix = @"LZZ";
    }
    return _commonPrefix;
}

- (NSString *)rootPrefix
{
    if (!_rootPrefix) {
        _rootPrefix = @"LZZROOT";
    }
    return _rootPrefix;
}

@end
