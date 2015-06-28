//
//  YQActivityView.m
//  shakeDemo
//
//  Created by Yongqi on 15/6/25.
//  Copyright (c) 2015年 Yongqi. All rights reserved.
//
#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
#define  PROGREESS_WIDTH 80 //圆直径
#define PROGRESS_LINE_WIDTH 4 //弧线的宽度


#import "YQActivityView.h"
#import "UIBezierPath+curved.h"
#import "UIColor+yyq.h"

@interface YQActivityView ()
@property (strong, nonatomic) NSArray *points;
@property (assign, nonatomic) NSInteger shakeRank;

//@property (strong, nonatomic) CAShapeLayer *lineLayer1;
//@property (strong, nonatomic) CAShapeLayer *lineLayer2;
@property (strong, nonatomic) NSMutableArray *lineLayers;

@property (strong, nonatomic) NSArray *colorHexs;


@property (assign, nonatomic) int linesCount;

@property (assign, nonatomic) BOOL zoomAnimation;

@end

@implementation YQActivityView
- (void)beginZoom{
    self.zoomAnimation = YES;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.9 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (self.zoomAnimation) {
                [self beginZoom];
            };
        }];
    }];
}
- (void)stopZoom{
    self.zoomAnimation = NO;
}
- (int)linesCount{
    if (_linesCount==0) {
        _linesCount = 6;
    }
    return _linesCount;
}
- (NSArray *)colorHexs{
    if (!_colorHexs) {
        _colorHexs = @[@"03AE17",@"21E90D",@"25FF09",@"A1EA8D",@"CFF1C2",@"FFFFFF"];
    }
    return _colorHexs;
}
- (NSMutableArray *)lineLayers
{
    if (!_lineLayers) {
        _lineLayers= [NSMutableArray array];
    }
    return _lineLayers;
}

- (NSArray *)points{
    if (_points) {
        return _points;
    }
    NSMutableArray *tempArr = [NSMutableArray array];
    int count = 30;
    //单位角度
    CGFloat angle = 360/count;
    //圆心点
    CGPoint center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    
    //半径增量系数
    CGFloat add = 2;
    if (self.shakeRank>ShakeRankA) {
        add = 3;
    }else if (self.shakeRank>ShakeRankC){
        add = 20;
    }
    for (int i = 0; i < count+1; i ++) {
        //点半径
        CGFloat radius = [self getRandomNumber:50 to:(50+add*(int)self.shakeRank)];
        CGFloat pAngle = angle * i;
        CGFloat x=0;
        CGFloat y=0;
        CGFloat aAngle = 0;
        if (pAngle<=90) {
            aAngle = degreesToRadians(pAngle);
            x = center.x + sin(aAngle) * radius;
            y = center.y - cos(aAngle) * radius;
        }else if (pAngle<=180){
            aAngle = degreesToRadians(pAngle-90);
            x = center.x + cos(aAngle) * radius;
            y = center.y + sin(aAngle) * radius;
        }else if (pAngle<=270){
            aAngle = degreesToRadians(pAngle-180);
            x = center.x - sin(aAngle) * radius;
            y = center.y + cos(aAngle) * radius;
        }else{
            aAngle = degreesToRadians(pAngle-270);
            x = center.x - cos(aAngle) * radius;
            y = center.y - sin(aAngle) * radius;
        }
//        NSLog(@"第%i个点，角度 = %f, x = %f , y = %f",i ,pAngle,x,y );
         NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
        if (i!=count) {
            [tempArr addObject:pointValue];
        }else{
            [tempArr addObject:[tempArr firstObject]];
        }
        
        
    }
    _points = tempArr;
    return _points;
}

- (void)updateWithShakeRank:(NSInteger)shakeRank
{
    self.shakeRank = shakeRank;
    self.points = nil;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {

    self.lineLayers = nil;
   
    //初始化路径
    UIBezierPath *bezPath = [UIBezierPath bezierPath];
    bezPath.lineCapStyle = kCGLineCapRound;//拐角处理
    bezPath.lineJoinStyle = kCGLineCapRound;//终点处理

    
    for (int i = 0; i < self.points.count; i ++) {
        NSValue * aPointValue = self.points[i];
        CGPoint point = [aPointValue CGPointValue];
        if (i==0) {
            [bezPath moveToPoint:point];
        }else{
            [bezPath addLineToPoint:point];
        }
        
    }
    
    
    [bezPath closePath];
    bezPath = [bezPath smoothedPathWithGranularity:20];

    //渐隐消失的时间，与rank有关
    CGFloat dur = 0;
    if (self.shakeRank < ShakeRankC) {
      dur = 0.2;
    }else if (self.shakeRank < ShakeRankD){
        dur = 0.3;
    }else{
        dur = 1;
    }
    
    
    for (int i = 0; i < self.shakeRank; i ++) {
        CAShapeLayer * contentLayer = [CAShapeLayer layer];
        contentLayer.fillColor = [UIColor clearColor].CGColor;
        contentLayer.frame = self.bounds;
        contentLayer.strokeColor = [UIColor colorWithHexString:self.colorHexs[self.colorHexs.count-i-1]].CGColor;
        contentLayer.lineWidth = 1.3;
        contentLayer.path = bezPath.CGPath;
        
        CGFloat trans = 1+0.15*i;
        contentLayer.transform = CATransform3DMakeScale(trans, trans, 1);
        
        [self.layer addSublayer:contentLayer];
        [self.lineLayers addObject:contentLayer];
        
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
            opacityAnimation.toValue = [NSNumber numberWithFloat:0];
            opacityAnimation.duration = dur;
            [contentLayer addAnimation:opacityAnimation forKey:@"opacity"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dur * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [contentLayer removeFromSuperlayer];
            });

        
    }

//    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//    opacityAnimation.toValue = [NSNumber numberWithFloat:0];
//    opacityAnimation.duration = 0.3;
//    [contentLayer addAnimation:opacityAnimation forKey:@"opacity"];
//    [contentLayer2 addAnimation:opacityAnimation forKey:@"opacity"];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [contentLayer removeFromSuperlayer];
//        [contentLayer2 removeFromSuperlayer];
//
//    });
    
//       CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    animation.fromValue = @0;
//    animation.toValue = @1;
//    animation.duration = 5;
////    animation.delegate = self;
//    [contentLayer addAnimation:animation forKey:@"MPStroke"];

    
    
    
//    [bezPath stroke];
    
//    //2.圆形
//    UIColor *pathColorA = [UIColor greenColor];
//    [pathColorA set];
//    CGRect rectA = CGRectMake(100, 100, 100, 200);
//    
//    UIBezierPath *bezPathA = [UIBezierPath bezierPathWithOvalInRect:rectA];
//    [bezPathA stroke];
    
}

-(int)getRandomNumber:(int)from to:(int)to

{
    return (int)(from + (arc4random() % (to - from + 1)));
}

@end
