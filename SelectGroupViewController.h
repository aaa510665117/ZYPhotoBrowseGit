//
//  SelectGroupViewController.h
//  SkyHospital
//
//  Created by ZY on 15-1-6.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^CompleteBlock)(NSMutableArray *);   //外部接口，用于处理选择完成后的方法

@interface SelectGroupViewController : UIViewController

@property(nonatomic, retain)NSString * saveImagePath;  //图片临时保存路径

@property(nonatomic, assign)long maxPhotoNumber;       //最大图片数量

@property(nonatomic, copy)CompleteBlock completeBlock;

@end
