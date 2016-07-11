//
//  ChatViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/23.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "ChatViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "MyChatToolBarView.h"
#import "MyUIDefine.h"
#import "MyMoreView.h"

@interface ChatViewController ()

@property (nonatomic, strong) MyChatToolBarView *toolBar;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation ChatViewController


- (void)dealloc
{
    [_receiverKVO unobserveAll];
}

- (instancetype)initWith:(IMAUser *)user
{
    if (self = [super init])
    {
        _receiver = user;
    }
    return self;
}

- (void)addHeaderView
{
    self.headerView = [[ChatHeadRefreshView alloc] init];
}

- (void)onRefresh
{
    __weak ChatViewController *ws = self;
    [_conversation asyncLoadRecentMessage:10 completion:^(NSArray *imamsgList, BOOL succ) {
        if (succ)
        {
            [ws onLoadRecentMessage:imamsgList complete:YES scrollToBottom:NO];
        }
        
        [ws refreshCompleted];
        [ws layoutHeaderRefreshView];
    }];
}


- (void)addFooterView
{
    // 作空实现
}

- (void)addOwnViews
{
    [super addOwnViews];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = kClearColor;
    _tableView.sectionFooterHeight = 0.f;
    
    [self addChatToolBar];
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    longPressGr.minimumPressDuration = 1.0;
    [_tableView addGestureRecognizer:longPressGr];
    
    
    
}

-(void)onLongPress:(UILongPressGestureRecognizer *)gesture
{
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.tableView];
        
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        UITableViewCell<TIMElemAbleCell> *cell = [_tableView cellForRowAtIndexPath:indexPath];
        BOOL showMenu = [cell canShowMenu];
        
        if (showMenu)
        {
            if ([cell canShowMenuOnTouchOf:gesture])
            {
                [cell showMenu];
            }
        }
    }
}


- (void)addChatToolBar
{
    CGFloat kToolbarY = CGRectGetMaxY(self.view.bounds) - CHAT_BAR_MIN_H - 2*CHAT_BAR_VECTICAL_PADDING;
    
    _toolbar = [[MyChatToolBarView alloc] initWithFrame:CGRectMake(0, kToolbarY, CGRectGetWidth(self.view.bounds), CHAT_BAR_MIN_H+2*CHAT_BAR_VECTICAL_PADDING) chatType:[_conversation type]];
    _toolbar.delegate = self;
    [self.view addSubview:_toolbar];
    [(MyMoreView *)_toolbar.moreView setDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configWithUser:_receiver];
    
    UITapGestureRecognizer* tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard)];
    [self.tableView addGestureRecognizer:tapAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)configWithUser:(IMAUser *)user
{
    [_receiverKVO unobserveAll];
    
    _receiver = user;
    __weak ChatViewController *ws = self;
    
    _receiverKVO = [FBKVOController controllerWithObserver:self];
    
    [_receiverKVO observe:_receiver keyPaths:@[@"remark", @"nickName"] options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [ws setChatTitle];
    }];
    
    if (_conversation)
    {
        [_conversation releaseConversation];
        _messageList = nil;
        [self reloadData];
    }
    
    _conversation = [[IMAPlatform sharedInstance].conversationMgr chatWith:user];
    _messageList = _conversation.msgList;
    
    [_conversation asyncLoadRecentMessage:5 completion:^(NSArray *imamsgList, BOOL succ) {
        [ws onLoadRecentMessage:imamsgList complete:succ scrollToBottom:YES];
    }];
    
    _conversation.receiveMsg = ^(NSArray *imamsgList, BOOL succ) {
        [ws onReceiveNewMsg:imamsgList succ:succ];
    };
    
    
    
    [self addChatSettingItem];
    
    
    [self setChatTitle];
    
    // 同步群资料
    if ([user isGroupType])
    {
        [((IMAGroup *)user) asyncUpdateGroupInfo:nil fail:nil];
    }
}

- (void)setChatTitle
{
    NSString *title = [_receiver showTitle];
    if (title.length > 10)
    {
        title = [NSString stringWithFormat:@"%@...", [title substringToIndex:10]];
    }
    self.title = title;
}

- (void)onReceiveNewMsg:(NSArray *)imamsgList succ:(BOOL)succ
{
    [_tableView beginUpdates];
    
    NSInteger count = [imamsgList count];
    NSMutableArray *indexArray = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++)
    {
        NSInteger idx = _messageList.count + i - count;
        NSIndexPath *index = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexArray addObject:index];
    }
    
    [_tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateOnSendMessage:imamsgList succ:YES];
    });
}


- (void)onLoadRecentMessage:(NSArray *)imamsgList complete:(BOOL)succ scrollToBottom:(BOOL)scroll
{
    if (succ)
    {
        if (imamsgList.count > 0)
        {
            [_tableView beginUpdates];
            
            NSMutableArray *ar = [NSMutableArray array];
            for (NSInteger i = 0; i < imamsgList.count; i++)
            {
                [ar addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            
            [_tableView insertRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationTop];
            
            [_tableView endUpdates];
            
            if (scroll)
            {
                //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSIndexPath *last = [NSIndexPath indexPathForRow:[_messageList count] - 1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                //                });
            }
        }
    }
}

- (void)layoutRefreshScrollView
{
    CGFloat kToolbarY = CGRectGetMaxY(self.view.bounds) - CHAT_BAR_MIN_H - 2*CHAT_BAR_VECTICAL_PADDING;
    // do nothing
    _tableView.frame = CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds), CGRectGetWidth(self.view.bounds), kToolbarY);
    _toolbar.frame = CGRectMake(0, kToolbarY, CGRectGetWidth(self.view.bounds), CHAT_BAR_MIN_H+2*CHAT_BAR_VECTICAL_PADDING);
}


- (void)addChatSettingItem
{
    BOOL isUser = [_receiver isC2CType];
    
    UIImage *call = [UIImage imageNamed:@"call_baricon"];
    
    UIButton *callbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [callbtn setImage:call forState:UIControlStateNormal];
    [callbtn setImage:call forState:UIControlStateHighlighted];
    [callbtn addTarget:self action:@selector(onClickCall) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *callBar = [[UIBarButtonItem alloc] initWithCustomView:callbtn];
    
    UIImage *norimage =  isUser ? [UIImage imageNamed:@"person"] :  [UIImage imageNamed:@"group"];
    UIImage *higimage =  isUser ? [UIImage imageNamed:@"person_hover"] :  [UIImage imageNamed:@"group_hover"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn setImage:norimage forState:UIControlStateNormal];
    [btn setImage:higimage forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onClickChatSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = @[bar, callBar];
}

- (void)onClickCall
{
    if ([IMAPlatform sharedInstance].callViewController)
    {
        [[HUDHelper sharedInstance] tipMessage:@"正在通话中"];
        return;
    }
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    [sheet bk_addButtonWithTitle:@"语音电话" handler:^{
        [[AppDelegate sharedAppDelegate] presentCallViewControllerWith:_receiver type:YES callMsgHandler:self];
    }];
    
    [sheet bk_addButtonWithTitle:@"视频电话" handler:^{
        [[AppDelegate sharedAppDelegate] presentCallViewControllerWith:_receiver type:NO callMsgHandler:self];
    }];
    
    [sheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [sheet showInView:self.view];
}

- (void)onClickChatSetting
{
    //如果是创建群，直接进入聊天界面时，_receiver是临时创建的群，这里需要在ongroupAdd之后，重新获取一次详细群信息
    IMAGroup *group = [[IMAGroup alloc] initWith:_receiver.userId];
    NSInteger index = [[IMAPlatform sharedInstance].contactMgr.groupList indexOfObject:group];
    if (index >= 0 && index < [IMAPlatform sharedInstance].contactMgr.groupList.count)
    {
        _receiver = [[IMAPlatform sharedInstance].contactMgr.groupList objectAtIndex:index];
    }
    
    if ([_receiver isC2CType])
    {
        IMAUser *user = (IMAUser *)_receiver;
        if ([[IMAPlatform sharedInstance].contactMgr isMyFriend:user])
        {
            FriendProfileViewController *vc = [[FriendProfileViewController alloc] initWith:user];
            [[AppDelegate sharedAppDelegate] pushViewController:vc withBackTitle:@"返回"];
        }
        else
        {
            StrangerProfileViewController *vc = [[StrangerProfileViewController alloc] initWith:user];
            [[AppDelegate sharedAppDelegate] pushViewController:vc withBackTitle:@"返回"];
        }
    }
    else if ([_receiver isGroupType])
    {
        IMAGroup *user = (IMAGroup *)_receiver;
        
        if ([user isPublicGroup])
        {
            
            GroupProfileViewController *vc = [[GroupProfileViewController alloc] initWith:user];
            [[AppDelegate sharedAppDelegate] pushViewController:vc withBackTitle:@"返回"];
        }
        else if ([user isChatGroup])
        {
            ChatGroupProfileViewController *vc = [[ChatGroupProfileViewController alloc] initWith:user];
            [[AppDelegate sharedAppDelegate] pushViewController:vc withBackTitle:@"返回"];
        }
        else if ([user isChatRoom])
        {
            ChatRoomProfileViewController *vc = [[ChatRoomProfileViewController alloc] initWith:user];
            [[AppDelegate sharedAppDelegate] pushViewController:vc withBackTitle:@"返回"];
        }
        else
        {
            // do nothing
        }
        
    }
}

// 加载历史信息
- (void)loadHistotyMessages
{
    
}

// 添加收到的信息
- (void)appendReceiveMessage
{
    
}

///==========================
#pragma mark - MyChatToolBarViewDelegate

- (void)updateOnSendMessage:(NSArray *)msglist succ:(BOOL)succ
{
    if (msglist.count)
    {
        
        NSInteger index = [_messageList indexOfObject:msglist.lastObject];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
- (void)sendMsg:(IMAMsg *)msg
{
    [self sendMsg:msg completion:nil];
}

- (void)sendMsg:(IMAMsg *)msg completion:(CommonFinishBlock)block
{
    if (msg)
    {
        [_tableView beginUpdates];
        
        __weak ChatViewController *ws = self;
        NSArray *newaddMsgs = [_conversation sendMessage:msg completion:^(NSArray *imamsglist, BOOL succ) {
            [ws updateOnSendMessage:imamsglist succ:succ];
            if (block)
            {
                block(succ);
            }
        }];
        
        NSMutableArray *array = [NSMutableArray array];
        for (IMAMsg *msg in newaddMsgs)
        {
            NSInteger idx = [_messageList indexOfObject:msg];
            NSIndexPath *index = [NSIndexPath indexPathForRow:idx inSection:0];
            [array addObject:index];
        }
        
        [_tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:_messageList.count - 1 inSection:0];
        [_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        //        });
    }
}

- (void)sendText:(NSString *)text
{
    if (text && text.length > 0)
    {
        IMAMsg *msg = [IMAMsg msgWithText:text];
        [self sendMsg:msg];
    }
}
- (void)didChangeToolBarHight:(CGFloat)toHeight
{
    __weak ChatViewController* weakself = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = weakself.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = weakself.view.frame.size.height - toHeight;
        weakself.tableView.frame = rect;
        [weakself.toolBar updateEmoj];
    }];
    
    if (_tableView.contentSize.height > _tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height);
        [_tableView setContentOffset:offset animated:YES];
    }
}
- (void)sendAudioRecord:(AudioRecord *)audio
{
    IMAMsg *msg = [IMAMsg msgWithSound:audio.audioData duration:audio.duration];
    [self sendMsg:msg];
}

//===========================

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil)
    {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (void)sendImage:(UIImage *)image orignal:(BOOL)orignal
{
    if (image)
    {
        IMAMsg *msg = [IMAMsg msgWithImage:image isOrignal:orignal];
        [self sendMsg:msg];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info[UIImagePickerControllerOriginalImage] fixOrientation];
        NSData *data = UIImagePNGRepresentation(image);
        
        if(data.length > 28 * 1024 * 1024)
        {
            [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
            return;
        }
        
        ImageThumbPickerViewController *vc = [[ImageThumbPickerViewController alloc] initWith:image];
        __weak ChatViewController *ws = self;
        vc.sendImageBlock = ^ (ImageThumbPickerViewController *svc, BOOL isOrignal) {
            [ws sendImage:svc.showImage orignal:isOrignal];
            ws.imagePicker = nil;
            
        };
        [picker pushViewController:vc animated:YES];
        
        
    }
    else if([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
        if (self.imagePicker.mediaTypes.count == 2)
        {
            NSURL *url = info[UIImagePickerControllerMediaURL];
            NSError *err = nil;
            NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&err];
            if(data.length < 28 * 1024 * 1024)
            {
                //文件最大不超过28MB
                IMAMsg *msg = [IMAMsg msgWithFilePath:url];
                [self sendMsg:msg];
            }
            else
            {
                [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
            }
        }
        //        else
        //        {
        //                NSURL *url = info[UIImagePickerControllerMediaURL];
        //                NSError *err;
        //                NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&err];
        //
        //                NSFileManager *fileManager = [NSFileManager defaultManager];
        //
        //                NSString *nsTmpDIr = NSTemporaryDirectory();
        //                NSString *videoPath = [NSString stringWithFormat:@"%@uploadVideoFile%3.f.%@", nsTmpDIr, [NSDate timeIntervalSinceReferenceDate], @"mp4"];
        //                BOOL isDirectory;
        //
        //                if ([fileManager fileExistsAtPath:videoPath isDirectory:&isDirectory])
        //                {
        //                    if (![fileManager removeItemAtPath:nsTmpDIr error:&err])
        //                    {
        //                        TDDLogEvent(@"Upload Image Failed: same upload filename: %@", err);
        //                        return;
        //                    }
        //                }
        //                NSString *snapshotPath = [NSString stringWithFormat:@"%@uploadSnapshotFile%3.f", nsTmpDIr, [NSDate timeIntervalSinceReferenceDate]];
        //                if ([fileManager fileExistsAtPath:snapshotPath isDirectory:&isDirectory]) {
        //                    if (![fileManager removeItemAtPath:nsTmpDIr error:&err]) {
        //                        TDDLogEvent(@"Upload Image Failed: same upload filename: %@", err);
        //                        return;
        //                    }
        //                }
        //
        //                AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        //                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
        //                imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
        //                CMTime time = CMTimeMakeWithSeconds(1.0, 30);   // 1.0为截取视频1.0秒处的图片，30为每秒30帧
        //                CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:nil error:nil];
        //                UIImage *image = [UIImage imageWithCGImage:cgImage];
        //
        //                [self convertToMP4:urlAsset videoPath:videoPath succ:^{
        //                    UIGraphicsBeginImageContext(CGSizeMake(240, 320));
        //                    // 绘制改变大小的图片
        //                    [image drawInRect:CGRectMake(0,0, 240, 320)];
        //                    // 从当前context中创建一个改变大小后的图片
        //                    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
        //                    // 使当前的context出堆栈
        //                    UIGraphicsEndImageContext();
        //                    NSData *snapshotData = UIImageJPEGRepresentation(scaledImage, 0.75);
        //                    if (![fileManager createFileAtPath:snapshotPath contents:snapshotData attributes:nil]) {
        //                        TDDLogEvent(@"Upload Image Failed: fail to create uploadfile: %@", err);
        //                        return;
        //                    }
        //
        //                    MyMsgVideoModel* model = [[MyMsgVideoModel alloc] init];
        //                    model.videoPath = videoPath;
        //                    model.videoType = @"mp4";
        //                    model.duration = urlAsset.duration.value/urlAsset.duration.timescale;
        //                    model.snapshotPath = snapshotPath;
        //                    model.snapshotType = @"kTypeSnapshot";
        //                    model.width = scaledImage.size.width;
        //                    model.height = scaledImage.size.height;
        //
        //                    TIMVideoElem* elem = [[TIMVideoElem alloc] init];
        //                    TIMVideo* video = [[TIMVideo alloc] init];
        //                    TIMSnapshot* snapshot = [[TIMSnapshot alloc] init];
        //                    elem.video = video;
        //                    elem.snapshot = snapshot;
        //                    elem.videoPath = videoPath;
        //                    elem.snapshotPath = snapshotPath;
        //
        //                    video.type = model.videoType;
        //                    video.duration = model.duration;
        //                    snapshot.type = model.snapshotType;
        //                    snapshot.width = model.width;
        //                    snapshot.height = model.height;
        //
        //                    model.elem = elem;
        //
        //                    // NSLog(@"filename = %@",[url pathComponents].lastObject);
        //                    model.inMsg = NO;
        //                    [self performSelectorOnMainThread:@selector(sendVideoMessage:) withObject:model waitUntilDone:NO];
        //                } fail:^{
        //                    [fileManager removeItemAtPath:videoPath error:nil];
        //                }];
        //        }
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

//===========================


#pragma mark - moreView
-(void)hiddenKeyBoard
{
    [_toolbar endEditing:YES];
}

#pragma mark - MyMoreViewDelegate
- (void)moreViewPhotoAction
{
    // 隐藏键盘
    [self hiddenKeyBoard];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}
- (void)moreViewCameraAction
{
    [self hiddenKeyBoard];
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self.imagePicker setEditing:YES];
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied)
        {
            // 没有权限
            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" cancel:@"确定"];
            return;
        }
    }
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)moreViewFileAction
{
    // 隐藏键盘，只能选择图片或视频文件
    [self hiddenKeyBoard];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)moreVideVideoAction
{
    CGFloat selfWidth  = self.view.bounds.size.width;
    CGFloat selfHeight = self.view.bounds.size.height;
    MicroVideoView *microVideoView = [[MicroVideoView alloc] initWithFrame:CGRectMake(0, selfHeight/3, selfWidth, selfHeight * 2/3)];
    microVideoView.delegate = self;
    [self.view addSubview:microVideoView];
    //    [self hiddenKeyBoard];
    //    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //    self.imagePicker.videoMaximumDuration = 10.0f; // 10 seconds
    //    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    //    [self.imagePicker setEditing:YES];
    //
    //    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)])
    //    {
    //        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    //        if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied)
    //        {
    //            // 没有权限
    //            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" cancel:@"确定"];
    //            return;
    //        }
    //    }
    //    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    [super scrollViewWillBeginDragging:scrollView];
//    [self hiddenKeyBoard];
//}

- (void)touchUpDone:(NSString *)savePath
{
    NSError *err = nil;
    NSData* data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:savePath] options:NSDataReadingMappedIfSafe error:&err];
    if(data.length < 28 * 1024 * 1024)
    {
        //文件最大不超过28MB
        IMAMsg *msg = [IMAMsg msgWithVideoPath:savePath];
        [self sendMsg:msg];
    }
    else
    {
        [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMAMsg *msg = [_messageList objectAtIndex:indexPath.row];
    return [msg heightInWidth:tableView.bounds.size.width inStyle:_conversation.type == TIM_GROUP];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messageList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMAMsg *msg = [_messageList objectAtIndex:indexPath.row];
    UITableViewCell<TIMElemAbleCell> *cell = [msg tableView:tableView style:[_receiver isC2CType] ? TIMElemCell_C2C : TIMElemCell_Group];
    [cell configWith:msg];
    return cell;
}

#pragma mark- BaseCell deleteCell
//- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell<TIMElemAbleCell> *cell = [tableView cellForRowAtIndexPath:indexPath];
//    BOOL showMenu = [cell canShowMenu];
//    if (showMenu)
//    {
//        [cell showMenu];
//    }
//    return showMenu;
//}
//
//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    UITableViewCell<TIMElemAbleCell> *cell = [tableView cellForRowAtIndexPath:indexPath];
//    BOOL can = [cell canPerformAction:action withSender:sender];
//    return can;
//}
//
//- (void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    // do nothing
//}
//


- (void)sendCallMsg:(AVIMCMD *)callCmd finish:(CommonFinishBlock)block
{
    if (callCmd.msgType >= AVIMCMD_Call && callCmd.msgType <= AVIMCMD_Call_AllCount)
    {
        if (callCmd.msgType == AVIMCMD_Call_Dialing || callCmd.msgType == AVIMCMD_Call_Disconnected)
        {
            IMAMsg *msg = [IMAMsg msgWithCall:callCmd];
            
            [self sendMsg:msg completion:block];
        }
        else
        {
            IMAMsg *msg = [IMAMsg msgWithCall:callCmd];
            [_conversation sendOnLineMessage:msg completion:^(NSArray *imamsgList, BOOL succ) {
                if (block)
                {
                    block(succ);
                }
            }];
        }
    }
}

@end
