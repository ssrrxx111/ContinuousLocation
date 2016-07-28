//
//  ViewController.m
//  locationdemo
//
//  Created by 123不准动 on 16/6/17.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *buttonStart;
@property (nonatomic, strong) UIButton *buttonStop;
@property (nonatomic, strong) UIButton *buttonClear;


@end

@implementation ViewController

#pragma life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
}


- (void)initView {
    _buttonStart = [[UIButton alloc] init];
    [_buttonStart setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:_buttonStart];
    
    _buttonStop = [[UIButton alloc] init];
    [_buttonStop setTitle:@"停止" forState:UIControlStateNormal];
    [self.view addSubview:_buttonStop];
    
    _buttonClear = [[UIButton alloc] init];
    [_buttonClear setTitle:@"清空" forState:UIControlStateNormal];
    [self.view addSubview:_buttonClear];
    
    CGFloat buttonWidth = (self.view.bounds.size.width - 40) / 3;
    
    [_buttonStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@40);
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(32);
    }];
    
    [_buttonStop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_buttonStart.mas_right).offset(10);
        make.width.height.centerY.equalTo(_buttonStart);
    }];
    
    [_buttonClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_buttonStop.mas_right).offset(10);
        make.width.height.centerY.equalTo(_buttonStart);
    }];
    
}
















@end
