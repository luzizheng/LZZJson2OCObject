//
//  NSString+Utils.h
//  LZZJson2OCObject
//
//  Created by zizheng lu on 2020/9/10.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Utils)

/// 根据驼峰命名拆分字符串
-(NSArray *)seperateByUppercaseWord;

/// 转成空格键划分的句子
-(NSString *)formatToOneLineByUppercaseWord;

@end

NS_ASSUME_NONNULL_END
