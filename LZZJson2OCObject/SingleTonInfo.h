//
//  SingleTonInfo.h
//  LZZJson2OCObject
//
//  Created by Chemm_Luzz on 2020/8/10.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import <Foundation/Foundation.h>




NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ModelType) {
    ModelType_YY = 0,
    ModelType_MJ
};

@interface SingleTonInfo : NSObject
@property(nonatomic,copy)NSString * rootPrefix;
@property(nonatomic,copy)NSString * commonPrefix;
@property(nonatomic,copy)NSString * dirPath;
@property(nonatomic,assign)ModelType modelType;

+ (instancetype)sharedInstance;




@end


#define kDirPath [SingleTonInfo sharedInstance].dirPath
#define kCommonPrefix [SingleTonInfo sharedInstance].commonPrefix
#define kRootPrefix [SingleTonInfo sharedInstance].rootPrefix


NS_ASSUME_NONNULL_END
