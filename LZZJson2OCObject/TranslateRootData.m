#import "TranslateRootData.h"




@implementation TranslateRootData


- (NSString *)result
{
    if (self.translateResult) {
        if (self.translateResult.count>0) {
            id obj_a = [self.translateResult firstObject];
            if ([obj_a isKindOfClass:[NSArray class]]) {
                NSArray * array = obj_a;
                if (array.count>0) {
                    id obj_b = [array firstObject];
                    if ([obj_b isKindOfClass:[NSDictionary class]]) {
                        id value = [obj_b objectForKey:@"tgt"];
                        if (value && [value isKindOfClass:[NSString class]]) {
                            return value;
                        }
                    }
                }
            }else if ([obj_a isKindOfClass:[NSDictionary class]]){
                id value = [obj_a objectForKey:@"tgt"];
                if (value && [value isKindOfClass:[NSString class]]) {
                    return value;
                }
            }
        }
    }
    return @"";
}
@end
