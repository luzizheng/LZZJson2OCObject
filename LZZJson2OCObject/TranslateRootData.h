#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN




@interface TranslateRootData : NSObject
/// errorCode
@property(nonatomic,copy)NSString * errorCode;

/// elapsedTime
@property(nonatomic,copy)NSString * elapsedTime;

/// type
@property(nonatomic,copy)NSString * type;

/// translateResult
@property(nonatomic,strong)NSArray * translateResult;


@property(nonatomic,copy,readonly)NSString * result;

@end
NS_ASSUME_NONNULL_END
