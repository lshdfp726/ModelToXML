//
//  TestModel.m
//  DataAnalysis
//
//  Created by 刘松洪 on 2018/9/19.
//  Copyright © 2018年 刘松洪. All rights reserved.
//

#import "TestModel.h"

@implementation Wireless

@end

@implementation TestModel
+ (NSArray *)ignoreProperty {
    return @[@"s",];
}

+ (NSString *)rootName {
    return @"WirelessSecurity";
}
@end


@implementation ChirdrenModel
+ (NSString *)rootName {
    return @"WPA";
}
@end
