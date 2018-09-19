//
//  ModelToXMLManager.m
//  DataAnalysis
//
//  Created by 刘松洪 on 2018/7/7.
//  Copyright © 2018年 刘松洪. All rights reserved.
//

#import "ModelToXMLManager.h"
#import "NSObject+NewModelToXML.h"


@implementation ModelToXMLManager
+ (instancetype)shareInstance {
    static ModelToXMLManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[ModelToXMLManager alloc] init];
    });
    return _manager;
}


//需要传入的model
- (NSString *)transformModel:(id)model headerInfo:(NSDictionary *)header {
    NSMutableString *xml = [NSMutableString stringWithString:[model modelTransmitXml]];
    NSDictionary *dic = [header copy];
    if (dic && dic.allKeys.count != 0) {
        NSArray *infoArr = dic.allKeys;
        NSString *rootName = @"";
        if ([[model class] respondsToSelector:@selector(rootName)]) {
            rootName = [[model class] rootName];
        } else {
            rootName = NSStringFromClass([model class]);
        }
        NSRange range = [xml rangeOfString:rootName];
        NSInteger count  = infoArr.count;
        NSMutableString *container = [NSMutableString string];
        for (NSInteger i = 0 ; i < count;  i ++) {
            NSString *key = infoArr[i];
            NSString *value = [dic valueForKey:key];
            [container appendString:[NSString stringWithFormat:@" %@:%@",key,value]];
        }
        [xml insertString:container atIndex: range.location + range.length];
    }
    
    return [NSString stringWithString:xml];
}



@end
