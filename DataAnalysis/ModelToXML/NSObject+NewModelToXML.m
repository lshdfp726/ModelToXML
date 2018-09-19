//
//  NSObject+NewModelToXML.m
//  DataAnalysis
//
//  Created by 刘松洪 on 2018/7/6.
//  Copyright © 2018年 刘松洪. All rights reserved.
//

#import "NSObject+NewModelToXML.h"
#import <objc/runtime.h>
#import <MJExtension.h>


//系统类和自定义类
typedef NS_ENUM(NSInteger, ClassType) {
    SystemType,//系统类
    CustomType//自定义类
};


// 容器，非容器
typedef NS_ENUM(NSInteger, StoregeType) {
    ContainerType,//容器类
    NotContainerType//非容器类
};


//系统容器还是自定义容器
typedef NS_ENUM(NSInteger, SystemContainerType) {
    CustomContainer,//其实就是自定义的model，也算容器对象
    SystemContainer,
};


const NSString *propertyTypeKey; //用来存储 key-Value （key 是属性名称，value 是属性的类型）
const NSString *propertyValueKey;//用来存储 key-Vakue  (key 是属性名称，value 是属性值）

//XML 字符串插入节点key
static inline NSString* insertKey(NSString *xmlStr, NSString *key)
{
    return [xmlStr stringByReplacingOccurrencesOfString:@"*" withString:[NSString stringWithFormat:@"<%@>_</%@>*",key,key]];
}


//XML 字符串插入节点值
static inline NSString* insertValue(NSString *xmlStr, NSString *value)
{
    return [xmlStr stringByReplacingOccurrencesOfString:@"_" withString:[NSString stringWithFormat:@"%@",value]];
}


//XML 插入子节点(容器类，自定义类)
static inline NSString* insertChirdenModeNode(NSString *xmlStr, NSString *value)
{
    return [xmlStr stringByReplacingOccurrencesOfString:@"*" withString:[NSString stringWithFormat:@"%@*",value]];
}


//系统非容器对象类型
static inline NSArray* systemNotContainerObjcClass()
{
    return @[@"NSNumber",
             @"NSURL",
             @"NSDate",
             @"NSValue",
             @"NSData",
             @"NSError",
             @"NSString",
             @"NSAttributedString"];
}

//系统基本类型
static inline NSArray* systemBaseType()
{
    return @[@"Tc",
             @"Td",
             @"Tf",
             @"Tl",
             @"Ts",
             @"Ti",
             @"Tq",
             @"CGRect",
             @"TB",
             @"="];
}


//系统容器类型
static inline NSArray* Container()
{
    return @[@"NSArray",
             @"NSDictionary"];
}



/**
 * model 直接转为Xml格式的字符串
 * 约定 节点key值用 _ 做站位符， 节点值用 * 做占位符。然后字符串替换。 插入子model 节点也用 * 站位
 */
@implementation NSObject (NewModelToXML)
- (NSString *)modelTransmitXml { //入口
    [self getClassData]; //分解出类的 @{变量名称 : 变量类型(字符串描述)} 、@{变量名称 : 变量值(id)}

    //根节点
    NSString *rootName = nil;
    if ([[self class] respondsToSelector:@selector(rootName)]) {//如果定义了类节点名称
        rootName = [[self class] rootName]; //根结点key
    } else {
        rootName = NSStringFromClass([self class]); //根结点key
    }
    NSString *xmlStr = [NSString stringWithFormat:@"<%@>\n*\n</%@>",rootName,rootName];
    
    NSArray *keyArr = [[self getKeyValue] allKeys];
    NSInteger count = keyArr.count;
    for (NSInteger i = 0; i < count; i ++) {
        NSString *key = keyArr[i];
        id value = [self valueForKey:key];
        if (value) {
            StoregeType type = [self filterContainer:key]; //筛选当前属性出容器类和非容器类
            if (type == ContainerType) { //容器类，继续遍历
                SystemContainerType t = [self fileterCustomContainer: key];//分离系统的容器和自定义容器类
                if (t == SystemContainer) { //系统容器类
                    NSString *chirdenNode = [self disposeSystemContainer:key value: value];
                    xmlStr = insertChirdenModeNode(xmlStr, chirdenNode);
                } else {
                    //自定义类
                    NSString *customNode = [self customModelWith:key value:value];
                    xmlStr = insertChirdenModeNode(xmlStr, customNode);
                }
            } else if (type == NotContainerType) {
                ClassType clsType = [self filerClassType:key];
                if (clsType == SystemType) { //系统非容器类，直接可以KVC赋值的属性
                    //kvc
                    NSString *chirdenNode = [self systemKVCValue:value];
                    if (![xmlStr containsString:@"*"]) {
                        xmlStr = [NSString stringWithFormat:@"%@*",xmlStr];
                    }
                    xmlStr = insertKey(xmlStr, key);
                    xmlStr = insertValue(xmlStr, chirdenNode);
                } else {
                    //自定义类
                    NSString *customNode = [self customModelWith:key value:value];
                    xmlStr = insertChirdenModeNode(xmlStr, customNode);
                }
            }
        }
        
        if (count - 1 == i) { //表示遍历到最后一个数组，加换行符
            xmlStr = [xmlStr stringByReplacingOccurrencesOfString:@"*" withString:@""];
            NSRange range = [xmlStr rangeOfString:[NSString stringWithFormat:@"</%@>",rootName]];
            NSMutableString *muta = [[NSMutableString alloc] initWithString:xmlStr];
            [muta insertString:@"\n" atIndex:range.location];
            xmlStr = [NSString stringWithString:muta];
        }
    }
    return [xmlStr stringByReplacingOccurrencesOfString:@"*" withString:@""];
}


#pragma mark - 添加每一个model的根节点




#pragma mark - 属性筛选分类方法
/**
 * key 是属性名称
 * 分离容器和非容器类
 * return 容器或者非容器类
 */
- (StoregeType)filterContainer:(NSString *)key {
    StoregeType type = ContainerType;//默认自定义，然后取遍历系统类
    NSDictionary *dic = [self getKeyType];
    NSArray *keyArray = dic.allKeys;
    if ([keyArray containsObject:key]) { //判断key 是属于这个类的
        NSString *keyVar = dic[key];//获取key属性对应的类型
        NSLog(@"属性名称%@  属性类型:%@ ",key, keyVar);
        NSMutableArray *totalArray = [NSMutableArray arrayWithArray:systemNotContainerObjcClass()];
        [totalArray addObjectsFromArray:systemBaseType()];
 
        NSInteger count = totalArray.count;
        for (NSInteger i = 0; i < count; i ++) {
            if ([keyVar containsString:totalArray[i]]) {
                type = NotContainerType;
            }
        }
    }
    return type;
}


/**
 * key 属性名称
 * 分离系统类和自定义类
 * return 系统类还是自定义的类
 */
- (ClassType)filerClassType:(NSString *)key {
    ClassType type = CustomType;
    NSDictionary *dic = [self getKeyType];
    NSArray *keyArray = dic.allKeys;
    if ([keyArray containsObject:key]) {
        NSString *keyVar = dic[key];
        NSMutableArray *totalArray = [NSMutableArray arrayWithArray:systemNotContainerObjcClass()];
        [totalArray addObjectsFromArray:systemBaseType()];
        [totalArray addObjectsFromArray:Container()];
        //totoal 为囊括系统所有的类型变量
        NSInteger count = totalArray.count;
        for (NSInteger i = 0 ; i < count; i ++) {
            if ([keyVar containsString:totalArray[i]]) {
                type = SystemType;
            }
        }
    }
    return type;
}


/**
 * key 属性名称
 * 分离出系统容器类还是自定义容器类（其实就是自定义类）
 * return 数组/字典还是 自定义类
 */
- (SystemContainerType)fileterCustomContainer:(NSString *)key {
    SystemContainerType type = CustomContainer;
    NSDictionary *dic = [self getKeyType];
    NSArray *keyArray = dic.allKeys;
    if ([keyArray containsObject:key]) {
        NSString *keyVar = dic[key];
        NSMutableArray *totalArray = [NSMutableArray arrayWithArray:Container()];
        //totoal 为囊括系统所有的类型变量
        NSInteger count = totalArray.count;
        for (NSInteger i = 0 ; i < count; i ++) {
            if ([keyVar containsString:totalArray[i]]) {
                type = SystemContainer;
            }
        }
    }
    return type;
}


#pragma mark - 处理自定义model数据成为XML
- (NSString *)disposeCustomData:(NSString *)key value:(id)value {
    NSString *xmlStr = [value modelTransmitXml];
    return xmlStr;
}


/**
 * 处理自定义类成为XML字符串
 * return 返回子model 节点字符串
 */
- (NSString *)customModelWith:(NSString *)key value:(NSString *)value {
    NSString *customNode = [self disposeCustomData:key value:value];
    return customNode;
}


#pragma mark - 处理系统容器类数据成为XML
- (NSString *)disposeSystemContainer:(NSString *)key value:(id)value {
    NSString *chirdenNode = @"";
    if ([value isKindOfClass:[NSArray class]]) {
        chirdenNode =  [chirdenNode stringByAppendingString:[self disposeArrayDataKey:key value:value]];//默认数组里面嵌套同一类模型。类似C语言数组只限制同类指针。
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        chirdenNode = [chirdenNode stringByAppendingString:[self disposeDictionaryKey:key value:value]];
    } else {
        NSLog(@"不存在的类型");
        return nil;
    }
    return chirdenNode;
}


/**
 * 处理数组数据
 * 数组里面只包含dic/Model/Array 形式，其他形式考虑
 */
- (NSString *)disposeArrayDataKey:(NSString *)key value:(id)value {
    NSArray *arr = [NSArray arrayWithArray:value];
    NSInteger count = arr.count;
    NSString *chirdenXml = [NSString stringWithFormat:@"<%@>_</%@>",key,key];
    NSString *container = @"";
    for (NSInteger i = 0; i < count;  i++) {//默认数组里面嵌套模型，其他不考虑，实际情况也不大可能会出现这种数据类型
        id model = arr[i];
        if ([model isKindOfClass:[NSDictionary class]]) { //字典
            NSString *chirdenNode = [self disposeDictionaryKey:@"" value:model];
            container = [container stringByAppendingString:chirdenNode];
        } else if ([model isKindOfClass:[NSArray class]]){
            NSString *chirdenNode = [self disposeArrayDataKey:@"" value:model];
            container = [container stringByAppendingString:chirdenNode];
        } else {
            //自定义模型
            NSString *chirdenNode = [model modelTransmitXml];
            container = [container stringByAppendingString:chirdenNode];
        }
        
        if (count - 1 == i) {
            container = [container stringByReplacingOccurrencesOfString:@"*" withString:@""];
        }
    }
    if (key.length != 0 && key) {
        chirdenXml = [NSString stringWithFormat:@"<%@>_</%@>",key,key];
        chirdenXml = insertValue(chirdenXml, container);
        return chirdenXml;
    }
    return container;
}


/**
 * 分两种情况:
 * 1.数组里面包含字典，然后走此方法，这个时候数组里是不提供key值的，数组没办法遍历出每一个对象自身的内容，只能交给下一级处理。
 * 2.字典里面包含字典，这时候会带key值，因为字典可以遍历所有的key和value，可以在当前层级处理出key，丢给下一级。
 */
- (NSString *)disposeDictionaryKey:(NSString *)key value:(id)value {
    NSString *xmlStr = @"";
    NSString *container = @"";
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:value];
    NSArray *allKey   = dic.allKeys;
    NSInteger count = allKey.count;
    for (NSInteger i = 0; i < count;  i++) {//默认数组里面嵌套同一类模型。类似C语言数组只限制同类指针。
        NSString *k = allKey[i];
        id model = dic[k];
        if (model) {
            if ([model isKindOfClass:[NSArray class]]) {
                NSString *chirdenValue = [self disposeArrayDataKey:k value:model];
                container = [container stringByAppendingString:chirdenValue];
            } else {
                NSArray *systemNotContainerClass = systemNotContainerObjcClass();//系统非容器对象类型
                NSInteger count = systemNotContainerClass.count;
                BOOL flag = NO;
                for (NSInteger i = 0 ; i < count; i++) {
                    NSString *strClass = systemNotContainerClass[i];
                    if ([model isKindOfClass:NSClassFromString(strClass)]) {
                        NSString *chirderRoot  = [NSString stringWithFormat:@"<%@>_</%@>",k,k];
                        NSString *chirdenValue = [self systemKVCValue:model];
                        chirderRoot = insertValue(chirderRoot, chirdenValue);
                        container = [container stringByAppendingString:chirderRoot];
                        flag = YES; //标记出字典容器里面是系统对象类型，而非自定义
                    }
                }
                if (!flag) {
                    //自定义
                    NSString *chirderRoot  = [NSString stringWithFormat:@"<%@>_</%@>",k,k];
                    NSString *chirdenValue = [self customModelWith:k value:model];
                    chirderRoot = insertValue(chirderRoot, chirdenValue);
                    container = [container stringByAppendingString:chirderRoot];
                }
            }
        }
        if (count - 1 == i) {
            container = [container stringByReplacingOccurrencesOfString:@"*" withString:@""];
        }
    }
    if (key.length != 0 && key) {
        xmlStr = [NSString stringWithFormat:@"<%@>_</%@>",key,key];
        xmlStr = insertValue(xmlStr, container);
        return xmlStr;
    }
    return container;
}

#pragma mark - 系统属性直接支持KVC赋值,返回XML字符串
- (NSString *)systemKVCValue:(id)value{
    return [NSString stringWithFormat:@"%@",value];
}


/**
 *获取类属性变量名称和变量类型并且以字典形式存起来
 *获取类属性变量名称和值并且以字典形式存起来
 */
- (void)getClassData {
    NSMutableDictionary *keyTypeDic  = [NSMutableDictionary dictionary];
    NSMutableDictionary *keyValueDic = [NSMutableDictionary dictionary];
    NSMutableArray *ignore = [NSMutableArray array];
    if ([[self class] respondsToSelector:@selector(ignoreProperty)]) {
        [ignore addObjectsFromArray:[[self class] ignoreProperty]]; //自定义类忽视的属性
    }
    [ignore addObjectsFromArray:[[self class] systemIgnoreProperty]];//忽视系统自动添加的属性
    
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t p = propertyList[i];
        const char *type  = property_getAttributes(p);
        NSString *ocType  = [NSString stringWithUTF8String:type];
        const char *CName = property_getName(p);
        NSString *ocName  = [NSString stringWithUTF8String:CName];
        [keyTypeDic setObject:ocType forKey:ocName];//属性名称为键，类型为值
        NSString *value   = [self valueForKey:ocName];
        if (![ignore containsObject:ocName] && value) {
            [keyValueDic setObject:value forKey:ocName];
        }
    }
    objc_setAssociatedObject(self, &propertyTypeKey, keyTypeDic, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, &propertyValueKey, keyValueDic, OBJC_ASSOCIATION_COPY);
}


//获取model 转换成字典的键值对
- (NSDictionary *)getKeyValue {
    return objc_getAssociatedObject(self, &propertyValueKey);
}


//获取model 属性名称和属性类型的键值对
- (NSDictionary *)getKeyType {
    return objc_getAssociatedObject(self, &propertyTypeKey);
}


/**
 * model转成json时忽略系统自动添加的属性名称
 */
+ (NSArray *)systemIgnoreProperty {
    return @[@"debugDescription", @"description", @"hash", @"superclass"];
}

@end
