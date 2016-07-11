//
//  IMALoginParam.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <ImSDK/ImSDK.h>


@interface TIMLoginParam (PlatformConfig)

// 因demo无后台服服器，临时做法
// 通时当时时间距 20160601的时间差 ＊ 100 + rand%100 作房间号
// 使用时分配, 分配后，同一帐号在本地手机使用同一AVRoomID
+ (int)generateAVCallRoomID;
- (int)avCallRoomID;

- (IMAPlatformConfig *)config;
- (void)saveToLocal;

@end

@interface IMALoginParam : TIMLoginParam

@property (nonatomic, assign) NSInteger tokenTime;              // 时间戮
@property (nonatomic, strong) IMAPlatformConfig *config;        // 用户对应的配置
@property (nonatomic, assign) int avCallRoomID;


+ (instancetype)loadFromLocal;



// 保存至本地
- (void)saveToLocal;

// 是否过期
- (BOOL)isExpired;

// 是否有效
- (BOOL)isVailed;

@end
