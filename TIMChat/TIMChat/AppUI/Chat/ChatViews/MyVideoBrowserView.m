//
//  MyVideoBrowserView.m
//  MyDemo
//
//  Created by tomzhu on 15/12/8.
//  Copyright © 2015年 sofawang. All rights reserved.
//

#import "MyVideoBrowserView.h"
#import "UIViewAdditions.h"
#import "MyMsgVideoModel.h"
#import "UIResponder+addtion.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MyVideoBrowserView()
@property (nonatomic, strong) MyMsgVideoModel* model;
@property (nonatomic, assign) CGRect fromRect;
@property (nonatomic, strong) MPMoviePlayerController* movie;
@end

@implementation MyVideoBrowserView

- (id)initWithVideoModel:(MyMsgVideoModel *)videoModel fromRect:(CGRect)rect
{
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        self.fromRect = rect;
        self.model = videoModel;
        [self showVideo];
    }
    return self;
}

- (void)showVideo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyNotificationImageViewDisplayChange object:nil userInfo:@{@"DisplayImage":@YES}];
    
    //视频URL
    NSURL *url = [NSURL fileURLWithPath:self.model.videoPath];
    //视频播放对象
    self.movie = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [self.movie prepareToPlay];
    [self addSubview:self.movie.view];
    self.movie.shouldAutoplay=YES;
    [self.movie setControlStyle:MPMovieControlStyleFullscreen];
    [self.movie.view setFrame:self.bounds];
    // 注册一个播放结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.movie];
    
    [self.movie play];
}

-(void)myMovieFinishedCallback:(NSNotification*)notify
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyNotificationImageViewDisplayChange object:nil userInfo:@{@"DisplayImage":@NO}];
    
    //视频播放对象
    MPMoviePlayerController* theMovie = [notify object];
    //销毁播放通知
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:theMovie];
    [theMovie.view removeFromSuperview];
    
    [self removeFromSuperview];
}

@end
