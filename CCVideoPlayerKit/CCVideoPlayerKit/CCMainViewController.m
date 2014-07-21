//
//  CCMainViewController.m
//  CCVideoPlayerKit
//
//  Created by 陈 爱彬 on 14-7-16.
//  Copyright (c) 2014年 陈爱彬. All rights reserved.
//

#import "CCMainViewController.h"
#import "CCVideoPlayerViewController.h"

@interface CCMainViewController ()

@end

@implementation CCMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:57.0/255.0 green:135.0/255.0 blue:224.0/255.0 alpha:1.0f];
    
    UIButton *_localButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _localButton.frame = CGRectMake(100, 100, 120, 40);
    [_localButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_localButton setTitle:@"Local Video" forState:UIControlStateNormal];
    [_localButton addTarget:self action:@selector(onPlayLocalVideoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_localButton];

    UIButton *_networkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _networkButton.frame = CGRectMake(100, 200, 120, 40);
    [_networkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_networkButton setTitle:@"Network Video" forState:UIControlStateNormal];
    [_networkButton addTarget:self action:@selector(onPlayNetworkVideoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_networkButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onPlayLocalVideoButtonTapped
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"localVideo" ofType:@"mp4"];
    NSURL *localVideoUrl = [NSURL fileURLWithPath:filePath];
    CCVideoPlayerViewController *playerVc = [[CCVideoPlayerViewController alloc] initLocalVideoPlayerViewControllerWithURL:localVideoUrl videoTitle:@"大力水手"];
    [self presentViewController:playerVc animated:YES completion:^{
        //Loading Video
        [playerVc startLoadMovie];
    }];
}
- (void)onPlayNetworkVideoButtonTapped
{
    
    NSURL *videoUrl = [NSURL URLWithString:@"http://v.youku.com/player/getM3U8/vid/XNzIxNTE0NDcy/type/mp4/video.m3u8"];
    CCVideoPlayerViewController *playerVc = [[CCVideoPlayerViewController alloc] initNetworkVideoPlayerViewControllerWithURL:videoUrl videoTitle:@"小苹果MV"];
    [self presentViewController:playerVc animated:YES completion:^{
        //Loading Video
        [playerVc startLoadMovie];
    }];

}
@end
