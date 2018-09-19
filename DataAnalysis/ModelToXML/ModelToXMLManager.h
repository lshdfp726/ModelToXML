//
//  ModelToXMLManager.h
//  DataAnalysis
//
//  Created by 刘松洪 on 2018/7/7.
//  Copyright © 2018年 刘松洪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelToXMLManager : NSObject
+ (instancetype)shareInstance;

/**
 * model: 需要解析的model 实例,
 * header header信息，xml版本等等，可不传。默认没有头信息.
 */
- (NSString *)transformModel:(id)model headerInfo:(NSDictionary *)header;


@end
