# iOS TIMChat(支持电话场景版本---还在开发ing)
因外部用户反馈需要电话场景示例，现将IMSDK示例TIMChat上集成TCAdapter进行电话场景开发，目前此版本仍在开发中。
此处代码只给电话场景用户作参考，不是最终Release的稳定版本；

已知问题：

1.只支持前台呼叫，不支持APNS,VOIP等；

2.逻辑功能上未处理电话消息在消息列表中的显示问题（显示会有错乱）；

3.群电话时，缺少音频只支持6路问题的处理逻辑；

因GitHub有文件大小限制，将IMSDK以及AVSDK上传到腾讯云COS上。
更新时，请到对应的地址进行更新，并添加到工程下面对应的目录下

IMSDK : http://tcshowsdks-10022853.cos.myqcloud.com/20160629/IMSDK.zip 下载后解压，然后再放至对应放到工程目录  TIMChat/TCAdapter/TIMAdapter/Framework/IMSDK

AVSDK : http://tcshowsdks-10022853.cos.myqcloud.com/20160629/Libs.zip  下载后解压，然后再放至对应放到工程目录  TIMChat/TCAdapter/TCAVIMAdapter/Libs

TIMChat电话场景版本，跟随心播一样，处理了大量的异常情况，请开发者在编码过程中注意;
更多文档信息请参考：https://github.com/zhaoyang21cn/iOS_Suixinbo

##TIMChat电话场景版本的Spear的配置
因电话场景中，通话各方，都支持开麦与开摄像头，所以配置均为同一个
![spear配置](https://raw.githubusercontent.com/zhaoyang21cn/iOS_Suixinbo/master/LiveHost.jpeg)
