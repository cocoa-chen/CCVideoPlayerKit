//
//  CCVideoPlayerViewController.h
//  CCVideoPlayerKit
//
//  Created by 陈 爱彬 on 14-7-16.
//  Copyright (c) 2014年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum{
    CCVideoPlayerViewControllerModeLocal = 0,
    CCVideoPlayerViewControllerModeNetwork,
}CCVideoPlayerViewControllerMode;

@interface CCVideoPlayerViewController : UIViewController

@property (nonatomic,strong,readonly) NSURL *videoURL;
@property (nonatomic,copy,readonly) NSString *videoTitle;
@property (nonatomic, assign) CCVideoPlayerViewControllerMode mode;

- (instancetype)initNetworkVideoPlayerViewControllerWithURL:(NSURL *)url videoTitle:(NSString *)movieTitle;

- (instancetype)initLocalVideoPlayerViewControllerWithURL:(NSURL *)url videoTitle:(NSString *)movieTitle;

//开始加载视频
- (void)startLoadMovie;

@end
