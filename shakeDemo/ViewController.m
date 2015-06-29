//
//  ViewController.m
//  shakeDemo
//
//  Created by Yongqi on 15/6/25.
//  Copyright (c) 2015年 Yongqi. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <math.h>

#import "YQActivityView.h"

@interface ViewController ()
@property (strong, nonatomic) CMMotionManager *cmMotionManager;
@property (weak, nonatomic) IBOutlet YQActivityView *shakeView;
@property (weak, nonatomic) IBOutlet UILabel *shakeRankLabel;


@property (strong, nonatomic) NSTimer *timer;

@end

@implementation ViewController

#pragma mark - 懒加载
- (CMMotionManager *)cmMotionManager
{
    if (!_cmMotionManager) {
        _cmMotionManager = [[CMMotionManager alloc]init];
        _cmMotionManager.accelerometerUpdateInterval = 1.0 / 20;
    }
    return _cmMotionManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
//    [self startShake];
}


#pragma mark - 点击事件
- (IBAction)startBtnClick:(UIButton *)sender {
    [self startShake];
}
- (IBAction)endBtnClick:(UIButton *)sender {
    [self stopShake];
}



#pragma mark - 事务方法
- (void)setupSubviews
{
    if (!self.shakeView.isZooming) {
        [self.shakeView beginZoom];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateShakeN) userInfo:nil repeats:YES];
}
- (void)updateShakeN
{
    [self.shakeView updateWithShakeRank:ShakeRankN];
}

- (void)stopShake{
    [self.cmMotionManager stopAccelerometerUpdates];
    [self setupSubviews];
}
- (void)startShake
{
    [self.timer invalidate];
    self.timer = nil;
//    _cmMotionManager = [[CMMotionManager alloc]init];
//    _cmMotionManager.accelerometerUpdateInterval = 1 / 5.0;
    
    NSOperationQueue * queue = [NSOperationQueue mainQueue];
    [self.cmMotionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        float x = fabs(accelerometerData.acceleration.x);
        float y = fabs(accelerometerData.acceleration.y);
        float z = fabs(accelerometerData.acceleration.z);
        float sum = x + y + z ;
        
    
        //得出摇晃等级；
        int shakeRank = ShakeRankN;
        if (sum<1.5) {
            shakeRank = ShakeRankA;
        }else if (sum<2){
            shakeRank = ShakeRankB;
        }else if (sum<2.5){
            shakeRank = ShakeRankC;
        }else if (sum<3){
            shakeRank = ShakeRankD;
        }else{
            shakeRank = ShakeRankE;
        }
        
        NSLog(@"摇晃等级 = %i",shakeRank);
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.shakeRankLabel.text = [NSString stringWithFormat:@"摇晃等级 = %i",shakeRank];
            [self.shakeView updateWithShakeRank:shakeRank];
//        });

        
        
    }];
}

@end
