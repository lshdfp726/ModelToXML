//
//  TestModel.h
//  DataAnalysis
//
//  Created by 刘松洪 on 2018/9/19.
//  Copyright © 2018年 刘松洪. All rights reserved.
//

#import <Foundation/Foundation.h>

struct Info {
    char a;
    int  b;
};


@class TestModel;
@class ChirdrenModel;

/**
 * rootModel 根model
 */
@interface Wireless : NSObject
@property (nonatomic, strong) TestModel *WirelessSecu;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy) NSString *ssid;
@end

/**
 * 一级子model
 */
@interface TestModel : NSObject <NSCacheDelegate>
@property (nonatomic, copy) NSString *securityMode;
//@property (nonatomic, assign) CGFloat height; //身高
//@property (nonatomic, assign) int IntVar;//
//@property (nonatomic, assign) float FloatVar;
//@property (nonatomic, assign) NSInteger nsInterVar;//Tq
//@property (nonatomic, assign) CGRect rect;
@property (nonatomic, copy) NSArray *arr;
@property (nonatomic, copy) NSDictionary *dic;
//@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) ChirdrenModel *chirdModel;
@end

/**
 * 二级子model
 */
@interface ChirdrenModel : NSObject
@property (nonatomic, copy) NSString *algorithmType;
@property (nonatomic, copy) NSString *shareKey;
@property (nonatomic, assign) NSInteger wpaKeyLength;
@end





