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

@interface SHRootController ()

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
  // Do any additional setup after loading the view.
  
  //initate the graph view
  SHLineGraphView *_lineGraph = [[SHLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
  
  //set the main graph area theme attributes

  /**
   *  theme attributes dictionary. you can specify graph theme releated attributes in this dictionary. if this property is
   *  nil, then a default theme setting is applied to the graph.
   */
  NSDictionary *_themeAttributes = @{
                                     //横轴字的颜色
                                     kXAxisLabelColorKey : [UIColor redColor],
                                     kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                     //竖轴的字颜色
                                     kYAxisLabelColorKey : [UIColor blueColor],
                                     kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                     //距离两边的距离
                                     kYAxisLabelSideMarginsKey : @10,
                                     //线的颜色
                                     kPlotBackgroundLineColorKye : [UIColor purpleColor]
                                     };
  _lineGraph.themeAttributes = _themeAttributes;
  
  //set the line graph attributes
  
  /**
   *  the maximum y-value possible in the graph. make sure that the y-value is not in the plotting points is not greater
   *  then this number. otherwise the graph plotting will show wrong results.
   */
    //数值最大值
  _lineGraph.yAxisRange = @(100);
  
  /**
   *  y-axis values are calculated according to the yAxisRange passed. so you do not have to pass the explicit labels for
   *  y-axis, but if you want to put any suffix to the calculated y-values, you can mention it here (e.g. K, M, Kg ...)
   */
  _lineGraph.yAxisSuffix = @"K";
  
  /**
   *  an Array of dictionaries specifying the key/value pair where key is the object which will identify a particular
   *  x point on the x-axis line. and the value is the label which you want to show on x-axis against that point on x-axis.
   *  the keys are important here as when plotting the actual points on the graph, you will have to use the same key to
   *  specify the point value for that x-axis point.
   */
  _lineGraph.xAxisValues = @[
                             @{ @1 : @"JAN" },
                             @{ @2 : @"FEB" },
                             @{ @3 : @"MAR" },
                             @{ @4 : @"APR" },
                             @{ @5 : @"MAY" },
                             @{ @6 : @"JUN" },
                             @{ @7 : @"JUL" },
                             @{ @8 : @"AUG" },
                             @{ @9 : @"SEP" },
                             @{ @10 : @"OCT" },
                             @{ @11 : @"NOV" },
                             @{ @12 : @"DEC" }
                             ];
  
  //create a new plot object that you want to draw on the `_lineGraph`
  SHPlot *_plot1 = [[SHPlot alloc] init];
  
  //set the plot attributes
  
  /**
   *  Array of dictionaries, where the key is the same as the one which you specified in the `xAxisValues` in `SHLineGraphView`,
   *  the value is the number which will determine the point location along the y-axis line. make sure the values are not
   *  greater than the `yAxisRange` specified in `SHLineGraphView`.
   */
  _plot1.plottingValues = @[
                            //点的数值
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
  
  /**
   *  this is an optional array of `NSString` that specifies the labels to show on the particular points. when user clicks on
   *  a particular points, a popover view is shown and will show the particular label on for that point, that is specified
   *  in this array.
   */
    //点的标题文字
  NSArray *arr = @[@"1", @"2", @"3", @"4", @"5", @"6" , @"7" , @"8", @"9", @"10", @"11", @"12"];
  _plot1.plottingPointsLabels = arr;
  
  //set plot theme attributes
  
  /**
   *  the dictionary which you can use to assing the theme attributes of the plot. if this property is nil, a default theme
   *  is applied selected and the graph is plotted with those default settings.
   */
  
  NSDictionary *_plotThemeAttributes = @{
                                         //线下的颜色
                                         kPlotFillColorKey : [UIColor clearColor],
                                         //线的宽度
                                         kPlotStrokeWidthKey : @1,
                                         //线的颜色
                                         kPlotStrokeColorKey : [UIColor colorWithRed:0.675 green:0.637 blue:1.000 alpha:1.000],
                                         //折点的颜色
                                         kPlotPointFillColorKey : [UIColor colorWithRed:1.000 green:0.572 blue:0.525 alpha:1.000],
                                         //点击标注的字体
                                         kPlotPointValueFontKey : [UIFont fontWithName:@"TrebuchetMS" size:18]
                                         };
  
  _plot1.plotThemeAttributes = _plotThemeAttributes;
  [_lineGraph addPlot:_plot1];
  
  //You can as much `SHPlots` as you can in a `SHLineGraphView`
  
  [_lineGraph setupTheView];
  
  [self.view addSubview:_lineGraph];
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
