# ContinuousLocation

###一、项目说明
1. 用来做持续定位，经过改进后可以实现一次定位和后台持续定位。
2. 示例项目依赖Masonry、AFNetWorking、JSONModel，请从locationdemo.xcworkspace运行项目
3. 如果自己需要将项目集成到自己的环境中，需要用到AFNetWorking、JSONModel，使用百度反地理编码获取地址信息需要用到网络处理，JSONModel将百度请求的数据封装成model，也可以使用ios自带的反地理编码，使用这个就不需要引入上面的库，但是准确度不是很高，差了几百米，至于这个原因，可以在网上搜索火星坐标，WGS坐标和百度坐标的区别。（只需要在LocationTracker的getReverseGeoCodeLocation方法中将BDGeocoding替换为iosGeocoding即可）

###二、项目配置
1. 在项目的Capabilities中Background Modes中开启Location updates和Background fetch
2. 自iOS8起，系统定位功能进行了升级，开发者在使用定位功能之前，需要在info.plist里添加（以下二选一，两个都添加默认使用NSLocationWhenInUseUsageDescription）：
NSLocationWhenInUseUsageDescription ，允许在前台使用时获取GPS的描述
NSLocationAlwaysUsageDescription ，允许永久使用GPS的描述
3. 模拟器中的debug-->Location中选择定位的位置，可以自己定义
[具体可以参考](http://www.jianshu.com/p/7ccc0860bdbd)

###三、项目使用
1. 
