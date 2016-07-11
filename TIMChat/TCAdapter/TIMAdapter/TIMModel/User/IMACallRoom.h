//
//  IMACallRoom.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/7.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMABase.h"

@interface IMACallRoom : IMABase<AVRoomAble>

@property (nonatomic, copy) NSString *callGroupID;
@property (nonatomic, copy) NSString *callGroupType;
@property (nonatomic, copy) NSString *callRoomTitle;
@property (nonatomic, strong) IMAUser *callSponsor;
@property (nonatomic, assign) int callRoomID;


@end
