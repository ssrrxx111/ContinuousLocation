//
//  LocationTracker.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"
#import "ACHRBDLocationModel.h"

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic, assign) NSTimeInterval uploadLocationTimeInterval;     // 上传服务器间隔时间
@property (nonatomic, assign) NSTimeInterval restartLocationTimeInterval;    // 每次重启定位服务的时间(在这个时间段内，除了定位的10秒，不会有定位信息)

+ (instancetype)sharedInstance;
- (void)startLocationTracking;
- (void)stopLocationTracking;

typedef void(^ContinuousLocationBlock)(ACHRBDLocationResult *);                       // 持续定位获取定期信息block
typedef void(^OnceLocationBlock)(ACHRBDLocationResult *);                             // 一次定位获取定位信息block

@property (nonatomic, strong) OnceLocationBlock onceLocationBlock;
@property (nonatomic, strong) ContinuousLocationBlock continuousLocationBlock;

/**
 *  获取一次定位信息
 *
 *  @param isUseBackLocation 是否使用持续定位的结果
 *  @param onceLocationBlock 一次定位后返回的定位block
 */
- (void)getOnceLocationInfoWithBackLocation:(Boolean)isUseBackLocation
                          withCompleteBlock:(OnceLocationBlock) onceLocationBlock;





@end
