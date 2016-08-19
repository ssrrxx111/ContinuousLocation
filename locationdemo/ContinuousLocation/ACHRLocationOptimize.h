//
//  ACHRLocationOptimize.h
//  locationdemo
//
//  Created by 123不准动 on 16/7/5.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ACHRLocationOptimize : NSObject

@property (nonatomic, assign) NSTimeInterval firstInterval;             // 最开始的定位时间间隔
@property (nonatomic, assign) NSTimeInterval multipleGrowthInterval;    // 倍数增长的定位时间间隔
@property (nonatomic, assign) NSTimeInterval mutipleThresholdInterval;  // 倍数增长的时间阈值
@property (nonatomic, assign) NSTimeInterval linearGrowthInterval;      // 线性增长的时间间隔
@property (nonatomic, assign) NSTimeInterval linearThresholdInterval;   // 线性增长的时间阈值，这个是定位重启的最大值
// 距离上次定位的距离
// distanceFromLocation
@property (nonatomic, assign) CLLocationDistance minLocationDistance;            // 定位距离最小值
@property (nonatomic, assign) CLLocationDistance maxLocationDistance;            // 定位距离最大值

@property (nonatomic, strong) CLLocation *lastLocation;                 // 上一次定位location
@property (nonatomic, strong) CLLocation *currentLocation;              // 最新获取的定位location

@property (nonatomic, assign) NSInteger currentLocationDistance;        // 距离上次定位的距离    需要计算

- (instancetype)initWithCurrentLocation:(CLLocation *)currentLocation lastLocation:(CLLocation *)lastLocation;

@end
