//
//  JsonToModelTool.h
//  TestTool
//
//  Created by Chemm_Luzz on 2019/8/22.
//  Copyright © 2019 Chemm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


extern NSString * const NSParsingErrorNotification;


@interface JsonToModelTool : NSObject


+(void)parseRootJsonWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
