//
//  CCVideoPlayerViewController.m
//  CCVideoPlayerKit
//
//  Created by 陈 爱彬 on 14-7-16.
//  Copyright (c) 2014年 陈爱彬. All rights reserved.
//

#import "CCVideoPlayerViewController.h"
#import "MBProgressHUD.h"

static CGFloat const kBarHiddenAnmationDuration = 5.f;
static CGFloat const kTopViewHeight = 75.f;
static CGFloat const kBottomViewHeight = 40.f;

#define IOS7Version ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
#define UIImageWithName(imageName) [UIImage imageNamed:imageName]
#define CCRGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]

@interface CCVideoPlayerViewController ()

@property (nonatomic,assign) CGFloat changeOffset;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) NSMutableArray *itemTimeList;
@property (nonatomic) CGFloat movieLength;

@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) UILabel *titleLable;

@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *playBtn;

@property (nonatomic,strong) UIView *loadingView;
@property (nonatomic,strong) UIActivityIndicatorView *loadingIndicatorView;

@property (nonatomic,strong) UISlider *movieProgressSlider;
@property (nonatomic,strong) UILabel *currentLable;

@property (nonatomic,weak) id timeObserver;
@property (nonatomic,assign) BOOL isMovieFinishedLoading;
@property (nonatomic,strong) MBProgressHUD *progressHud;


@end

@implementation CCVideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark -
#pragma mark 初始化
- (instancetype)initNetworkVideoPlayerViewControllerWithURL:(NSURL *)url videoTitle:(NSString *)movieTitle
{
    self = [super init];
    if (self) {
        _isPlaying = YES;
        _videoURL = url;
        _videoTitle = movieTitle;
        _itemTimeList = [[NSMutableArray alloc]initWithCapacity:5];
        _mode = CCVideoPlayerViewControllerModeNetwork;

    }
    return self;
}

- (instancetype)initLocalVideoPlayerViewControllerWithURL:(NSURL *)url videoTitle:(NSString *)movieTitle
{
    self = [super init];
    if (self) {
        _isPlaying = YES;
        _videoURL = url;
        _videoTitle = movieTitle;
        _itemTimeList = [[NSMutableArray alloc]initWithCapacity:5];
        _mode = CCVideoPlayerViewControllerModeLocal;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    [self createVideoTopView];
    [self createVideoBottomView];
    [self createMovieLoadingView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark 视图创建
//创建顶部条
- (void)createVideoTopView
{
    CGFloat titleLableWidth = 400;
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, kTopViewHeight)];
    _topView.backgroundColor = [UIColor clearColor];
    
    UIImageView *_shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_topView.frame), CGRectGetHeight(_topView.frame))];
    _shadowImageView.image = UIImageWithName(@"player_topshadow.png");
    [_topView addSubview:_shadowImageView];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(0, 5, 54, 64);
    [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 5, 10, 5)];
    [_backBtn setImage:UIImageWithName(@"player_close.png") forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_backBtn];
    
    _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.height/2 - titleLableWidth/2, 0, titleLableWidth, kTopViewHeight)];
    _titleLable.backgroundColor = [UIColor clearColor];
    _titleLable.text = _videoTitle;
    _titleLable.textColor = [UIColor whiteColor];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:_titleLable];
    
    [self.view addSubview:_topView];
}
//创建底部条
- (void)createVideoBottomView
{
    CGRect bounds = self.view.bounds;
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, bounds.size.width - kBottomViewHeight, bounds.size.height, kBottomViewHeight)];
    _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn.frame = CGRectMake(5, 0, 40, 40);
    [_playBtn setImage:[UIImage imageNamed:@"player_pause.png"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(pauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_playBtn];
    
    _currentLable = [[UILabel alloc]initWithFrame:CGRectMake(50 , 22, bounds.size.height - 60, 20)];
    _currentLable.font = [UIFont systemFontOfSize:12];
    _currentLable.textColor = [UIColor whiteColor];
    _currentLable.backgroundColor = [UIColor clearColor];
    _currentLable.textAlignment = NSTextAlignmentRight;
    [_bottomView addSubview:_currentLable];
    
    _movieProgressSlider = [[UISlider alloc]initWithFrame:CGRectMake(50, 10, bounds.size.height - 60, 20)];
    [_movieProgressSlider setMinimumTrackTintColor:[UIColor redColor]];
    [_movieProgressSlider setMaximumTrackTintColor:[UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f]];
    [_movieProgressSlider setThumbImage:[UIImage imageNamed:@"player_thumb.png"] forState:UIControlStateNormal];
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown];
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
    [_bottomView addSubview:_movieProgressSlider];
    
    [self.view addSubview:_bottomView];
}
//创建视频加载视图
- (void)createMovieLoadingView
{
    CGRect bounds = self.view.bounds;
    _loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, bounds.size.width - kBottomViewHeight, bounds.size.height, kBottomViewHeight)];
    _loadingView.backgroundColor = CCRGBCOLOR(30, 30, 30);
    
    //UIActivityIndicatorView视图
    _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _loadingIndicatorView.center = CGPointMake(CGRectGetMidX(_loadingView.frame) - 80, kBottomViewHeight * 0.5);
    [_loadingIndicatorView startAnimating];
    [_loadingView addSubview:_loadingIndicatorView];
    
    UILabel *_loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(100 , 0, bounds.size.height - 200, kBottomViewHeight)];
    _loadingLabel.font = [UIFont systemFontOfSize:14];
    _loadingLabel.textColor = [UIColor whiteColor];
    _loadingLabel.backgroundColor = [UIColor clearColor];
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    _loadingLabel.text = @"视频正在加载中...";
    [_loadingView addSubview:_loadingLabel];
    
    [self.view addSubview:_loadingView];
}
//移除加载视图
- (void)removeMovieLoadingView
{
    [_loadingView removeFromSuperview];
    self.loadingIndicatorView = nil;
    self.loadingView = nil;
    //显示底部视图
    _bottomView.hidden = NO;
}
//隐藏顶部及底部条视图
- (void)hideVideoControlBar
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect topFrame = _topView.frame;
        CGRect bottomFrame = _bottomView.frame;
        topFrame.origin.y = - (kTopViewHeight + self.changeOffset);
        bottomFrame.origin.y = self.view.frame.size.width;
        _topView.frame = topFrame;
        _bottomView.frame = bottomFrame;
    }];
}
#pragma mark -
#pragma mark 播放器创建及加载监听
- (void)createAvPlayer
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    CGRect playerFrame = CGRectMake(0, 0, self.view.layer.bounds.size.width, self.view.layer.bounds.size.height);
//    NSLog(@"frame:%@",NSStringFromCGRect(self.view.layer.bounds));
    
    __block CMTime totalTime = CMTimeMake(0, 0);
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
    totalTime.value += playerItem.asset.duration.value;
    totalTime.timescale = playerItem.asset.duration.timescale;
    [_itemTimeList addObject:[NSNumber numberWithDouble:((double)playerItem.asset.duration.value/totalTime.timescale)]];
    
    _movieLength = (CGFloat)totalTime.value/totalTime.timescale;
    _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:_videoURL]];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = playerFrame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    
    [_player play];
    
    //注册检测视频加载状态的通知
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    __weak typeof(_player) player_ = _player;
    __weak typeof(_movieProgressSlider) movieProgressSlider_ = _movieProgressSlider;
    __weak typeof(_currentLable) currentLable_ = _currentLable;
    typeof(_movieLength) *movieLength_ = &_movieLength;

    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(3, 30) queue:NULL usingBlock:^(CMTime time){
        //获取当前时间
        CMTime currentTime = player_.currentItem.currentTime;
        double currentPlayTime = (double)currentTime.value/currentTime.timescale;
        
        //转成秒数
        CGFloat totalTime = (*movieLength_);
        movieProgressSlider_.value = currentPlayTime/(*movieLength_);
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:currentPlayTime];
        NSDate *totalDate = [NSDate dateWithTimeIntervalSince1970:totalTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        [formatter setDateFormat:(currentPlayTime/3600>=1)? @"h:mm:ss":@"mm:ss"];
        NSString *currentTimeStr = [formatter stringFromDate:currentDate];
        [formatter setDateFormat:(totalTime/3600>=1)? @"h:mm:ss":@"mm:ss"];
        NSString *totalTimeStr = [formatter stringFromDate:totalDate];
        
        currentLable_.text = [NSString stringWithFormat:@"%@ / %@",currentTimeStr,totalTimeStr];
    }];
    _progressHud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:_progressHud];
    [_progressHud show:YES];

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            self.isMovieFinishedLoading = YES;
            //视频加载完成,去掉等待
            [self removeMovieLoadingView];
            [_progressHud hide:YES];
            //隐藏顶部及底部条
            [self performSelector:@selector(hideVideoControlBar) withObject:nil afterDelay:kBarHiddenAnmationDuration];
        }else if (playerItem.status == AVPlayerStatusFailed){
            //TODO:视频加载失败
            NSLog(@"视频加载失败:%@",playerItem.error);
        }
    }
}
//视频播放到结尾
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self popView];
}
#pragma mark -
#pragma mark 视频加载，播放，暂停逻辑
//开始加载视频
- (void)startLoadMovie
{
    [self createAvPlayer];
    [self.view bringSubviewToFront:_topView];
    [self.view bringSubviewToFront:_bottomView];
    [self.view bringSubviewToFront:_loadingView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}
- (void)becomeActive
{
    [self pauseBtnClick];
}
- (void)resignActive
{
    [self pauseBtnClick];
}
//播放/暂停视频
- (void)pauseBtnClick
{
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
        [_player play];
        [_playBtn setImage:[UIImage imageNamed:@"player_pause.png"] forState:UIControlStateNormal];
        
    }else{
        [_player pause];
        [_playBtn setImage:[UIImage imageNamed:@"player_play.png"] forState:UIControlStateNormal];
    }
}
//返回
- (void)popView
{
    [_player removeTimeObserver:_timeObserver];
    [_player replaceCurrentItemWithPlayerItem:nil];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.timeObserver = nil;
        self.player = nil;
    }];
}

-(void)scrubbingDidBegin
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
}
-(void)scrubberIsScrolling
{
    if (_mode == CCVideoPlayerViewControllerModeNetwork) {
        [_progressHud show:YES];
    }
    double currentTime = floor(_movieLength *_movieProgressSlider.value);
    
    int i = 0;
    double temp = [((NSNumber *)_itemTimeList[i]) doubleValue];
    while (currentTime > temp) {
        ++i;
        temp += [((NSNumber *)_itemTimeList[i]) doubleValue];
    }
    temp -= [((NSNumber *)_itemTimeList[i]) doubleValue];
    
    CMTime dragedCMTime = CMTimeMake(currentTime-temp, 1);
    [_player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish){
         if (_isPlaying == YES){
             [_player play];
         }
     }];
}
-(void)scrubbingDidEnd
{
    [self scrubberIsScrolling];
}
#pragma mark -
#pragma mark Common
- (void)commonInit
{
    if (IOS7Version) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.changeOffset = IOS7Version ? 20.f : 0.f;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isMovieFinishedLoading) {
        //视频还未加载完，return掉触摸响应
        NSLog(@"end:视频还未加载完，return");
        return;
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isMovieFinishedLoading) {
        //视频还未加载完，return掉触摸响应
        NSLog(@"end:视频还未加载完，return");
        return;
    }
    //隐藏/显示工具栏
    [UIView animateWithDuration:0.25 animations:^{
        CGRect topFrame = _topView.frame;
        CGRect bottomFrame = _bottomView.frame;
        if (topFrame.origin.y < 0) {
            //显示
            topFrame.origin.y = 0;
            bottomFrame.origin.y = self.view.frame.size.width-kBottomViewHeight;
            [self performSelector:@selector(hideVideoControlBar) withObject:nil afterDelay:kBarHiddenAnmationDuration];
        }else{
            //隐藏
            topFrame.origin.y = -(kTopViewHeight + self.changeOffset);
            bottomFrame.origin.y = self.view.frame.size.width;
        }
        _topView.frame = topFrame;
        _bottomView.frame = bottomFrame;
    }];
}

#pragma mark - 系统相关
//隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
//横屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
