//
//  LocationConversion.m
//  locationdemo
//  http://dijkst.github.io/blog/2013/08/09/zhong-guo-di-tu-zuo-biao-pian-yi-suan-fa-zheng-li/
//  Created by 123不准动 on 16/6/29.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import "LocationConversion.h"

@implementation LocationConversion

//
// Krasovsky 1940
//
// a = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

//
// World Geodetic System ==> Mars Geodetic System


- (Boolean)outOfChina:(CLLocationCoordinate2D) coordinate {
    if (coordinate.longitude < 72.004 || coordinate.longitude > 137.8347)
        return YES;
    if (coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271)
        return YES;
    return NO;
}

- (double) transformLatWithX:(double) x andY:(double) y {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

- (double) transformLonWithX:(double) x andY:(double) y {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

// 地球坐标系 (WGS-84) -> 火星坐标系 (GCJ-02)
- (CLLocationCoordinate2D) wgs2GcjWithCoordinate:(CLLocationCoordinate2D) coordinate {
    if ([self outOfChina:coordinate]) {
        return coordinate;
    }
    double wgLat = coordinate.latitude;
    double wgLon = coordinate.longitude;
    double dLat = [self transformLatWithX:wgLon - 105.0 andY:wgLat - 35.0];
    double dLon = [self transformLonWithX:wgLon - 105.0 andY:wgLat - 35.0];
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon);
}


// 地球坐标系 (WGS-84) <- 火星坐标系 (GCJ-02)
- (CLLocationCoordinate2D)gcj2wgsWithCoordinate:(CLLocationCoordinate2D) coordinate {
    if ([self outOfChina:coordinate]) {
        return coordinate;
    }
    CLLocationCoordinate2D c2 = [self wgs2GcjWithCoordinate:coordinate];
    return CLLocationCoordinate2DMake(2 * coordinate.latitude - c2.latitude, 2 * coordinate.longitude - c2.longitude);
}


const double x_M_PI = M_PI * 3000.0 / 180.0;

// 火星坐标系 (GCJ-02) -> 百度坐标系 (BD-09)
- (CLLocationCoordinate2D) bd_encryptWithCoordinate:(CLLocationCoordinate2D) coordinate {
    double x = coordinate.longitude, y = coordinate.latitude;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_M_PI);
    return CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065);
}

// 火星坐标系 (GCJ-02) <- 百度坐标系 (BD-09)
- (CLLocationCoordinate2D)bd_decriptWithCoordinate:(CLLocationCoordinate2D) coordinate {
    double x = coordinate.latitude - 0.0065, y = coordinate.longitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_M_PI);
    return CLLocationCoordinate2DMake(z * sin(theta), z * cos(theta));
}

















@end
