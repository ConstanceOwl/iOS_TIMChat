//
//  ChatInputPanel.h
//  TIMChat
//
//  Created by AlexiChen on 16/3/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatInputPanel : ChatInputBaseView<ChatInputToolBarDelegate>
{
@protected
    ChatInputToolBar                    *_toolBar;
@protected
    __weak UIView<ChatInputAbleView>           *_panel;
    
@protected
    UIView<ChatInputAbleView>           *_emojPanel;
    UIView<ChatInputAbleView>           *_funcPanel;
}

- (instancetype)initRichChatInputPanel;

@end


@interface RichChatInputPanel : ChatInputPanel

@end
