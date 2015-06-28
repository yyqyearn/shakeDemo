//
//  UIColor+yyq.h
//  Singtel
//
//  Created by yyq on 14-9-18.
//  Copyright (c) 2014年 mobilenow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (yyq)
/**
 *  根据十六进制参数返回颜色
 */
+ (UIColor *)colorWithHexString: (NSString *)color;

+ (UIColor *)colorWithHexString: (NSString *)color alpha:(CGFloat)alpha;

/**
 *  返回项目中通用蓝色
 */
+ (UIColor *)colorWithSportsBlue;
@end
