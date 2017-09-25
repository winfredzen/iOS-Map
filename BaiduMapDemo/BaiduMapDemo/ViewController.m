//
//  ViewController.m
//  BaiduMapDemo
//
//  Created by wangzhen on 2017/9/22.
//  Copyright © 2017年 wz. All rights reserved.
//

#import "ViewController.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface ViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, weak) IBOutlet BMKMapView* mapView;
//定位服务对象
@property (nonatomic, strong) BMKLocationService *locationService;
//地理编码
@property (nonatomic, strong) BMKGeoCodeSearch *codeSearch;

- (IBAction)leftAction:(id)sender;
- (IBAction)rightAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    //切换为卫星图
    //[_mapView setMapType:BMKMapTypeSatellite];
    
    self.mapView.delegate = self;
    
    //定位服务对象
    _locationService = [[BMKLocationService alloc]init];
    _locationService.delegate = self;
    //设置再次定位最小距离
    [BMKLocationService setLocationDistanceFilter:10];
    
    //地理编码
    self.codeSearch = [[BMKGeoCodeSearch alloc] init];
    self.codeSearch.delegate = self;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)leftAction:(id)sender {
    //启动LocationService
    [_locationService startUserLocationService];
    //在地图上显示用户的位置
    self.mapView.showsUserLocation = YES;
}

- (IBAction)rightAction:(id)sender {
    
    //关闭定位服务
    [self.locationService stopUserLocationService];
    //设置地图不显示用户的位置
    [self.mapView setShowsUserLocation:NO];
    //删除标注对象
    [self.mapView removeAnnotation:[[self.mapView annotations] firstObject]];
    
}


#pragma mark - BMKMapViewDelegate



#pragma mark - BMKLocationServiceDelegate
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser
{
    NSLog(@"开始定位");
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    NSLog(@"停止定位");
}

//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    //地理反编码
    //1.创建反向地理编码选项对象
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    //2.执行反向地理编码操作
    BOOL flag = [self.codeSearch reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}


#pragma mark - BMKGeoCodeSearchDelegate
//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
  if (error == BMK_SEARCH_NO_ERROR) {
      
      //添加大头针
      //添加一个 PointAnnotation
      BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
      //设置标注的位置坐标
      annotation.coordinate = result.location;
      /*
       CLLocationCoordinate2D coor;
       coor.latitude = userLocation.location.coordinate.latitude;
       coor.longitude = userLocation.location.coordinate.longitude;
       annotation.coordinate = coor;
       */
      
      annotation.title = result.address;
      //添加到地图中
      [_mapView addAnnotation:annotation];
      //使地图显示该位置
      [self.mapView setCenterCoordinate:result.location animated:YES];
      
  }
  else {
      NSLog(@"抱歉，未找到结果");
  }
}















@end
