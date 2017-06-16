//
//  PreViewPhotoView.h
//  SkyHospital
//
//  Created by ZY on 15-1-7.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHImageViewer;
@protocol XHImageViewerDelegate <NSObject>

@optional
- (void)imageViewer:(XHImageViewer *)imageViewer  willDismissWithSelectedView:(UIImageView*)selectedView;

@end

@interface PreViewPhotoView : UIView

@property(nonatomic, assign)BOOL isHasRemove;       //是否删除

@property(nonatomic, retain)NSMutableArray * selectFrameView;

-(void)showWithImageViews:(NSArray *)images withSelectImageView:(UIImageView *)imageViews;

@end
