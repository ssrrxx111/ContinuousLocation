//
//  ACHRBDLocationModel.m
//  locationdemo
//
//  Created by 123不准动 on 16/7/1.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import "ACHRBDLocationModel.h"

@implementation ACHRBDLocationModel
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end

@implementation ACHRBDLocationResult
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

/**
 *  将日期格式化为字符串
 */
- (NSString *)locationDate {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"YYYY-MM-dd HH:mm:ss SS";
    return [dateFormater stringFromDate:_locationDate];
}

@end

@implementation ACHRBDLocationAddress
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end

@implementation ACHRBDLocationPoiRegions
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end

@implementation ACHRBDLocationCoordinate
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end

@implementation ACHRBDLocationPois
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end

@implementation ACHRBDLocationPoisPoint
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end









