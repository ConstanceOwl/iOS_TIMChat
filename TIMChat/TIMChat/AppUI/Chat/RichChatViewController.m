//
//  RichChatViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/31.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "RichChatViewController.h"

@implementation RichChatViewController


- (void)addInputPanel
{
    _inputView = [[RichChatInputPanel alloc] initRichChatInputPanel];
    _inputView.chatDelegate = self;
    [self.view addSubview:_inputView];
}

@end
