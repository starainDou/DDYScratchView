//
//  ViewController.m
//  DDYScratchView
//
//  Created by SmartMesh on 2018/6/6.
//  Copyright © 2018年 com.smartmesh. All rights reserved.
//

#import "ViewController.h"
#import "DDYScratchView.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIButton *showButton;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _contentLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 210, 110)];
        label.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2., [UIScreen mainScreen].bounds.size.height/2.-110);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"马尔代夫一周游";
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
        [self.view addSubview:label];
        label;
    });
    
    _showButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(CGRectGetMinX(_contentLabel.frame), CGRectGetMaxY(_contentLabel.frame) + 20, 210, 35)];
        [button setBackgroundColor:[UIColor lightGrayColor]];
        [button setTitle:@"展示涂层" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showScratchView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
}

- (void)showScratchView {
    __weak __typeof (self)weakSelf = self;
    [self.showButton setHidden:YES];
    DDYScratchView *frontImageView = [[DDYScratchView alloc] initWithFrame:self.contentLabel.frame];
    frontImageView.image = [UIImage imageNamed:@"Scratch"];
    frontImageView.scratchCompleteBlock = ^{
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        strongSelf.showButton.hidden = NO;
    };
    [self.view addSubview:frontImageView];
}

@end
