//
//  NSObject+NewModelToXML.h
//  DataAnalysis
//
//  Created by 刘松洪 on 2018/7/6.
//  Copyright © 2018年 刘松洪. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 特殊说明，只支持数组里面嵌套同一种模型/字典的情况，其他情况格式没办法转换（xml 必须有头/尾标签）
 * 联合体 等一些在OC冷门的数据结构不予考虑。
 */
@interface NSObject (NewModelToXML)
/**
 * 转换入口，返回XML字符串
 */
- (NSString *)modelTransmitXml;

//需要忽略的属性
+ (NSArray *)ignoreProperty;


/**
 * 如果类或者嵌套的子类需要换节点名称可以用此方法，类的属性节点暂不支持替换
 */
+ (NSString *)rootName;

@end
