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



#define kSel(_x_) NSStringFromSelector(@selector(_x_))
#define kUserDefaultSave(val,key) [[NSUserDefaults standardUserDefaults] setValue:val forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];


#define NS_HAS_PERMISSION_ERROR(error) (error.code == NSFileReadNoPermissionError || error.code == NSFileWriteNoPermissionError)

#define kStrHasText(str) (str!=nil && ![str isKindOfClass:[NSNull class]] && ![str isEqualToString:@""])
#define kStringF(str) str==nil?@"":[NSString stringWithFormat:@"%@",str]
