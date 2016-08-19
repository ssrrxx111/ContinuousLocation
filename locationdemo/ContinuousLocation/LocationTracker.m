//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//

#import "LocationTracker.h"
#import "LocationConversion.h"
#import "ACHRLocationModel.h"
#import "AFNetworking.h"
#import "ACHRBDLocationModel.h"

#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

@interface LocationTracker()

@property (strong,nonatomic) LocationShareModel * shareModel;

@property (nonatomic, strong) ACHRLocationModel *locationModel;             // 反地理编码信息以及各种坐标
@property (nonatomic, strong) ACHRBDLocationModel *BDLocationModel;
@property (nonatomic) CLLocationCoordinate2D myLastLocation;                // 最近一次获取的位置
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (nonatomic, strong) NSTimer *uploadLocationTimer;

@property (nonatomic, assign) Boolean isOnceLocation;                       // 是否一次请求定位标识
@property (nonatomic, assign) Boolean hasStartBackLocation;                 // 是否已经开启后台定位
@property (nonatomic, assign) Boolean backHasStartBackLocation;             // 备份是否已经开启后台定位



@end

@implementation LocationTracker

#pragma 单例

+ (instancetype)sharedInstance {
    static LocationTracker *_locationTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_locationTracker) {
            _locationTracker = [[self alloc] init];
        }
    });
    return _locationTracker;
}

- (id)init {
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        return nil;
    }
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        return nil;
    }
	if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        _uploadLocationTimeInterval = 60.0 * 5;                     // 设置默认的上传时间
        _restartLocationTimeInterval = 60.0 * 3;
        self.shareModel = [LocationShareModel sharedModel];
        _isOnceLocation = NO;
        _hasStartBackLocation = NO;
        _backHasStartBackLocation = NO;
        self.locationModel = [[ACHRLocationModel alloc] init];      // 需要进行初始化
	}
	return self;
}

/**
 *  定位服务单例
 */
+ (CLLocationManager *)sharedLocationManager {
    static CLLocationManager *_locationManager;
    
    @synchronized(self) {
        if (_locationManager == nil) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;        // 导航下的最高定位精度
            _locationManager.distanceFilter = kCLDistanceFilterNone;                        // 检测任何位置变化
            
            //ios8之后需要这个，需要使用这个，才能持续使用后台定位服务
            if(IS_OS_8_OR_LATER) {
                [_locationManager requestAlwaysAuthorization];
            }
            // ios9.0之后后台定位需要
            if (IS_OS_9_OR_LATER) {
                _locationManager.allowsBackgroundLocationUpdates = YES;
            }
            _locationManager.pausesLocationUpdatesAutomatically = NO;       // 指定定位是否会被系统暂停，默认yes
        }
    }
    return _locationManager;
}

/**
 *  开始定位，并且每隔60秒上传一次位置信息到服务器
 */
- (void)startLocationTracking {
    NSLog(@"startLocationTracking");
	if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc]
                                              initWithTitle:@"Location Services Disabled"
                                              message:@"You currently have all location services for this device disabled"
                                              delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
		[servicesDisabledAlert show];
	} else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied ||
           authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            _hasStartBackLocation = YES;
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            [locationManager startUpdatingLocation];
            
            //只有服务启动成功后，才开启上传定时器，每隔60秒上传一次最佳的位置信息给服务器
            self.uploadLocationTimer = [NSTimer scheduledTimerWithTimeInterval:_uploadLocationTimeInterval
                                                                        target:self
                                                                      selector:@selector(updateLocationToServer)
                                                                      userInfo:nil
                                                                       repeats:YES];
            
            // 前台开启定位服务成功后，监控后台运行的定位通知才打开
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationEnterBackground)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
	}
}

/**
 *  一定定位
 */
- (void)startOnceLocationTracking {
    NSLog(@"startLocationTracking");
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc]
                                              initWithTitle:@"Location Services Disabled"
                                              message:@"You currently have all location services for this device disabled"
                                              delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied ||
           authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            _isOnceLocation = YES;
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            [locationManager startUpdatingLocation];
            
            [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(updateLocationToServer)
                                               userInfo:nil
                                                repeats:NO];
            
        }
    }
}

/**
 *  程序进入后台后才运行的
 *  1、监听后台定位的通知应该在开启定位后启动
 *  1、程序进入后台后，同样应该开启上传服务
 */
-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    //    [locationManager startMonitoringSignificantLocationChanges];  // 这个使用的是基站定位
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

/**
 *  重启定位服务
 */
- (void) restartLocationUpdates
{
    NSLog(@"restartLocationUpdates");
    // 在delegate中会多次执行这个，需要判断是否还有后台定位服务，不然总是会重启
    if (_hasStartBackLocation) {
        if (self.shareModel.timer) {
            [self.shareModel.timer invalidate];
            self.shareModel.timer = nil;
        }
        
        CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
    }
    
    
}

/**
 *  停止定位之后，应该停止 
 *  1、停止 定位重启定时器
 *  2、停止 上传服务器定时器
 *  3、移除 后台服务通知
 */
- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    // 后台持续定位标志也应该停止，防止开启了后台定位--》使用者关闭--》开启一次定位（会重新启动后台定位服务）
    // 这个放在前面，防止快速点击开始 - 关闭 - 一次定位
    _hasStartBackLocation = NO;
    // 停止所有的定时器
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
    if (self.shareModel.delay10Seconds) {
        [self.shareModel.delay10Seconds invalidate];
        self.shareModel.delay10Seconds = nil;
    }
    
    if (self.uploadLocationTimer) {
        [self.uploadLocationTimer invalidate];
        self.uploadLocationTimer = nil;
    }
    
    // 移除后台监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // 停止后台服务
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask endAllBackgroundTasks];
    
    // 停止定位服务
	CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
	[locationManager stopUpdatingLocation];
    
}

#pragma mark - CLLocationManagerDelegate Methods

/**
 *  获取到定位信息后的代理方法
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"locationManager didUpdateLocations");
    for (int i=0; i<locations.count; i++) {
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0) {
            continue;
        }
        
        //Select only valid location and also location with good accuracy
        if (newLocation != nil &&
            theAccuracy > 0 &&
            theAccuracy < 2000 &&
            CLLocationCoordinate2DIsValid(theLocation) ) {
            
            self.myLastLocation = theLocation;
            self.myLastLocationAccuracy= theAccuracy;
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[NSNumber numberWithDouble:theLocation.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithDouble:theLocation.longitude] forKey:@"longitude"];
            [dict setObject:[NSNumber numberWithDouble:theAccuracy] forKey:@"theAccuracy"];
            
            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            [self.shareModel.myLocationArray addObject:dict];
        }
    }
    
    // 如果开启了一次定位，下面的都不运行了
    if (_isOnceLocation) {
        return;
    }

    // 防止一次定位后无法关闭的情况
    if (!_hasStartBackLocation) {
        return;
    }
    
    //If the timer still valid, return it (Will not run the code below)
    // 如果重启定位服务的定时器还存在，说明正在执行这个定时器，执行完这个定时器中的restartLocationUpdates方法后，定时器会被销毁
    if (self.shareModel.timer) {
        return;
    }
    
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    // 获取到定位信息之后，60后重启定位服务，在获取之后的10秒，会先关闭定位服务，只有10秒的时间获取定位信息
    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:_restartLocationTimeInterval target:self
                                                           selector:@selector(restartLocationUpdates)
                                                           userInfo:nil
                                                            repeats:NO];
    
    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
    if (self.shareModel.delay10Seconds) {
        [self.shareModel.delay10Seconds invalidate];
        self.shareModel.delay10Seconds = nil;
    }
    
    self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                    selector:@selector(stopLocationDelayBy10Seconds)
                                                    userInfo:nil
                                                     repeats:NO];
    
}


//Stop the locationManager
-(void)stopLocationDelayBy10Seconds{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    NSLog(@"locationManager stop Updating after 10 seconds");
}


- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:@"Please check your network connection."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service"
                                                            message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
             NSLog(@"locationManager error:%@",error);
        }
            break;
    }
}

/**
 *  根据精度获取最佳的位置信息
 */
- (void)getBestLocationBasedOnAccuracy {
    NSLog(@"getBestLocationBasedOnAccuracy");
    // Find the best location from the array based on accuracy
    NSMutableDictionary * dicMyBestLocation = [[NSMutableDictionary alloc]init];
    for(int i=0;i<self.shareModel.myLocationArray.count;i++){
        NSMutableDictionary * dicCurrentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
        if(i==0) {
            dicMyBestLocation = dicCurrentLocation;
        }
        else {
            if ([[dicCurrentLocation objectForKey:ACCURACY] doubleValue] <=
                [[dicMyBestLocation objectForKey:ACCURACY] doubleValue]) {
                dicMyBestLocation = dicCurrentLocation;
            }
        }
    }
    NSLog(@"My Best location:%@",dicMyBestLocation);
    
    // 如果没有获取到位置信息，就发送上一次的给服务器
    if(self.shareModel.myLocationArray.count==0)
    {
        NSLog(@"Unable to get location, use the last known location");
        
        self.locationModel.wgsCoordinate = self.myLastLocation;
        self.locationModel.locationAccuracy=self.myLastLocationAccuracy;
        
    }else{
        CLLocationCoordinate2D theBestLocation;
        theBestLocation.latitude = [[dicMyBestLocation objectForKey:LATITUDE] doubleValue];
        theBestLocation.longitude = [[dicMyBestLocation objectForKey:LONGITUDE] doubleValue];
        self.locationModel.wgsCoordinate = theBestLocation;
        self.locationModel.locationAccuracy =[[dicMyBestLocation objectForKey:ACCURACY] doubleValue];
    }
    
    NSLog(@"Get best Location: Latitude(%f) Longitude(%f) Accuracy(%f)",
          self.locationModel.wgsCoordinate.latitude,
          self.locationModel.wgsCoordinate.longitude,
          self.locationModel.locationAccuracy);
    
    // 清除获取的位置信息
    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
}


/**
 *  反地理编码，根据经纬度获取位置信息
 *  这个查询也需要时间
 *  http://www.jianshu.com/p/964b19ef0225
 */
- (void)getReverseGeoCodeLocation {
    NSLog(@"getReverseGeoCodeLocation:(%f,%f)",
          self.locationModel.wgsCoordinate.latitude,
          self.locationModel.wgsCoordinate.longitude);
    
    // 将地球坐标 --> 国测局坐标
    LocationConversion *conversion = [[LocationConversion alloc] init];
    self.locationModel.gcjCoordinate = [conversion wgs2GcjWithCoordinate:self.locationModel.wgsCoordinate];
    self.locationModel.bdCoordinate = [conversion bd_encryptWithCoordinate:self.locationModel.gcjCoordinate];
    self.locationModel.locationDate = [[NSDate alloc] init];
    
     NSLog(@"地球坐标(%f,%f)->火星坐标(%f,%f)->百度坐标(%f,%f)",
           self.locationModel.wgsCoordinate.latitude,self.locationModel.wgsCoordinate.longitude,
           self.locationModel.gcjCoordinate.latitude,self.locationModel.gcjCoordinate.longitude,
           self.locationModel.bdCoordinate.latitude,self.locationModel.bdCoordinate.longitude);
    
    [self BDGeocoding];
    
//    [self iosGeocoding];      // 先禁用，试下上面的bd反地理编码
}

/**
 *  使用百度反地理编码，未认证用户6K每天，个人认证30W，企业认证300W
 *  api地址：http://api.map.baidu.com/lbsapi/cloud/webservice-geocoding.htm
 *  认证地址：http://lbsyun.baidu.com/apiconsole/auth
 */
- (void)BDGeocoding {
    NSURL *URL = [NSURL URLWithString:@"http://api.map.baidu.com/geocoder/v2/?"];
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setValue:@"QPymE4TZRVnpfclD1bGwvZi73GBgVgav" forKey:@"ak"];
    // 坐标的类型，目前支持的坐标类型包括：
    // bd09ll（百度经纬度坐标）、bd09mc（百度米制坐标）、
    // gcj02ll（国测局经纬度坐标）、wgs84ll（ GPS经纬度）
    [paramDict setValue:@"wgs84ll" forKey:@"coordtype"];
    [paramDict setValue:@"renderReverse" forKey:@"renderReverse"];              // 用于jsonp调用，可以不用
    [paramDict setValue:[NSString stringWithFormat:@"%f,%f",
                         self.locationModel.wgsCoordinate.latitude,
                         self.locationModel.wgsCoordinate.longitude]
                 forKey:@"location"];
    [paramDict setValue:@"json" forKey:@"output"];
    [paramDict setValue:@"0" forKey:@"pois"];                                   // 是否获取poi
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:paramDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        // 使用jsonmodel
        NSError *error = nil;
        if (responseObject) {
            self.BDLocationModel = [[ACHRBDLocationModel alloc] initWithDictionary:responseObject error:&error];
            self.BDLocationModel.result.locationDate = [[NSDate alloc] init];
            if (self.BDLocationModel.status == 0) {
                if (_isOnceLocation) {
                    _isOnceLocation = NO;
                    [self stopLocationTracking];
                    // 如果已经开启后台定位，重新打开
                    if (_backHasStartBackLocation) {
                        [self startLocationTracking];
                    }
                    self.onceLocationBlock(self.BDLocationModel.result);
                } else {
                    self.continuousLocationBlock(self.BDLocationModel.result);
                }
            } else {
                
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

/**
 *  使用ios自带的反地理编码，使用的是google，位置信息不准确
 *  现在先禁用
 */
- (void)iosGeocoding {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    // 根据经纬度信息进行反地理编码
    [geoCoder reverseGeocodeLocation:[[CLLocation alloc]
                                      initWithLatitude:self.locationModel.gcjCoordinate.latitude
                                      longitude:self.locationModel.gcjCoordinate.longitude]
                   completionHandler:^(NSArray<CLPlacemark *> * __nullable placemarks, NSError * __nullable error)
     {
         // 包含区，街道等信息的地标对象
         self.locationModel.placemark = [placemarks firstObject];
         self.locationModel.city = self.locationModel.placemark.locality;
         self.locationModel.street = self.locationModel.placemark.thoroughfare;
         self.locationModel.name = self.locationModel.placemark.name;
         
         NSLog(@"reverseGeocodeLocation: city:%@, street:%@, name:%@",
               self.locationModel.placemark.locality,
               self.locationModel.placemark.thoroughfare,
               self.locationModel.placemark.name);
//         if (_isOnceLocation) {
//             _isOnceLocation = NO;
//             [self stopLocationTracking];
//             // 如果已经开启后台定位，重新打开
//             if (_backHasStartBackLocation) {
//                 [self startLocationTracking];
//             }
//             self.onceLocationBlock(self.locationModel);
//         } else {
//             self.continuousLocationBlock(self.locationModel);
//         }
     }];
}

/**
 *  获取最佳定位信息，反地理编码获取地址，使用block抛给外界
 */
- (void)updateLocationToServer {
    [self getBestLocationBasedOnAccuracy];
    [self getReverseGeoCodeLocation];
}

/**
 *  获取一次定位信息
 *
 *  @param isUseBackLocation 是否使用后台定位的信息
 */
- (void)getOnceLocationInfoWithBackLocation:(Boolean)isUseBackLocation withCompleteBlock:(void(^)(ACHRBDLocationResult *)) completeBlock {
    _onceLocationBlock = completeBlock;
    // 如果之前使用后台持续定位获取了定位信息，直接给一次定位使用，并且重启定位时间不超过10分钟
    if (self.BDLocationModel.status == 0 &&
        isUseBackLocation &&
        _hasStartBackLocation &&
        _restartLocationTimeInterval < 60*10) {
        _onceLocationBlock(self.BDLocationModel.result);
        // 这里也要开启后台定位，不然定位一次后后台定位就直接关闭了
        [self startLocationTracking];
    } else {
        // 保存一个临时变量，证明已经启动了后台定位。不然一次定位和后台定位会重合
        _backHasStartBackLocation = _hasStartBackLocation;
        if (_hasStartBackLocation) {
            [self stopLocationTracking];
        }
        [self startOnceLocationTracking];
    }
}

#pragma getter/setter
/**
 *  设置位置上传时间器
 *  1、以下面的重启定位时间间隔为主，不然会重复设置，然后设置不是想要的结果
 */
- (void)setUploadLocationTimeInterval:(NSTimeInterval)uploadLocationTimeInterval {
//    if (uploadLocationTimeInterval < 60 * 5)          //最少5分钟
    if (uploadLocationTimeInterval < 10) {
        _uploadLocationTimeInterval = 60.0 * 5;
    } else {
        _uploadLocationTimeInterval = uploadLocationTimeInterval;
    }
}

/**
 *  设置重启定位时间间隔
 *  1、不能小于10  2、默认3分钟  3、上传是它的2倍
 *
 */
- (void)setRestartLocationTimeInterval:(NSTimeInterval)restartLocationTimeInterval {
//    if (restartLocationTimeInterval < 60*3)       //最少3分钟
    //10~60之间可以设置，为了测试方便
    if (restartLocationTimeInterval < 10) {
        _restartLocationTimeInterval = 60 * 3;
    } else if (restartLocationTimeInterval > _uploadLocationTimeInterval ||
               fmod(_uploadLocationTimeInterval, restartLocationTimeInterval) != 0) {
        _uploadLocationTimeInterval = restartLocationTimeInterval * 2;              // 以重启定位时间间隔为准
        _restartLocationTimeInterval = restartLocationTimeInterval;
    } else {
        _restartLocationTimeInterval = restartLocationTimeInterval;
    }
}









@end
