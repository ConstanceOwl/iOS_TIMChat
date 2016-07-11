//
//  MyVideoBrowserView.h
//  MyDemo
//
//  Created by tomzhu on 15/12/8.
//  Copyright © 2015年 sofawang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyMsgVideoModel;

@interface MyVideoBrowserView : UIView
- (id)initWithVideoModel:(MyMsgVideoModel *)videoModel fromRect:(CGRect)rect;
@end
