//
//  SelectImageViewController.h
//  SkyHospital
//
//  Created by ZY on 15-1-5.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompleteBlock)(NSMutableArray *);   //外部接口，用于处理选择完成后的方法
typedef void (^GroupBlock) (NSMutableArray *,NSMutableArray *);

@interface SelectImageViewController : UIViewController

@property(nonatomic, retain)NSString * saveImagePath;  //图片临时保存路径

@property(nonatomic, assign)long maxPhotoNumber;       //最大图片数量

@property(nonatomic, retain)NSString * groupType;      //相册类型

@property(nonatomic, copy)CompleteBlock completeBlock;
@property(nonatomic, copy)GroupBlock groupBlock;

-(void)setBlock:(void(^)(NSMutableArray * imageArray))block;

-(void)setGroupBlock:(GroupBlock)groupBlock;
@end
