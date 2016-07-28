//
//  LOCLocationDemoVC.m
//  locationdemo
//
//  Created by 123不准动 on 16/6/17.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import "LOCLocationDemoVC.h"
#import "Masonry.h"
#import "LocationTracker.h"
#import "ACHRBDLocationModel.h"

@interface LOCLocationDemoVC ()

@property (nonatomic, strong) LocationTracker *locationTracker;

@property (nonatomic, strong) UIButton *buttonStart;                    // 开始定位
@property (nonatomic, strong) UIButton *buttonStop;                     // 停止定位
@property (nonatomic, strong) UIButton *buttonClear;                    // 清空定位数据按钮
@property (nonatomic, strong) UIButton *buttonOnceLocation;             // 一次定位

@property (nonatomic, strong) UITextField *textFieldUploadInterval;     // 上传服务器间隔时间
@property (nonatomic, strong) UITextView *textViewLocationInfo;         // 定位信息

@end

@implementation LOCLocationDemoVC

#pragma mark - life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}


- (void)initView {
    _buttonStart = [[UIButton alloc] init];
    [_buttonStart setTitle:@"开始" forState:UIControlStateNormal];
    _buttonStart.backgroundColor = [UIColor blueColor];
    [_buttonStart addTarget:self action:@selector(startLocationDemo) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_buttonStart];
    
    _buttonStop = [[UIButton alloc] init];
    [_buttonStop setTitle:@"停止" forState:UIControlStateNormal];
    _buttonStop.backgroundColor = [UIColor redColor];
    [_buttonStop addTarget:self action:@selector(stopLocationTracker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonStop];
    
    _buttonOnceLocation = [[UIButton alloc] init];
    [_buttonOnceLocation setTitle:@"一次定位" forState:UIControlStateNormal];
    _buttonOnceLocation.backgroundColor = [UIColor greenColor];
    [_buttonOnceLocation addTarget:self action:@selector(onceLocationInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonOnceLocation];
    
    _buttonClear = [[UIButton alloc] init];
    [_buttonClear setTitle:@"清空" forState:UIControlStateNormal];
    _buttonClear.backgroundColor = [UIColor orangeColor];
    [_buttonClear addTarget:self action:@selector(clearLabelText) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonClear];
    
    _textFieldUploadInterval = [[UITextField alloc] init];
    _textFieldUploadInterval.borderStyle = UITextBorderStyleLine;
    _textFieldUploadInterval.keyboardType = UIKeyboardTypeNumberPad;
    _textFieldUploadInterval.placeholder = @"请输入上传定位信息到服务器的间隔时间";
    [self.view addSubview:_textFieldUploadInterval];
    
    _textViewLocationInfo = [[UITextView alloc] init];
    _textViewLocationInfo.backgroundColor = [UIColor whiteColor];
    _textViewLocationInfo.editable = NO;
    [self.view addSubview:_textViewLocationInfo];
    
    
    CGFloat buttonWidth = (self.view.bounds.size.width - 25) / 4;
    
    [_buttonStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@40);
        make.left.equalTo(self.view).offset(5);
        make.top.equalTo(self.view).offset(32);
    }];
    
    [_buttonStop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_buttonStart.mas_right).offset(5);
        make.width.height.centerY.equalTo(_buttonStart);
    }];
    
    [_buttonOnceLocation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_buttonStop.mas_right).offset(5);
        make.width.height.centerY.equalTo(_buttonStart);
    }];
    
    [_buttonClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_buttonOnceLocation.mas_right).offset(5);
        make.width.height.centerY.equalTo(_buttonStart);
    }];
    
    [_textFieldUploadInterval mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(@40);
        make.top.equalTo(_buttonStop.mas_bottom).offset(10);
    }];
    
    [_textViewLocationInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-10);
        make.width.centerX.equalTo(_textFieldUploadInterval);
        make.top.equalTo(_textFieldUploadInterval.mas_bottom).offset(10);
    }];
    
}

#pragma mark - event

- (void)startLocationDemo {
    NSTimeInterval timeInterval = 20.0;
    if (![_textFieldUploadInterval.text isEqualToString:@""]) {
        timeInterval = [_textFieldUploadInterval.text doubleValue];
    }
    
    _textViewLocationInfo.text = [@"开始后台定位\n" stringByAppendingString:_textViewLocationInfo.text];
    // 初始化之前判断
    // 获取位置信息后，隔10秒会关闭位置服务，50秒会重启定位服务（这个期间定位服务不会重启），隔20秒会上传位置信息
    self.locationTracker = [LocationTracker sharedInstance];
    self.locationTracker.restartLocationTimeInterval = 60;
    self.locationTracker.uploadLocationTimeInterval = 60;       // 这个要大于60秒，不然会有失效的情况
    [self.locationTracker startLocationTracking];
    __weak LOCLocationDemoVC *weakSelf = self;
    self.locationTracker.continuousLocationBlock = ^(ACHRBDLocationResult *locationModel){
        __strong LOCLocationDemoVC *strongSelf = weakSelf;
        NSString *locationInfo = [NSString stringWithFormat:@" %@:发送到服务器:\n 省名:%@ 城市:%@ 区县名:%@ 街道名:%@  \n 结构化地址信息:%@ \n poi地址描述:      %@ \n 经纬度:             (%@,%@)\n\n",
                                  locationModel.locationDate,
                                  locationModel.addressComponent.province,
                                  locationModel.addressComponent.city,
                                  locationModel.addressComponent.district,
                                  locationModel.addressComponent.street,
                                  locationModel.formatted_address,
                                  locationModel.sematic_description,
                                  locationModel.location.lat,
                                  locationModel.location.lng];
        NSLog(@"%@",locationInfo);
        strongSelf.textViewLocationInfo.text = [locationInfo stringByAppendingString:strongSelf.textViewLocationInfo.text];
    };

}

- (void)onceLocationInfo {
    // 下面会执行多次，需要控制一下
    _textViewLocationInfo.text = [@"正在获取一次定位信息……\n" stringByAppendingString:_textViewLocationInfo.text];
    self.locationTracker = [LocationTracker sharedInstance];
    __weak LOCLocationDemoVC *weakSelf = self;
    [self.locationTracker getOnceLocationInfoWithBackLocation:YES withCompleteBlock:^(ACHRBDLocationResult * locationModel) {
        __strong LOCLocationDemoVC *strongSelf = weakSelf;
        NSString *locationInfo = [NSString stringWithFormat:@" %@:一次定位信息:\n 省名:%@ 城市:%@ 区县名:%@ 街道名:%@ \n 结构化地址信息:%@ \n poi地址描述:      %@ \n 经纬度:              (%@,%@)\n\n",
                                  locationModel.locationDate,
                                  locationModel.addressComponent.province,
                                  locationModel.addressComponent.city,
                                  locationModel.addressComponent.district,
                                  locationModel.addressComponent.street,
                                  locationModel.formatted_address,
                                  locationModel.sematic_description,
                                  locationModel.location.lat,
                                  locationModel.location.lng];
        NSLog(@"%@",locationInfo);
        strongSelf.textViewLocationInfo.text = [locationInfo stringByAppendingString:strongSelf.textViewLocationInfo.text];
    }];
}

- (void)stopLocationTracker {
    if (self.locationTracker) {
        _textViewLocationInfo.text = [@"停止定位\n" stringByAppendingString:_textViewLocationInfo.text];
        if ([self.locationTracker respondsToSelector:@selector(stopLocationTracking)]) {
            [self.locationTracker stopLocationTracking];
        }
    }
}

- (void)clearLabelText {
    _textViewLocationInfo.text =  @"";
}




@end
