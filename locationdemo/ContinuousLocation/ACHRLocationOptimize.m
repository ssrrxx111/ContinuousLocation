//
//  ACHRLocationOptimize.m
//  locationdemo
//
//  Created by 123不准动 on 16/7/5.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import "ACHRLocationOptimize.h"

@interface ACHRLocationOptimize()

@end

@implementation ACHRLocationOptimize

#pragma mark - life circle
- (instancetype)init {
    return [self initWithCurrentLocation:[CLLocation new] lastLocation:[CLLocation new]];
}

- (instancetype)initWithCurrentLocation:(CLLocation *)currentLocation lastLocation:(CLLocation *)lastLocation {
    self = [super init];
    if (self) {
        [self initData];
        _currentLocation = currentLocation;
        _lastLocation = lastLocation;
    }
    return self;
}

/**
 *  初始化数据
 */
- (void)initData {
    _firstInterval =            3 * 60;         // 最开始定时时间间隔3分钟
    _mutipleThresholdInterval = 1.5;            // 倍数增长1.5倍
    _mutipleThresholdInterval = 20 * 60;        // 倍数增长最大到20分钟
    _linearGrowthInterval =     1.5 * 60;       // 线性增长每次1.5分钟
    _linearThresholdInterval =  30 * 60;        // 定时时间间隔最大值30分钟    有可能出现之前没动，但是在20分钟内走了很远又回到了原地
    
    _minLocationDistance =      20;             // 大于最小距离才记录这次定位信息
    _maxLocationDistance =      100 * 1000;     // 最大200Km/h，有可能达到最大定时阈值之后，高速运动
    
}





/**
 *  是否启动反地理编码，优化
 */
- (Boolean) isUseGeoCoder {
    Boolean useGeoCoder = NO;
    
    
    CLLocationDistance currentDistance = [_currentLocation distanceFromLocation:_lastLocation];
//    CLLocationSpeed    currentSpeed = _currentLocation.speed;
    
    // 定位时间间隔在指定区域，则上传服务器
    if (currentDistance > _minLocationDistance && currentDistance < _maxLocationDistance) {
        useGeoCoder = YES;
    }
    
    // 如果很长时间都没有上传，那么还是上传一次，即使是在同一个位置
    
    
    // 如果速度很快，就按照距离上传
    
    
    
    // 最开始的定位时间间隔
    
    // 倍数增长的定位时间间隔
    
    // 倍数增长的时间阈值
    
    // 线性增长的时间间隔
    
    // 线性增长的时间阈值，这个是定位重启的最大值
    
    // 距离上次定位的距离
    // distanceFromLocation
    
    // 定位距离最小值
    
    // 定位距离最大值
    
    // 获取两次定位的时间间隔
    
    // 获取两次定位的时间间隔
    
    return useGeoCoder;
}


@end
