//
//  TranslateAnnotationTool.m
//  LZZJson2OCObject
//
//  Created by Chemm_Luzz on 2020/8/12.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import "TranslateAnnotationTool.h"
#import "TranslateRootData.h"
@implementation TranslateAnnotationTool
+(void)translateAllHeaderContent:(NSString *)content withCompletion:(void(^)(NSString * result))completion
{
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        completion(content);
        return;
    }
    
    
    NSScanner *scanner = [NSScanner scannerWithString:content];
    NSMutableArray <NSString *>* allAnnotation = [NSMutableArray array];
    while (scanner.isAtEnd == NO) {
        NSString *text;
        [scanner scanUpToString:@"/// " intoString:nil];
        [scanner scanString:@"/// " intoString:nil];
        [scanner scanUpToString:@"\n" intoString:&text];
        if (text) {
            [allAnnotation addObject:text];
        }
    }
    
    __block NSMutableDictionary * map = [NSMutableDictionary dictionary];
    
    NSLog(@"即将开始多个请求");
    //创建group
    dispatch_group_t group = dispatch_group_create();
    //全局并发队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    for (NSString * thisKey in allAnnotation) {
        
        dispatch_group_enter(group);
        dispatch_async(globalQueue,^{
            
            NSString * translateApi = @"http://fanyi.youdao.com/translate";
            NSDictionary * params = @{@"doctype":@"json",@"type":@"EN2ZH_CN",@"i":kStringF(thisKey)};
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager GET:translateApi parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                //
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                TranslateRootData * data = [TranslateRootData yy_modelWithJSON:responseObject];
                NSString * result = data.result;
                if (kStrHasText(result) == NO) {
                    result = thisKey;
                }
                [map setValue:result forKey:thisKey];
                NSLog(@"%@:%@\n",thisKey,result);
                dispatch_group_leave(group);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [map setValue:thisKey forKey:thisKey];
                dispatch_group_leave(group);
            }];
        });
    }
    
    dispatch_group_notify(group, globalQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"全部请求完成\n");
            
            NSString * result_content = content;
            for (NSString * key in map.allKeys) {
                
                NSString * result = [map objectForKey:key];
                NSLog(@"%@:%@\n",key,result);
                result_content = [result_content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/// %@",key] withString:[NSString stringWithFormat:@"/// %@",result]];
            }
            if (completion) {
                completion(result_content);
            }
        });
    });
}
@end
