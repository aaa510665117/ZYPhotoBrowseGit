//
//  SelectImageCollectionViewCell.h
//  SkyHospital
//
//  Created by ZY on 15-1-5.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectImageCollectionViewCell : UICollectionViewCell

@property(nonatomic, retain)UIImageView * myImageView;

@property(nonatomic, retain)UIImageView * unSelectView;

@property(nonatomic, retain)UIView * selectView;

@end

@interface PublicCollectionViewCell : UICollectionViewCell

@property(nonatomic, retain)UIImageView * myImageView;

@property(nonatomic, retain)UIImageView * deleteImageView;

@end
