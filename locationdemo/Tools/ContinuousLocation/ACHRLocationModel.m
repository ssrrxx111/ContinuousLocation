//
//  LocationModel.m
//  locationdemo
//
//  Created by 123不准动 on 16/6/30.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import "ACHRLocationModel.h"

@implementation ACHRLocationModel

/**
 *  将日期格式化为字符串
 */
- (NSString *)locationDate {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"YYYY-MM-dd HH:mm:ss SS";
    return [dateFormater stringFromDate:_locationDate];
}

@end
