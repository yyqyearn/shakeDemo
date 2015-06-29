//
//  YQActivityView.h
//  shakeDemo
//
//  Created by Yongqi on 15/6/25.
//  Copyright (c) 2015年 Yongqi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ShakeRank) {
    ShakeRankN = 1,
    ShakeRankA,
    ShakeRankB,
    ShakeRankC,
    ShakeRankD,
    ShakeRankE
};
@interface YQActivityView : UIView
@property (assign, nonatomic,getter=isZooming) BOOL zoomAnimation;

- (void)updateWithShakeRank:(NSInteger)shakeRank;
- (void)beginZoom;

@end
