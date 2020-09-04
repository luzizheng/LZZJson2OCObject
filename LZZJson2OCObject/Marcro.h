//
//  Marcro.h
//  LZZJson2OCObject
//
//  Created by Chemm_Luzz on 2020/8/12.
//  Copyright © 2020 Chemm. All rights reserved.
//

#ifndef Marcro_h
#define Marcro_h


#endif /* Marcro_h */

#import <Foundation/Foundation.h>


#define kSel(_x_) NSStringFromSelector(@selector(_x_))
#define kUserDefaultSave(val,key) [[NSUserDefaults standardUserDefaults] setValue:val forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];


#define NS_HAS_PERMISSION_ERROR(error) (error.code == NSFileReadNoPermissionError || error.code == NSFileWriteNoPermissionError)

#define kStrHasText(str) (str!=nil && ![str isKindOfClass:[NSNull class]] && ![str isEqualToString:@""])
#define kStringF(str) str==nil?@"":[NSString stringWithFormat:@"%@",str]
#define kGetSizeFit(view)  [view sizeThatFits:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)]


#define kGitHubLink @"https://github.com/luzizheng/LZZJson2OCObject"

#define kAppName [[NSBundle mainBundle].infoDictionary valueForKey:(NSString *)kCFBundleNameKey]
#define kAppName [[NSBundle mainBundle].infoDictionary valueForKey:(NSString *)kCFBundleNameKey]
static inline NSString * kGetTimeWithFormat(NSString * format){
    NSDate * dateNow = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:dateNow];
}
static inline NSString * kGetCopyRightDescription(){
    NSString * cp = nil;
    for (id value in [NSBundle mainBundle].infoDictionary.allValues) {
        if ([value isKindOfClass:[NSString class]]) {
            if ([((NSString *)value) containsString:@"Copyright"]) {
                cp = value;
                break;
            }
        }
    }
    return cp;
}
