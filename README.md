# ModelToXML
iOS 模型数据转xml数据格式


1.NSObject+NewModelToXML 是核心转换方法类。主要思想是识别出当前属性是何种类型，然后利用递归遍历到最基本的可支持KVC设置的属性。
2.ModelToXMLManager 是一管理NSObject+NewModelToXML 的入口。支持封装添加xml头信息的方法。
3.支持设置忽略需要转换的属性和修改rootName节点名称
