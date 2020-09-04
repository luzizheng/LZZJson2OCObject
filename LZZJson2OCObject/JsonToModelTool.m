//
//  JsonToModelTool.m
//  TestTool
//
//  Created by Chemm_Luzz on 2019/8/22.
//  Copyright © 2019 Chemm. All rights reserved.
//

#import "JsonToModelTool.h"
#import <objc/runtime.h>

#import "TranslateAnnotationTool.h"
NSString * const NSParsingErrorNotification = @"NSParsingErrorNotification";

@implementation JsonToModelTool

+(void)parseRootJsonWithDict:(NSDictionary *)dict;
{
    [self createNewModelWithJson:dict andModelClassName:[SingleTonInfo sharedInstance].rootPrefix];
}

+(NSDictionary *)modelCustomPropertyMapper
{
    unsigned int count;
    objc_property_t * properties = class_copyPropertyList([NSObject class], &count);
    NSMutableDictionary *mapDict = [NSMutableDictionary dictionary];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        NSString * replaceName = [NSString stringWithFormat:@"%@_this",name];
        [mapDict setValue:replaceName forKey:name];
    }
    [mapDict addEntriesFromDictionary:@{@"id":@"id_this",
                                        @"const":@"const_this",
                                        @"extern":@"extern_this",
                                        @"in":@"in_this",
                                        @"out":@"out_this"
    }];
    return mapDict;
}

+(void)createNewModelWithJson:(NSDictionary *)jsonDict andModelClassName:(NSString *)className
{
    NSString * fileName_h = [NSString stringWithFormat:@"%@.h",className];
    NSString * fileName_m = [NSString stringWithFormat:@"%@.m",className];
    NSMutableString * resultH = [[NSMutableString alloc] init];
    NSMutableArray * otherClsName = [NSMutableArray array];
    NSMutableDictionary * propertyMapper = [NSMutableDictionary dictionary];
    NSMutableDictionary * containerProertyMapper = [NSMutableDictionary dictionary];
    for(NSString * thisKey in [jsonDict allKeys]){
        NSString * propertyName = thisKey;
        // .h
        NSString * mod = nil;
        NSString * defaultClsName = nil;
        id value = [jsonDict valueForKey:propertyName];
        NSString * thisClsName = NSStringFromClass([value class]);
        NSDictionary * mod_map = @{@"__NSDictionaryM":@"strong",
                                   @"NSDictionary":@"strong",
                                   @"__NSCFString":@"copy",
                                   @"NSTaggedPointerString":@"copy",
                                   @"__NSCFNumber":@"copy",
                                   @"__NSCFConstantString":@"copy",
                                   @"NSString":@"copy",
                                   @"__NSArrayM":@"strong"
                                   };
        NSDictionary * class_map = @{@"__NSDictionaryM":@"NSDictionary",
                                     @"NSDictionary":@"NSDictionary",
                                     @"__NSCFString":@"NSString",
                                     @"NSTaggedPointerString":@"NSString",
                                     @"__NSCFNumber":@"NSString",
                                     @"__NSCFConstantString":@"NSString",
                                     @"NSString":@"NSString",
                                     @"__NSArrayM":@"NSArray"
                                     };
        mod = [mod_map valueForKey:thisClsName];
        defaultClsName = [class_map valueForKey:thisClsName];
        if(mod==nil){
            mod = @"copy";
        }
        if(defaultClsName == nil){
            defaultClsName = @"NSString";
        }
        
        // 检查建名（与系统冲突）
        NSDictionary *modelCustomPropertyMapper = [self modelCustomPropertyMapper];
        for(NSString * k in modelCustomPropertyMapper.allKeys){
            if([k isEqualToString:thisKey]){
                propertyName = [modelCustomPropertyMapper objectForKey:k];
                [propertyMapper setValue:k forKey:propertyName];
            }
        }
        if([propertyName hasPrefix:@"new"]){ // 键名带有new开头
            NSString * replaceName = [NSString stringWithFormat:@"%@_%@",[kCommonPrefix lowercaseString],[propertyName capitalizedString]];
            [propertyMapper setValue:propertyName forKey:replaceName];
            propertyName = replaceName;
        }
        
        // 处理model内嵌model
        if([defaultClsName isEqualToString:@"NSDictionary"]){
            // need to create an entity
            NSString * firstCha = [propertyName substringToIndex:1];
            NSString * tailCha = [propertyName substringFromIndex:1];
            NSString * entityClsName = [NSString stringWithFormat:@"%@%@%@",kCommonPrefix,[firstCha uppercaseString],tailCha];
            [otherClsName addObject:entityClsName];
            [self createNewModelWithJson:value andModelClassName:entityClsName];
            defaultClsName = entityClsName;
            mod = @"strong";
        }
        
        // 处理数组内嵌model
        if([defaultClsName isEqualToString:@"NSArray"]){
            NSArray * array = value;
            id firstItem = [array firstObject];
            if([firstItem isKindOfClass:[NSDictionary class]]){
                NSString * firstCha = [propertyName substringToIndex:1];
                NSString * tailCha = [propertyName substringFromIndex:1];
                NSString * entityClsName = [NSString stringWithFormat:@"%@%@%@Item",kCommonPrefix,[firstCha uppercaseString],tailCha];
                [otherClsName addObject:entityClsName];
                
                // 因为数组里面的字典元素，可能每个的属性数量不同，所以要创造一个字典包含所有属性的
                NSMutableDictionary * hole_dict = [NSMutableDictionary dictionaryWithDictionary:firstItem];
                for (NSDictionary * each_item in array) {
                    for (NSString * key_n in each_item.allKeys) {
                        if ([hole_dict.allKeys containsObject:key_n] == NO) {
                            [hole_dict setValue:each_item[key_n] forKey:key_n];
                        }
                    }
                }
                
                [self createNewModelWithJson:hole_dict andModelClassName:entityClsName];
                defaultClsName = [NSString stringWithFormat:@"NSArray <%@ *>",entityClsName];
                [containerProertyMapper setValue:entityClsName forKey:propertyName];
            }
        }
        NSString * strA = [NSString stringWithFormat:@"/// %@\n@property(nonatomic,%@)%@ * %@;\n\n",thisKey,mod,defaultClsName,propertyName];
        [resultH appendString:strA];
        
    }
    NSString * headerStr = [self createHeaderFileWithClsName:className andPropertiesString:resultH andExtModelClassNames:otherClsName];
    __block NSString * blockPath = [kDirPath stringByAppendingPathComponent:fileName_h];
    [TranslateAnnotationTool translateAllHeaderContent:headerStr withCompletion:^(NSString * _Nonnull result) {
        NSError * headErr = nil;
        [result writeToURL:[NSURL fileURLWithPath:blockPath] atomically:YES encoding:NSUTF8StringEncoding error:&headErr];
        if (headErr) {
            NSLog(@"error : %@",headErr.description);
            [[NSNotificationCenter defaultCenter] postNotificationName:NSParsingErrorNotification object:nil userInfo:@{NSLocalizedDescriptionKey:headErr.description}];
        }
    }];
    
    
    NSString * mStr = [self createImplementationFileWithClsName:className andPropertyMapper:propertyMapper andContainerPropertyGenericClassDict:containerProertyMapper];
    NSError * mError = nil;
    [mStr writeToURL:[NSURL fileURLWithPath:[kDirPath stringByAppendingPathComponent:fileName_m]] atomically:YES encoding:NSUTF8StringEncoding error:&mError];
    if (mError) {
        NSLog(@"error : %@",mError.description);
        [[NSNotificationCenter defaultCenter] postNotificationName:NSParsingErrorNotification object:nil userInfo:@{NSLocalizedDescriptionKey:mError.description}];
    }
    
}

+(NSString *)createHeaderFileWithClsName:(NSString *)clsName andPropertiesString:(NSString *)propertiesString andExtModelClassNames:(NSArray *)otherModelClsNames
{
    NSMutableString * result = [[NSMutableString alloc] init];
    [result appendString:@"#import <Foundation/Foundation.h>\n"];
    for(NSString * other in otherModelClsNames){
        NSString * line = [NSString stringWithFormat:@"#import \"%@.h\"\n",other];
        [result appendString:line];
    }
    [result appendString:@"\nNS_ASSUME_NONNULL_BEGIN\n"];
    [result appendFormat:@"@interface %@ : NSObject\n",clsName];
    [result appendString:propertiesString];
    [result appendString:@"\n@end\n"];
    [result appendString:@"NS_ASSUME_NONNULL_END\n"];
    
    return result;
}

+(NSString *)createImplementationFileWithClsName:(NSString *)clsName andPropertyMapper:(NSDictionary *)propertyMapper andContainerPropertyGenericClassDict:(NSDictionary *)containerPropertyGenericClassDict
{
    NSMutableString * result = [[NSMutableString alloc] init];
    
    [result appendFormat:@"#import \"%@.h\"\n",clsName];
    [result appendFormat:@"@implementation %@\n",clsName];
    
    // modelCustomPropertyMapper
    if(propertyMapper.allKeys.count>0){
        if ([SingleTonInfo sharedInstance].modelType == ModelType_YY) {
            [result appendString:@"\n+(NSDictionary *)modelCustomPropertyMapper\n{\n    return @{"];
        }else if ([SingleTonInfo sharedInstance].modelType == ModelType_MJ){
            [result appendString:@"\n+(NSDictionary *)mj_replacedKeyFromPropertyName\n{\n    return @{"];
        }
        
        NSArray * allKeys = propertyMapper.allKeys;
        if(allKeys.count == 1){
            NSString * key = [allKeys firstObject];
            NSString * val = propertyMapper[key];
            [result appendFormat:@"@\"%@\":@\"%@\"};\n}\n",key,val];
        }else{
            for(int i = 0;i<allKeys.count;i++){
                NSString * key = allKeys[i];
                NSString * val = propertyMapper[key];
                if(i == allKeys.count-1){
                    [result appendFormat:@"@\"%@\":@\"%@\"\n             };\n}\n",key,val];
                }else{
                    [result appendFormat:@"@\"%@\":@\"%@\",\n              ",key,val];
                }
            }
        }
        
    }
    
    // modelContainerPropertyGenericClass
    if(containerPropertyGenericClassDict.allKeys.count>0){
        
        if ([SingleTonInfo sharedInstance].modelType == ModelType_YY) {
            [result appendString:@"\n+(NSDictionary *)modelContainerPropertyGenericClass\n{\n    return @{"];
        }else if ([SingleTonInfo sharedInstance].modelType == ModelType_MJ){
            [result appendString:@"\n+(NSDictionary *)mj_objectClassInArray\n{\n    return @{"];
        }
        NSArray * allKeys = containerPropertyGenericClassDict.allKeys;
        if(allKeys.count == 1){
            NSString * key = [allKeys firstObject];
            NSString * val = containerPropertyGenericClassDict[key];
            
            if ([SingleTonInfo sharedInstance].modelType == ModelType_YY) {
                [result appendFormat:@"@\"%@\" : [%@ class]};\n}\n",key,val];
            }else if ([SingleTonInfo sharedInstance].modelType == ModelType_MJ){
                [result appendFormat:@"@\"%@\" : @\"%@\"};\n}\n",key,val];
            }
        }else{
            for(int i = 0;i<allKeys.count;i++){
                NSString * key = allKeys[i];
                NSString * val = containerPropertyGenericClassDict[key];
                if(i == allKeys.count-1){
                    [result appendFormat:@"@\"%@\" : [%@ class]\n             };\n}\n",key,val];
                }else{
                    [result appendFormat:@"@\"%@\" : [%@ class]\n,              ",key,val];
                }
            }
        }
        
    }
    [result appendString:@"\n@end\n"];
    
    return result;
}

@end
