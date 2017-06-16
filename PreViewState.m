//
//  PreViewState.m
//  SkyHospital
//
//  Created by ZY on 15-1-7.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import "PreViewState.h"

@implementation PreViewState

static PreViewState * state = nil;

+ (PreViewState *)viewStateForView:(UIView *)view {
    if(state == nil) {
        state = [[PreViewState alloc]init];
    }
    return state;
}

- (void)setStateWithView:(UIView *)view {
    CGAffineTransform trans = view.transform;
    view.transform = CGAffineTransformIdentity;
    
    self.superview = view.superview;
    self.frame     = view.frame;
    self.transform = trans;
    self.userInteratctionEnabled = view.userInteractionEnabled;
    
    view.transform = trans;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
