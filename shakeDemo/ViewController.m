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
        _cmMotionManager.accelerometerUpdateInterval = 1.0 / 5.0;
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
}



#pragma mark - 事务方法
- (void)setupSubviews
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateShake) userInfo:nil repeats:YES];

}
- (void)updateShake
{
    [self.shakeView updateWithShakeRank:1];
}
- (void)startShake
{
    [self.timer invalidate];
    self.timer = nil;
//    _cmMotionManager = [[CMMotionManager alloc]init];
//    _cmMotionManager.accelerometerUpdateInterval = 1 / 5.0;
    
    NSOperationQueue * queue = [NSOperationQueue currentQueue];
    [self.cmMotionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        float x = fabs(accelerometerData.acceleration.x);
        float y = fabs(accelerometerData.acceleration.y);
        float z = fabs(accelerometerData.acceleration.z);
        float sum = x + y + z ;
        
    
        //得出摇晃等级；
        int shakeRank = ShakeRankN;
        if (sum<1.5) {
            shakeRank = ShakeRankA;
        }else if (sum<2.5){
            shakeRank = ShakeRankB;
        }else if (sum<4){
            shakeRank = ShakeRankC;
        }else if (sum<7){
            shakeRank = ShakeRankD;
        }else{
            shakeRank = ShakeRankE;
        }
        
        NSLog(@"摇晃等级 = %i",shakeRank);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shakeRankLabel.text = [NSString stringWithFormat:@"摇晃等级 = %i",shakeRank];
            [self.shakeView updateWithShakeRank:shakeRank];
        });
    }];
}

@end
