//
//  PreViewState.h
//  SkyHospital
//
//  Created by ZY on 15-1-7.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreViewState : UIView

@property (nonatomic, strong) UIView *superview;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) BOOL userInteratctionEnabled;
@property (nonatomic, assign) CGAffineTransform transform;

//单例
+ (PreViewState *)viewStateForView:(UIView *)view;
- (void)setStateWithView:(UIView *)view;

@end
