//
//  LocationConversion.h
//  locationdemo
//
//  Created by 123不准动 on 16/6/29.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationConversion : NSObject

// 地球坐标系 (WGS-84) -> 火星坐标系 (GCJ-02)
- (CLLocationCoordinate2D) wgs2GcjWithCoordinate:(CLLocationCoordinate2D) coordinate;

//// 地球坐标系 (WGS-84) <- 火星坐标系 (GCJ-02)
- (CLLocationCoordinate2D)gcj2wgsWithCoordinate:(CLLocationCoordinate2D) coordinate;
//
//// 火星坐标系 (GCJ-02) -> 百度坐标系 (BD-09)
- (CLLocationCoordinate2D) bd_encryptWithCoordinate:(CLLocationCoordinate2D) coordinate;
//
//// 火星坐标系 (GCJ-02) <- 百度坐标系 (BD-09)
- (CLLocationCoordinate2D)bd_decriptWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end
