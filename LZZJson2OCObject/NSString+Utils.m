//
//  NSString+Utils.m
//  LZZJson2OCObject
//
//  Created by zizheng lu on 2020/9/10.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)
-(NSArray *)seperateByUppercaseWord
{
    NSString * string = [self copy];
    NSMutableArray * result = [NSMutableArray array];
    NSInteger lastLocation = 0;
    for (int i = 0; i < string.length; i++) {
        char word = [string characterAtIndex:i];
        if (word > 64 && word < 91) {
            // 大写字母
            NSString * seperate_word = [string substringWithRange:NSMakeRange(lastLocation, i - lastLocation)];
            [result addObject:seperate_word];
            lastLocation =i;
        }
    }
    [result addObject:[string substringWithRange:NSMakeRange(lastLocation, string.length - lastLocation)]];
    return result;
}

-(NSString *)formatToOneLineByUppercaseWord
{
    NSArray * words = [self seperateByUppercaseWord];
    NSMutableString * string = [[NSMutableString alloc] init];
    for (NSString * word in words) {
        [string appendString:[word lowercaseString]];
        [string appendString:@" "];
    }
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
