//
//  ZoomImageView.h
//  SkyHospital
//
//  Created by ZY on 15-1-7.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomImageView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, readonly) BOOL isViewing;

@end
