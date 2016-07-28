//
//  LocationModel.h
//  locationdemo
//
//  Created by 123不准动 on 16/6/30.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ACHRLocationModel : NSObject

@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, copy)   NSString *city;
@property (nonatomic, copy)   NSString *street;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSDate *locationDate;
@property (nonatomic, assign) CLLocationAccuracy locationAccuracy;


@property (nonatomic, assign) CLLocationCoordinate2D wgsCoordinate;    // 谷歌全球坐标
@property (nonatomic, assign) CLLocationCoordinate2D gcjCoordinate;    // 国测局坐标
@property (nonatomic, assign) CLLocationCoordinate2D bdCoordinate;     // 百度坐标

@end
