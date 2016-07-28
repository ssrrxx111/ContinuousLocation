//
//  ACHRBDLocationModel.h
//  locationdemo
//
//  Created by 123不准动 on 16/7/1.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonModel.h"
@class ACHRBDLocationResult;


@interface ACHRBDLocationModel : JSONModel

/**
 *   0	正常
     1	服务器内部错误
     2	请求参数非法
     3	权限校验失败
     4	配额校验失败
     5	ak不存在或者非法
     101	服务禁用
     102	不通过白名单或者安全码不对
     2xx	无权限
     3xx	配额错误
 */
@property (nonatomic, assign) NSInteger status;                 // 返回结果状态值， 成功返回0
@property (nonatomic, strong) ACHRBDLocationResult *result;



@end

@class ACHRBDLocationAddress;
@class ACHRBDLocationCoordinate;
//@class ACHRBDLocationPoiRegions;
@class ACHRBDLocationPois;
@interface ACHRBDLocationResult : JSONModel

@property (nonatomic, strong) ACHRBDLocationAddress *addressComponent;
@property (nonatomic, strong) ACHRBDLocationCoordinate *location;
//@property (nonatomic, strong) ACHRBDLocationPoiRegions *poiRegions;
@property (nonatomic, strong) NSArray<ACHRBDLocationPois *> *pois;

@property (nonatomic, copy) NSString *business;                         // 所在商圈信息，如 "人民大学,中关村,苏州街"
@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *formatted_address;                // 结构化地址信息
@property (nonatomic, copy) NSString *sematic_description;              // 当前位置结合POI的语义化结果描述
@property (nonatomic, strong) NSDate *locationDate;

@end

@interface ACHRBDLocationAddress : JSONModel

@property (nonatomic, copy) NSString *country;               // 国家
@property (nonatomic, copy) NSString *province;              // 省名
@property (nonatomic, copy) NSString *city;                  // 城市名
@property (nonatomic, copy) NSString *district;              // 区县名
@property (nonatomic, copy) NSString *street;                // 街道名
@property (nonatomic, copy) NSString *street_number;         // 街道门牌号
@property (nonatomic, copy) NSString *adcode;                // 行政区划代码
@property (nonatomic, copy) NSString *country_code;          // 国家代码
@property (nonatomic, copy) NSString *direction;             // 和当前坐标点的方向，当有门牌号的时候返回数据
@property (nonatomic, copy) NSString *distance;             // 和当前坐标点的距离，当有门牌号的时候返回数据



@end

@interface ACHRBDLocationCoordinate : JSONModel

@property (nonatomic, copy) NSString *lat;
@property (nonatomic, copy) NSString *lng;


@end

@interface ACHRBDLocationPoiRegions : JSONModel

@end

@class ACHRBDLocationPoiRegions;
@interface ACHRBDLocationPois : JSONModel

@property (nonatomic, copy) NSString *addr;              // 地址信息
@property (nonatomic, copy) NSString *cp;                // 数据来源
@property (nonatomic, copy) NSString *direction;         // 和当前坐标点的方向
@property (nonatomic, copy) NSString *distance;          // 离坐标点距离
@property (nonatomic, copy) NSString *name;              // poi名称
@property (nonatomic, copy) NSString *poiType;           // poi类型，如’ 办公大厦,商务大厦’
@property (nonatomic, strong) ACHRBDLocationPoiRegions *point;  // poi坐标{x,y}
@property (nonatomic, copy) NSString *tel;               // 电话
@property (nonatomic, copy) NSString *uid;               // poi唯一标识
@property (nonatomic, copy) NSString *zip;               // 邮编

@end


@interface ACHRBDLocationPoisPoint : JSONModel

@property (nonatomic, copy) NSString *x;               // poi坐标
@property (nonatomic, copy) NSString *y;               //

@end







