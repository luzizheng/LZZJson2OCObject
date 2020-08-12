//
//  TranslateAnnotationTool.h
//  LZZJson2OCObject
//
//  Created by Chemm_Luzz on 2020/8/12.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TranslateAnnotationTool : NSObject

+(void)translateAllHeaderContent:(NSString *)content withCompletion:(void(^)(NSString * result))completion;

@end

NS_ASSUME_NONNULL_END
