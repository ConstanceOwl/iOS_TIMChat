//
//  TIMCallBeautyView.h
//  live
//
//  Created by AlexiChen on 16/2/25.
//  Copyright © 2016年 kenneth. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^TIMCallBeautyChanged)(CGFloat beauty);

@interface TIMCallBeautyView : UIView
{
@protected
    UIView   *_clearBg;
    UIView   *_sliderBack;
    UISlider *_slider;
}

@property (nonatomic, readonly) UISlider *slider;


@property (nonatomic, copy) TIMCallBeautyChanged changeCompletion;
@property (nonatomic, copy) CommonVoidBlock dismissBlock;

- (void)setBeauty:(CGFloat)beauty;

@end
