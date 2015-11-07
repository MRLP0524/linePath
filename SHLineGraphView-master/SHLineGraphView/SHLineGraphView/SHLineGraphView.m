// SHLineGraphView.m
//
// Copyright (c) 2014 Shan Ul Haq (http://grevolution.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "SHLineGraphView.h"
#import "PopoverView.h"
#import "SHPlot.h"
#import <math.h>
#import <objc/runtime.h>

#define BOTTOM_MARGIN_TO_LEAVE 30.0
#define TOP_MARGIN_TO_LEAVE 30.0
#define INTERVAL_COUNT 9
#define PLOT_WIDTH (self.bounds.size.width - _leftMarginToLeave)

#define kAssociatedPlotObject @"kAssociatedPlotObject"


@implementation SHLineGraphView
{
    float _leftMarginToLeave;
}
- (instancetype)init {
    if((self = [super init])) {
        [self loadDefaultTheme];
    }
    return self;
}

- (void)awakeFromNib
{
    [self loadDefaultTheme];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadDefaultTheme];
    }
    return self;
}

- (void)loadDefaultTheme {
    _themeAttributes = @{
                         kXAxisLabelColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                         kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                         kYAxisLabelColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                         kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                         kYAxisLabelSideMarginsKey : @10,
                         kPlotBackgroundLineColorKye : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4]
                         };
}

- (void)addPlot:(SHPlot *)newPlot;
{
    if(nil == newPlot) {
        return;
    }
    
    if(_plots == nil){
        _plots = [NSMutableArray array];
    }
    [_plots addObject:newPlot];
}

- (void)setupTheView
{
    for(SHPlot *plot in _plots) {
        [self drawPlotWithPlot:plot];
    }
}

#pragma mark - Actual Plot Drawing Methods

- (void)drawPlotWithPlot:(SHPlot *)plot {
    //draw y-axis labels. this has to be done first, so that we can determine the left margin to leave according to the
    //y-axis lables.
    [self drawYLabels:plot];
    
    //draw x-labels
    [self drawXLabels:plot];
    
    //draw the grey lines
    [self drawLines:plot];
    
    /*
     actual plot drawing
     */
    [self drawPlot:plot];
}

- (int)getIndexForValue:(NSNumber *)value forPlot:(SHPlot *)plot {
    for(int i=0; i< _xAxisValues.count; i++) {
        NSDictionary *d = [_xAxisValues objectAtIndex:i];
        __block BOOL foundValue = NO;
        [d enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSNumber *k = (NSNumber *)key;
            if([k doubleValue] == [value doubleValue]) {
                foundValue = YES;
                *stop = foundValue;
            }
        }];
        if(foundValue){
            return i;
        }
    }
    return -1;
}
//绘制点的方法
- (void)drawPlot:(SHPlot *)plot {
    
    NSDictionary *theme = plot.plotThemeAttributes;
    
    //逻辑填充图的路径
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.frame = self.bounds;
    backgroundLayer.fillColor = ((UIColor *)theme[kPlotFillColorKey]).CGColor;
    backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
    [backgroundLayer setStrokeColor:[UIColor clearColor].CGColor];
    [backgroundLayer setLineWidth:((NSNumber *)theme[kPlotStrokeWidthKey]).intValue];
    //构造路径(CGPathCreateMutable) 一系列点放在一起,构成了一个形状。一系列的形状放在一起,构成了一个路径
    CGMutablePathRef backgroundPath = CGPathCreateMutable();
    
    //圈层的路径
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = self.bounds;
    circleLayer.fillColor = ((UIColor *)theme[kPlotPointFillColorKey]).CGColor;
    circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    [circleLayer setStrokeColor:((UIColor *)theme[kPlotPointFillColorKey]).CGColor];
    [circleLayer setLineWidth:((NSNumber *)theme[kPlotStrokeWidthKey]).intValue];
    //构造路径(CGPathCreateMutable) 一系列点放在一起,构成了一个形状。一系列的形状放在一起,构成了一个路径
    CGMutablePathRef circlePath = CGPathCreateMutable();
    
    //后台的路径
    CAShapeLayer *graphLayer = [CAShapeLayer layer];
    graphLayer.frame = self.bounds;
    graphLayer.fillColor = [UIColor clearColor].CGColor;
    graphLayer.backgroundColor = [UIColor clearColor].CGColor;
    [graphLayer setStrokeColor:((UIColor *)theme[kPlotStrokeColorKey]).CGColor];
    [graphLayer setLineWidth:((NSNumber *)theme[kPlotStrokeWidthKey]).intValue];
    //构造路径(CGPathCreateMutable) 一系列点放在一起,构成了一个形状。一系列的形状放在一起,构成了一个路径
    CGMutablePathRef graphPath = CGPathCreateMutable();
    //Y轴坐标的数值
    double yRange = [_yAxisRange doubleValue]; // this value will be in dollars
    //Y轴之间文字之间的间距
    double yIntervalValue = yRange / INTERVAL_COUNT;

    //逻辑填充图的路径，圈层的路径，后台的路径。
    [plot.plottingValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        
        __block NSNumber *_key = nil;
        __block NSNumber *_value = nil;
        
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            _key = (NSNumber *)key;
            _value = (NSNumber *)obj;
        }];
        //当前具体的点的个数
        int xIndex = [self getIndexForValue:_key forPlot:plot];
        //x value
        double height = self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE;
        double y = height - ((height / ([_yAxisRange doubleValue] + yIntervalValue)) * [_value doubleValue]);
        //点的具体位置坐标
        (plot.xPoints[xIndex]).x = ceil((plot.xPoints[xIndex]).x);
        (plot.xPoints[xIndex]).y = ceil(y);
    }];
    
    //移动到初始点的路径和背景。
    CGPathMoveToPoint(graphPath, NULL, _leftMarginToLeave, plot.xPoints[0].y);
    CGPathMoveToPoint(backgroundPath, NULL, _leftMarginToLeave, plot.xPoints[0].y);
    //具体点的个数
    int count = _xAxisValues.count;
    for(int i=0; i< count; i++){
        CGPoint point = plot.xPoints[i];
        //点的线路的开始位置
        CGPathAddLineToPoint(graphPath, NULL, point.x, point.y);
        CGPathAddLineToPoint(backgroundPath, NULL, point.x, point.y);
        //点的位置和大小
        CGPathAddEllipseInRect(circlePath, NULL, CGRectMake(point.x - 5, point.y - 5, 10, 10));
    }
    
    //移动结束点的路径和背景。
    CGPathAddLineToPoint(graphPath, NULL, _leftMarginToLeave + PLOT_WIDTH , plot.xPoints[count -1].y);
    CGPathAddLineToPoint(backgroundPath, NULL, _leftMarginToLeave + PLOT_WIDTH, plot.xPoints[count - 1].y);
    
    //背景附加点的位置和坐标
    CGPathAddLineToPoint(backgroundPath, NULL, _leftMarginToLeave + PLOT_WIDTH , self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE);
    CGPathAddLineToPoint(backgroundPath, NULL, _leftMarginToLeave, self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE);
    CGPathCloseSubpath(backgroundPath);
    
    backgroundLayer.path = backgroundPath;
    graphLayer.path = graphPath;
    circleLayer.path = circlePath;
    
    //动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 1;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    [graphLayer addAnimation:animation forKey:@"strokeEnd"];
    
    backgroundLayer.zPosition = 0;
    graphLayer.zPosition = 1;
    circleLayer.zPosition = 2;
    
    [self.layer addSublayer:graphLayer];
    [self.layer addSublayer:circleLayer];
    [self.layer addSublayer:backgroundLayer];
    //附加的 button 的位置和点击事件
    NSUInteger count2 = _xAxisValues.count;
    for(int i=0; i< count2; i++){
        CGPoint point = plot.xPoints[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = i;
        btn.frame = CGRectMake(point.x - 20, point.y - 20, 40, 40);
        [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(btn, kAssociatedPlotObject, plot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self addSubview:btn];
    }
}

- (void)drawXLabels:(SHPlot *)plot {
    //获取横坐标个数
    int xIntervalCount = _xAxisValues.count;
    //获取每一个数值之间的间距为多少像素
    double xIntervalInPx = PLOT_WIDTH / _xAxisValues.count;
    //初始化点的位置将为的实际的点的位置数值
    plot.xPoints = calloc(sizeof(CGPoint), xIntervalCount);
    //根据点的个数进行循环
    for(int i=0; i < xIntervalCount; i++){
        //第一个点的初始位置
        CGPoint currentLabelPoint = CGPointMake((xIntervalInPx * i) + _leftMarginToLeave , self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE);
        //横轴下方提示性文字的具体位置        (前面两个参数是具体位置,后面两个参数是提示文字占得位置大小)
        CGRect xLabelFrame = CGRectMake(currentLabelPoint.x , currentLabelPoint.y, xIntervalInPx, BOTTOM_MARGIN_TO_LEAVE);
        //具体点的位置坐标
        plot.xPoints[i] = CGPointMake((int) xLabelFrame.origin.x + (xLabelFrame.size.width /2) , (int) 0);
        
        UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:xLabelFrame];
        xAxisLabel.backgroundColor = [UIColor clearColor];
        xAxisLabel.font = (UIFont *)_themeAttributes[kXAxisLabelFontKey];
        xAxisLabel.textColor = (UIColor *)_themeAttributes[kXAxisLabelColorKey];
        xAxisLabel.textAlignment = NSTextAlignmentCenter;
        
        NSDictionary *dic = [_xAxisValues objectAtIndex:i];
        __block NSString *xLabel = nil;
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            xLabel = (NSString *)obj;
        }];
        
        xAxisLabel.text = [NSString stringWithFormat:@"%@", xLabel];
        [self addSubview:xAxisLabel];
    }
}

- (void)drawYLabels:(SHPlot *)plot {
    double yRange = [_yAxisRange doubleValue]; // this value will be in dollars
    //!!!: 在这里修改具体参数
    double yIntervalValue = yRange / 20;
    double intervalInPx = (self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE ) / (INTERVAL_COUNT +1);
    //!!!:标识的距离
    NSMutableArray *labelArray = [NSMutableArray array];
    float maxWidth = 0;
    //!!!: 标识的个数
    for(int i= INTERVAL_COUNT + 1; i >= 0; i--){
        CGPoint currentLinePoint = CGPointMake(_leftMarginToLeave, i * intervalInPx);
        CGRect lableFrame = CGRectMake(0, currentLinePoint.y - (intervalInPx / 2), 100, intervalInPx);
        
        if(i != 0) {
            //竖轴左侧提示性文字
            UILabel *yAxisLabel = [[UILabel alloc] initWithFrame:lableFrame];
            yAxisLabel.backgroundColor = [UIColor clearColor];
            yAxisLabel.font = (UIFont *)_themeAttributes[kYAxisLabelFontKey];
            yAxisLabel.textColor = (UIColor *)_themeAttributes[kYAxisLabelColorKey];
            yAxisLabel.textAlignment = NSTextAlignmentCenter;
            //竖轴显示具体数值
            float val = (yIntervalValue * (10 - i));
            if(val > 0){
                //如果数值是大于0的话,后面跟上具体的参数单位
                yAxisLabel.text = [NSString stringWithFormat:@"%.1f%@", val, _yAxisSuffix];
            } else {
                //等于0时,不带参数坐标
                yAxisLabel.text = [NSString stringWithFormat:@"%.0f", val];
            }
            [yAxisLabel sizeToFit];
            //设置新的坐标文字具体位置
            CGRect newLabelFrame = CGRectMake(0, currentLinePoint.y - (yAxisLabel.layer.frame.size.height / 2), yAxisLabel.frame.size.width, yAxisLabel.layer.frame.size.height);
            yAxisLabel.frame = newLabelFrame;
            //需要判断,如果新的位置大于之前的位置,才去使用新的坐标
            if(newLabelFrame.size.width > maxWidth) {
                maxWidth = newLabelFrame.size.width;
            }
            
            [labelArray addObject:yAxisLabel];
            [self addSubview:yAxisLabel];
        }
    }
    //竖轴提示性文字横向距离
    _leftMarginToLeave = maxWidth + [_themeAttributes[kYAxisLabelSideMarginsKey] doubleValue];
    for( UILabel *l in labelArray) {
        CGSize newSize = CGSizeMake(_leftMarginToLeave, l.frame.size.height);
        CGRect newFrame = l.frame;
        newFrame.size = newSize;
        l.frame = newFrame;
    }
}
//绘制线
- (void)drawLines:(SHPlot *)plot {
    //线的图层
    CAShapeLayer *linesLayer = [CAShapeLayer layer];
    linesLayer.frame = self.bounds;
    linesLayer.fillColor = [UIColor clearColor].CGColor;
    linesLayer.backgroundColor = [UIColor clearColor].CGColor;
    linesLayer.strokeColor = ((UIColor *)_themeAttributes[kPlotBackgroundLineColorKye]).CGColor;
    linesLayer.lineWidth = 1;
    
    CGMutablePathRef linesPath = CGPathCreateMutable();
    //每条线之间的间距
    double intervalInPx = (self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE) / (INTERVAL_COUNT + 1);
    for(int i= INTERVAL_COUNT + 1; i > 0; i--){
        //将对应点的数值转换为具体的坐标
        CGPoint currentLinePoint = CGPointMake(_leftMarginToLeave, (i * intervalInPx));
        //绘制横线的起点
        CGPathMoveToPoint(linesPath, NULL, currentLinePoint.x , currentLinePoint.y);
        //绘制横线的距离长度
        CGPathAddLineToPoint(linesPath, NULL, currentLinePoint.x + PLOT_WIDTH, currentLinePoint.y);
    }
    
    //获取横坐标个数
    int xIntervalCount = _xAxisValues.count;
    //获取每一个数值之间的间距为多少像素
    double xIntervalInPx = PLOT_WIDTH / _xAxisValues.count;
    
    double intervalInPx1 = (self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE ) / (INTERVAL_COUNT+1) *INTERVAL_COUNT;
    
    //根据点的个数进行循环
    for(int i=0; i < xIntervalCount; i++){
        //第一个点的初始位置
        CGPoint currentLabelPoint = CGPointMake((xIntervalInPx * i) + _leftMarginToLeave , self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE);
        
        
        
        //绘制横线的起点
        CGPathMoveToPoint(linesPath, NULL, currentLabelPoint.x + xIntervalInPx/2 , currentLabelPoint.y);
        //绘制横线的距离长度
        CGPathAddLineToPoint(linesPath, NULL, currentLabelPoint.x + xIntervalInPx/2, currentLabelPoint.y - intervalInPx1);
       
    }
    //绘制横线的起点
    CGPathMoveToPoint(linesPath, NULL,_leftMarginToLeave ,BOTTOM_MARGIN_TO_LEAVE);
    //绘制横线的距离长度
    CGPathAddLineToPoint(linesPath, NULL,_leftMarginToLeave ,self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE );
    
    
    linesLayer.path = linesPath;
    [self.layer addSublayer:linesLayer];
}

#pragma mark - UIButton event methods
//点击事件
- (void)clicked:(id)sender
{
    @try {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
        lbl.backgroundColor = [UIColor clearColor];
        UIButton *btn = (UIButton *)sender;
        NSUInteger tag = btn.tag;
        
        SHPlot *_plot = objc_getAssociatedObject(btn, kAssociatedPlotObject);
        NSString *text = [_plot.plottingPointsLabels objectAtIndex:tag];
        
        lbl.text = text;
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = (UIFont *)_plot.plotThemeAttributes[kPlotPointValueFontKey];
        [lbl sizeToFit];
        lbl.frame = CGRectMake(0, 0, lbl.frame.size.width + 5, lbl.frame.size.height);
        
        CGPoint point =((UIButton *)sender).center;
        point.y -= 15;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [PopoverView showPopoverAtPoint:point
                                     inView:self
                            withContentView:lbl
                                   delegate:nil];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"plotting label is not available for this point");
    }
}

#pragma mark - Theme Key Extern Keys

NSString *const kXAxisLabelColorKey         = @"kXAxisLabelColorKey";
NSString *const kXAxisLabelFontKey          = @"kXAxisLabelFontKey";
NSString *const kYAxisLabelColorKey         = @"kYAxisLabelColorKey";
NSString *const kYAxisLabelFontKey          = @"kYAxisLabelFontKey";
NSString *const kYAxisLabelSideMarginsKey   = @"kYAxisLabelSideMarginsKey";
NSString *const kPlotBackgroundLineColorKye = @"kPlotBackgroundLineColorKye";

@end
