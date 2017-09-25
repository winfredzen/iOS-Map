//
//  RouteVC.m
//  BaiduMapDemo
//
//  Created by wangzhen on 2017/9/22.
//  Copyright © 2017年 wz. All rights reserved.
//

#import "RouteVC.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface RouteVC ()<BMKMapViewDelegate,BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fromCityTF;
@property (weak, nonatomic) IBOutlet UITextField *toCityTF;
@property (weak, nonatomic) IBOutlet UITextField *fromAddressTF;
@property (weak, nonatomic) IBOutlet UITextField *toAddressTF;

@property (nonatomic, weak) IBOutlet BMKMapView* mapView;
- (IBAction)tap:(id)sender;

//定位服务对象
@property (nonatomic, strong) BMKLocationService *locationService;
//地理编码
@property (nonatomic, strong) BMKGeoCodeSearch *codeSearch;

//路线搜索
@property (nonatomic, strong) BMKRouteSearch* routeSearch;
//线路检索节点信息 开始
@property (nonatomic, strong) BMKPlanNode *startNode;
//线路检索节点信息 目标
@property (nonatomic, strong) BMKPlanNode *endNode;

- (IBAction)roadAction:(id)sender;

@end

@implementation RouteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
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
    
    
    //初始化检索对象
    _routeSearch = [[BMKRouteSearch alloc] init];
    //设置delegate，用于接收检索结果
    _routeSearch.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//路径规划
- (IBAction)roadAction:(id)sender {
    
    //完成准确的正向地理编码
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geoCodeSearchOption.city= self.fromCityTF.text;
    geoCodeSearchOption.address = self.fromAddressTF.text;
    BOOL flag = [self.codeSearch geoCode:geoCodeSearchOption];

    if(flag)
    {
        NSLog(@"开始geo检索发送成功");
    }
    else
    {
        NSLog(@"开始geo检索发送失败");
    }
    
    
    
    
}

- (IBAction)tap:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - BMKMapViewDelegate

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        //创建显示的折线
        BMKPolylineView *ploylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        //设置该线条的填充颜色
        ploylineView.fillColor = [UIColor redColor];
        ploylineView.strokeColor = [UIColor redColor];
        //设置折线的宽度
        ploylineView.lineWidth = 3.0;
        return ploylineView;
    }
    return nil;
}

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
//接收正向编码结果
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        
        if([result.address isEqualToString:self.fromAddressTF.text]){//开始节点
            self.startNode = [[BMKPlanNode alloc] init];
            //坐标赋值
            self.startNode.pt = result.location;
            
            //发起对目标位置的地理编码
            
            BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
            geoCodeSearchOption.city= self.toCityTF.text;
            geoCodeSearchOption.address = self.toAddressTF.text;
            BOOL flag = [self.codeSearch geoCode:geoCodeSearchOption];
            
            if(flag)
            {
                NSLog(@"目标geo检索发送成功");
            }
            else
            {
                NSLog(@"目标geo检索发送失败");
            }
            
            
        }else{//目标节点
            
            self.endNode = [[BMKPlanNode alloc] init];
            //坐标赋值
            self.endNode.pt = result.location;
            
            
        }
        
        //路径检索
        if(self.startNode != nil  && self.endNode != nil)
        {
            //自驾线路规划
            BMKDrivingRoutePlanOption *option = [[BMKDrivingRoutePlanOption alloc]init];
            option.from = self.startNode;
            option.to = self.endNode;
            //发起检索
            BOOL flag = [self.routeSearch drivingSearch:option];
            
            if(flag) {
                NSLog(@"自驾交通检索（支持垮城）发送成功");
            } else {
                NSLog(@"自驾交通检索（支持垮城）发送失败");
            }
        }
        
        
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}



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

#pragma mark - BMKRouteSearchDelegate

/**
 *返回驾乘搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKDrivingRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetMassTransitRouteResult error:%d", (int)error);
    if (error == BMK_SEARCH_NO_ERROR) {
        //成功获取结果
        
        //删除原来的覆盖物
        NSArray *array = [NSArray arrayWithArray:_mapView.annotations];
        [_mapView removeAnnotations:array];
        
        //删除overlays
        array = [NSArray arrayWithArray:_mapView.overlays];
        [_mapView removeOverlays:array];
        
        //选取获取到所有路线中的一条路线
        BMKDrivingRouteLine *plan = [result.routes objectAtIndex:0];
        //计算路线方案中路线的数目
        NSUInteger size = [plan.steps count];
        
        int planPointCounts = 0;
        for(int i = 0;i<size; i++){
            //获取路线中路段
            BMKDrivingStep *step = [plan.steps objectAtIndex:i];
            if(i==0){
                //地图显示经纬区域
                [self.mapView setRegion:BMKCoordinateRegionMake(step.entrace.location, BMKCoordinateSpanMake(0.01, 0.01))];
            }
            //累计轨迹点
            planPointCounts += step.pointsCount;
        }
        
        //声明结构体数组，用来保持所有的轨迹点
        BMKMapPoint *tempPoints = new BMKMapPoint[planPointCounts];
        
        int i=0;
        for(int j =0;j<size;j++ ){
            BMKDrivingStep *transitStep = [plan.steps objectAtIndex:j];
            int k = 0;
            for ( k =0; k<transitStep.pointsCount; k++) {
                //获取每个轨迹点的x y
                tempPoints[i].x = transitStep.points[k].x;
                tempPoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        
        
        //通过轨迹点构造BMKPloyLine
        
        BMKPolyline *ployLine = [BMKPolyline polylineWithPoints:tempPoints count:planPointCounts];
        
        //添加到mapview上，在地图上显示轨迹，先添加overlay
        
        [self.mapView addOverlay:ployLine];
        
        
        
    } else {
        //检索失败
    }
}


@end
