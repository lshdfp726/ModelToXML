//
//  ViewController.m
//  DataAnalysis
//
//  Created by 刘松洪 on 2018/7/3.
//  Copyright © 2018年 刘松洪. All rights reserved.
//

#import "ViewController.h"
#import "ModelToXMLManager.h"
#import "TestModel.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
//    [self modelContainModel]; //model 嵌套model
//    [self modelObject];//仅仅是model 对象
//    [self modelArray];//model数组对象
//
//    self.imageView.frame = CGRectMake(0, 0, 200.0, 200.0);
//    [self.view addSubview:self.imageView];
//    self.imageView.center = self.view.center;
//
//    [self requestFromService];//本地服务器返回数据
    
    
    //model 转XML文件
    [self modelToXml];
}


- (void)modelToXml {
    ChirdrenModel *chirderM = [[ChirdrenModel alloc] init];
    chirderM.shareKey = @"abcd1234";
    chirderM.wpaKeyLength = [chirderM.shareKey length];
    chirderM.algorithmType = @"测试字段";
    
    TestModel *model = [[TestModel alloc] init];
    model.securityMode = @"personal";
    model.chirdModel = chirderM;
//    model.name = @"fasdf";
//    model.height = 170.0;
//    model.IntVar = 1;
//    model.FloatVar = 2.0;
//    model.nsInterVar = 3;
//    model.rect   = CGRectMake(0, 0, 0, 0);
//    struct Info i = {'c',1};
//    model.s = i;
//    model.dic = @{@"a" : @"b"};
//    model.date = [NSDate date];
//    model.arr = @[@[chirderM],@{@"key" : @"value"}];
//    model.dic = @{@"chird" : chirderM,
//                  @"chirdArr" : @[chirderM, chirderM],
//                  @"hahaha" : @"111111"
//                  };
    
    Wireless *rootModel = [[Wireless alloc] init];
    rootModel.WirelessSecu = model;
    rootModel.enable = YES;
    rootModel.ssid = @"test1234";
    NSDictionary *dic = @{@"version" : @"2.0",
                          @"xmlns"   : @"http://www.baidu.com",
                          };
    NSString *xmlStr =  [[ModelToXMLManager shareInstance] transformModel:rootModel headerInfo:dic];
    NSLog(@"解析结果:%@",xmlStr);
}

@end
