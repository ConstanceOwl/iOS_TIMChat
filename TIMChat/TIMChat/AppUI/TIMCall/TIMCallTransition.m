//
//  TIMCallTransition.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//


#import "TIMCallTransition.h"

@interface TIMCallTransition ()


@property(nonatomic, strong) id <UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) UIViewController *fromViewController;

@property (nonatomic, strong) UIViewController *toViewController;

@end

@implementation TIMCallTransition

- (void)dealloc
{
    self.transitionContext = nil;
    self.fromViewController = nil;
    self.toViewController = nil;
}

#define kTIMCallGroupAnimDuration           0.6
#define kTIMCallRadiusDuration              0.6

+ (instancetype)transitionWithQSTransitionType:(TIMTransitionType)transitionType presentType:(TIMCallPressentType)presentType
{
    TIMCallTransition *transiton = [[self alloc] init];
    if (transiton)
    {
        transiton.transitionType = transitionType;
        transiton.pressentType = presentType;
    }
    return transiton;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.endRect = CGRectMake(100, 100, 100, 100);
        self.lastPoint = CGPointMake([UIScreen mainScreen].bounds.size.width - 50, [UIScreen mainScreen].bounds.size.height - 90);
        self.controlPoint = CGPointMake(self.lastPoint.x , self.endRect.origin.y + self.endRect.size.height);
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    
    switch (self.transitionType)
    {
        case TIMTransitionTypeDismiss:
        {
            [self animateDismissTransition:transitionContext];
        }
            break;
        case TIMTransitionTypePresent:
        {
            [self animatePresentTransition:transitionContext];
        }
            break;
            
        default:
            break;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
    switch (self.transitionType)
    {
            
        case TIMTransitionTypeDismiss:
        {
            [self animationDismissDidStop:anim finished:flag];
        }
            break;
        case TIMTransitionTypePresent:
        {
            [self animationPresentDidStop:anim finished:flag];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 显示和消失动画

- (void)animatePresentTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UINavigationController *fromNav = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    self.fromViewController = fromNav.viewControllers.lastObject;
    
    // 把新的试图控制器试图添加
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:_toViewController.view];
    
    TIMCallViewController *onlineVC = (TIMCallViewController *)self.toViewController;
    
    switch (self.pressentType)
    {
        case TIMCallTransitionPressentTypeNormal:
        {
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.duration = kTIMCallRadiusDuration;
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -onlineVC.callTopView.bounds.size.height, 0)];
            animation.toValue  = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 0, 0)];
            animation.delegate = self;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            [animation setValue:self.transitionContext forKey:@"transitionContext"];
            [onlineVC.callTopView.layer addAnimation:animation forKey:nil];
            
            
            CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation1.duration = kTIMCallRadiusDuration;
            animation1.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, onlineVC.callBottomView.bounds.size.height , 0)];
            animation1.byValue  = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, - onlineVC.callBottomView.bounds.size.height, 0)];
            animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            [onlineVC.callBottomView.layer addAnimation:animation1 forKey:nil];
            
        }
            break;
        case TIMCallTransitionPressentTypeMask:
        {
            
            TIMCallView *phoneView = [[UIApplication sharedApplication].keyWindow viewWithTag:kTIMCallViewTag];
            // 设置头像图
            phoneView.image = onlineVC.imgIconView.image;
            
            // 先隐藏新试图
            CALayer *maskLayer = [CALayer layer];
            maskLayer.frame = CGRectMake(0, 0, 0, 0);
            onlineVC.view.layer.mask = maskLayer;
            
            CGPoint starPoint = phoneView.center;
            CGPoint endPoint  = phoneView.firstCenter;
            
            CGPoint ancholPoint = CGPointMake(endPoint.x + (starPoint.x - endPoint.x)/2.0, endPoint.y);
            
            UIBezierPath *animPath = [[UIBezierPath alloc] init];
            [animPath moveToPoint:starPoint];
            [animPath addQuadCurveToPoint:endPoint controlPoint:ancholPoint];
            
            
            // 记录下phoneView消失的位置
            onlineVC.lastDismissPoint = starPoint;
            
            CAAnimationGroup *groupAnim = [self groupAnimationWithPath:animPath transform:CATransform3DMakeScale(1.0, 1.0, 1) duratio:kTIMCallGroupAnimDuration];
            
            groupAnim.removedOnCompletion = NO;
            groupAnim.fillMode = kCAFillModeForwards;
            groupAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [groupAnim setValue:self.transitionContext forKey:@"transitionContext"];
            
            [phoneView.layer addAnimation:groupAnim forKey:@"keyAnim"];
        }
            break;
            
        default:
            break;
    }
    
    // 启动波浪动画
    [onlineVC starLayerAnimation];
}

- (void)animateDismissTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UINavigationController *toNav = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.toViewController = toNav.viewControllers.lastObject;
    
    TIMCallViewController *onlineVC = (TIMCallViewController *)self.fromViewController;
    
    // 获取keyWindow
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect currentRect = [window convertRect:onlineVC.imgIconView.frame fromWindow:window];
    self.endRect = currentRect;
    
    
    switch (self.pressentType)
    {
        case TIMCallTransitionPressentTypeNormal:
        {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.duration = kTIMCallRadiusDuration;
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 0, 0)];
            animation.toValue  = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -onlineVC.callTopView.bounds.size.height, 0)];
            animation.delegate = self;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [animation setValue:self.transitionContext forKey:@"transitionContext"];
            [onlineVC.callTopView.layer addAnimation:animation forKey:nil];
            
            
            CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation1.duration = kTIMCallRadiusDuration;
            animation1.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0,0, 0)];
            animation1.byValue  = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0,onlineVC.callBottomView.bounds.size.height, 0)];
            animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation1.removedOnCompletion = NO;
            animation1.fillMode = kCAFillModeForwards;
            
            
            [onlineVC.callBottomView.layer addAnimation:animation1 forKey:nil];
            
            
            [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                onlineVC.view.alpha = 0;
            } completion:nil];
            
        }
            break;
            
        case TIMCallTransitionPressentTypeMask:
        {
            
            /**
             * 画两个圆路径
             */
            
            UIView *containerView = [transitionContext containerView];
            containerView.backgroundColor = [UIColor clearColor];
            // 对角线的一半作为半径
            CGFloat radius = sqrtf(containerView.frame.size.height * containerView.frame.size.height + containerView.frame.size.width * containerView.frame.size.width) / 2;
            
            UIBezierPath *startCycle = [UIBezierPath bezierPathWithArcCenter:containerView.center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            UIBezierPath *endCycle =  [UIBezierPath bezierPathWithOvalInRect:self.endRect];
            
            //创建CAShapeLayer进行遮盖
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.fillColor = [UIColor greenColor].CGColor;
            maskLayer.path = endCycle.CGPath;
            self.fromViewController.view.layer.mask = maskLayer;
            
            //创建路径动画
            CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            maskLayerAnimation.fromValue = (__bridge id)(startCycle.CGPath);
            maskLayerAnimation.toValue = (__bridge id)((endCycle.CGPath));
            maskLayerAnimation.duration = kTIMCallRadiusDuration;
            maskLayerAnimation.delegate = self;
            maskLayerAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [maskLayerAnimation setValue:transitionContext forKey:@"transitionContext"];
            [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
            
        }
            break;
            
        default:
            break;
    }

}

#pragma mark - 显示和消失状态 动画结束

- (void)animationPresentDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // 如果是第一段动画
    if ([anim valueForKey:@"transitionContext"] == self.transitionContext)
    {
        switch (self.pressentType)
        {
            case TIMCallTransitionPressentTypeNormal:
            {
                [self.transitionContext completeTransition:YES];
            }
                break;
            case TIMCallTransitionPressentTypeMask:
            {
                TIMCallView *phoneView = [[UIApplication sharedApplication].keyWindow viewWithTag:kTIMCallViewTag];
                
                phoneView.layer.transform =  CATransform3DMakeScale(1, 1, 1);
                phoneView.center = phoneView.firstCenter;
                [phoneView.layer removeAllAnimations];
                
                UIView *containerView = [self.transitionContext containerView];
                
                /**
                 * 画两个圆路径
                 */
                // 对角线的一半作为半径
                CGFloat radius = sqrtf(containerView.frame.size.height * containerView.frame.size.height + containerView.frame.size.width * containerView.frame.size.width) / 2;
                
                UIBezierPath *endCycle = [UIBezierPath bezierPathWithArcCenter:containerView.center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
                
                UIBezierPath *starCycle =  [UIBezierPath bezierPathWithOvalInRect:phoneView.frame];
                
                //创建CAShapeLayer进行遮盖
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                maskLayer.fillColor = [UIColor greenColor].CGColor;
                maskLayer.path = endCycle.CGPath;
                self.toViewController.view.layer.mask = maskLayer;
                
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
                animation.duration = kTIMCallRadiusDuration;
                animation.fromValue = (__bridge id)starCycle.CGPath;
                animation.toValue   = (__bridge id)endCycle.CGPath;
                animation.delegate = self;
                
                [maskLayer addAnimation:animation forKey:@"path"];
            }
                break;
                
            default:
                break;
        }
        
    }
    else
    {
        
        TIMCallView *phoneView = [[UIApplication sharedApplication].keyWindow viewWithTag:kTIMCallViewTag];
        [phoneView.layer removeAllAnimations];
        [phoneView removeFromSuperview];
        
        [self.transitionContext completeTransition:YES];
        
        self.toViewController.view.layer.mask = nil;
    }
}

- (void)animationDismissDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    TIMCallViewController *onlineVC = (TIMCallViewController *)self.fromViewController;
    
    switch (self.pressentType) {
        case TIMCallTransitionPressentTypeNormal:
        {
            
            [onlineVC.callTopView.layer removeAllAnimations];
            [onlineVC.callBottomView.layer removeAllAnimations];
            [self.transitionContext completeTransition:YES];
            
        }
            break;
            
        case TIMCallTransitionPressentTypeMask:
        {
            // 如果是第一段动画
            if ([anim valueForKey:@"transitionContext"] == self.transitionContext)
            {
                
                TIMCallView *imgPhotoView = [[TIMCallView alloc] initWithReceiver:onlineVC.callReceiver type:onlineVC.isVoice sponsor:onlineVC.isCallSponsor];
            
                imgPhotoView.frame = self.endRect;
                imgPhotoView.firstCenter = imgPhotoView.center;
                imgPhotoView.userInteractionEnabled = YES;
                imgPhotoView.layer.cornerRadius = self.endRect.size.width/2.0;
                imgPhotoView.layer.masksToBounds = YES;
                imgPhotoView.tag = kTIMCallViewTag;
                imgPhotoView.image = [UIImage imageNamed:@"dial_icon"];
                [[UIApplication sharedApplication].keyWindow addSubview:imgPhotoView];
                
                // 轻拍事件、拖动事件请在TIMCallView中查看
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:imgPhotoView action:@selector(panPhoneView:)];
                [imgPhotoView addGestureRecognizer:pan];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:imgPhotoView action:@selector(tapPhoneView:)];
                [imgPhotoView addGestureRecognizer:tap];
                
                
                [self.transitionContext completeTransition:YES];
                [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
                
                CGPoint starPoint = CGPointMake(self.endRect.origin.x + self.endRect.size.width / 2.0, self.endRect.origin.y + self.endRect.size.height / 2.0);
                
                CGPoint endPoint = onlineVC.lastDismissPoint;
                
                CGPoint ancholPoint = CGPointMake(starPoint.x + (endPoint.x - starPoint.x)/2.0, starPoint.y);
                
                UIBezierPath *animPath = [[UIBezierPath alloc] init];
                [animPath moveToPoint:starPoint];
                [animPath addQuadCurveToPoint:endPoint controlPoint:ancholPoint];
                
                CAAnimationGroup *groupAnim = [self groupAnimationWithPath:animPath transform:CATransform3DMakeScale(0.8, 0.8, 1) duratio:kTIMCallGroupAnimDuration];
                groupAnim.removedOnCompletion = NO;
                groupAnim.fillMode = kCAFillModeForwards;
                
                [imgPhotoView.layer addAnimation:groupAnim forKey:@"keyAnim"];
                
                onlineVC.callFloatView = imgPhotoView;
                
            }
            else
            {
                
                UIImageView *imgView = [[UIApplication sharedApplication].keyWindow viewWithTag:kTIMCallViewTag];
                [imgView.layer removeAllAnimations];
                imgView.center = onlineVC.lastDismissPoint;
                imgView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1);
            }
            
        }
            break;
            
        default:
            break;
    }

}

#pragma mark - 动画组

- (CAAnimationGroup *)groupAnimationWithPath:(UIBezierPath *)path transform:(CATransform3D)transform duratio:(CFTimeInterval)duration
{
    
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyAnimation.path = path.CGPath;

    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnim.toValue = [NSValue valueWithCATransform3D:transform];
    
    CAAnimationGroup *groupAnim = [CAAnimationGroup animation];
    groupAnim.animations = @[keyAnimation, rotationAnim];
    
    groupAnim.delegate = self;
    groupAnim.duration = duration;
    
    groupAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    return groupAnim;
}

@end
