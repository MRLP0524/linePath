//
//  SHRootController.m
//  SHLineGraphView
//
//  Created by SHAN UL HAQ on 23/3/14.
//  Copyright (c) 2014 grevolution. All rights reserved.
//

#import "SHRootController.h"
#import "SHLineGraphView.h"
#import "SHPlot.h"


#define SCREEN_WIDTH    self.view.bounds.size.width     //宏定义:屏幕的宽
#define SCREEN_HEIGHT   self.view.bounds.size.height    //宏定义:屏幕的高

@interface SHRootController () <UIScrollViewDelegate>

@end

@implementation SHRootController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

    //设置折线图的大小
    SHLineGraphView *_lineGraph = [[SHLineGraphView alloc] initWithFrame:CGRectMake(0, 0,  SCREEN_WIDTH * 2, SCREEN_HEIGHT/2)];
  
//=======================================================================================================
//
//                                        第一幅 折线图
//
//=======================================================================================================
    NSDictionary *_themeAttributes = @{
                                       //横轴字的颜色
                                       kXAxisLabelColorKey : [UIColor blackColor],
                                       kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                       //竖轴的字颜色
                                       kYAxisLabelColorKey : [UIColor blackColor],
                                       kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                       //距离两边的距离
                                       kYAxisLabelSideMarginsKey : @10,
                                       //坐标线的颜色
                                       kPlotBackgroundLineColorKye : [UIColor colorWithWhite:0.8 alpha:1.000]
                                       };
    
    _lineGraph.themeAttributes = _themeAttributes;
    //数值最大值
    _lineGraph.yAxisRange = @(200);
    //竖轴开始坐标数值
    _lineGraph.startYAxisRange = @(0);
    //竖轴点的间距
    _lineGraph.PX_IN_Y = @(20);
    //竖轴点的个数
    _lineGraph.COUNT_IN_Y = @(10);
    //设置最大值
    _lineGraph.MAX_Range_1 = @(110);
    //设置最小值
    _lineGraph.MIN_Range_1 = @(40);
    //Y轴单位文字
    _lineGraph.yAxisSuffix = @"(千克)";
    
    //点的标题文字
//    NSArray *arr = @[@"1", @"2", @"3", @"4", @"5", @"6" , @"7" , @"8", @"9", @"10", @"11", @"12"];
//    _plot1.plottingPointsLabels = arr;
    
    //横坐标的单位
    _lineGraph.xAxisValues = @[
                               @{ @1 :  @"10月1日" },
                               @{ @2 :  @"10月2日" },
                               @{ @3 :  @"10月3日" },
                               @{ @4 :  @"10月4日" },
                               @{ @5 :  @"10月5日" },
                               @{ @6 :  @"10月6日" },
                               @{ @7 :  @"10月7日" },
                               @{ @8 :  @"10月8日" },
                               @{ @9 :  @"10月9日" },
                               @{ @10 : @"10月10日" },
                               @{ @11 : @"10月11日" },
                               @{ @12 : @"10月12日" }
                               ];
    
    SHPlot *_plot1 = [[SHPlot alloc] init];
    
    //折线图点的数值
    _plot1.plottingValues = @[
                              @{ @1 : @65.8 },
                              @{ @2 : @20 },
                              @{ @3 : @23 },
                              @{ @4 : @22 },
                              @{ @5 : @12.3 },
                              @{ @6 : @45.8 },
                              @{ @7 : @56 },
                              @{ @8 : @97 },
                              @{ @9 : @65 },
                              @{ @10 : @10 },
                              @{ @11 : @67 },
                              @{ @12 : @23 }
                              ];
    //设置折线图的具体信息
    NSDictionary *_plotThemeAttributes = @{
                                           //线下的颜色
                                           kPlotFillColorKey : [UIColor clearColor],
                                           //线的宽度
                                           kPlotStrokeWidthKey : @2,
                                           //线的颜色
                                           kPlotStrokeColorKey : [UIColor  blackColor],
                                           //折点的颜色
                                           kPlotPointFillColorKey : [UIColor redColor],
                                           //点击标注的字体
                                           kPlotPointValueFontKey : [UIFont fontWithName:@"TrebuchetMS" size:18]
                                           };
    
    _plot1.plotThemeAttributes = _plotThemeAttributes;
    
    [_lineGraph addPlot:_plot1];
    
    [_lineGraph setupTheView];
//=======================================================================================================
//
//                                        第二幅 折线图
//
//=======================================================================================================
    //设置第二个折线图数值最大值
    _lineGraph.MAX_Range_2 = @(110);
    //设置第二个折线图数值最小值
    _lineGraph.MIN_Range_2 = @(40);
    
    SHPlot *_plot2 = [[SHPlot alloc] init];
    
    //点的数值
    _plot2.plottingValues_two = @[
                                  @{ @1 : @165.8 },
                                  @{ @2 : @120 },
                                  @{ @3 : @53 },
                                  @{ @4 : @122 },
                                  @{ @5 : @152.3 },
                                  @{ @6 : @10.8 },
                                  @{ @7 : @156 },
                                  @{ @8 : @10 },
                                  @{ @9 : @131 },
                                  @{ @10 : @110 },
                                  @{ @11 : @200 },
                                  @{ @12 : @123 }
                                  ];
    
    NSDictionary *_plotThemeAttributes2 = @{
                                            //线下的颜色
                                            kPlotFillColorKey :[UIColor clearColor],
                                            //线的宽度
                                            kPlotStrokeWidthKey : @2,
                                            //线的颜色
                                            kPlotStrokeColorKey : [UIColor blackColor],
                                            //折点的颜色
                                            kPlotPointFillColorKey :[UIColor blueColor],
                                            //点击标注的字体
                                            kPlotPointValueFontKey : [UIFont fontWithName:@"TrebuchetMS" size:18]
                                            };
    
    _plot2.plotThemeAttributes = _plotThemeAttributes2;
    
    [_lineGraph addPlot:_plot2];
    
    [_lineGraph setupTheView];
    
    //设置滑动视图
    UIScrollView *view = [[UIScrollView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(0, SCREEN_HEIGHT/4 + 40, SCREEN_WIDTH , SCREEN_HEIGHT / 2);
    view.delegate = self;
    view.tag =100;
    view.contentSize = _lineGraph.frame.size;
    view.pagingEnabled = NO;
    view.delaysContentTouches = YES;
    view.showsHorizontalScrollIndicator = YES;
    view.showsVerticalScrollIndicator = YES ;
    view.alwaysBounceHorizontal = NO;
    view.alwaysBounceVertical = NO;
    
    
    [self.view addSubview:view];
    
    [view addSubview:_lineGraph];

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
	return YES;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//	return UIInterfaceOrientationLandscapeLeft;
////    return UIInterfaceOrientationLandscapeRight;
//}
//
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//	return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}
@end
