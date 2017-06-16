//
//  SelectImageCollectionViewCell.m
//  SkyHospital
//
//  Created by ZY on 15-1-5.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import "SelectImageCollectionViewCell.h"

@implementation SelectImageCollectionViewCell
@synthesize myImageView,unSelectView,selectView;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        myImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:myImageView];
        
        unSelectView = [[UIImageView alloc]initWithFrame:CGRectMake(myImageView.frame.size.width-17, 2, 15, 15)];
        unSelectView.backgroundColor = [UIColor clearColor];
        unSelectView.image = [UIImage imageNamed:@"bg_checkbox_image_unselect"];
        unSelectView.hidden = YES;
        [self addSubview:unSelectView];
        
        selectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        selectView.backgroundColor = [UIColor colorWithRed:0.991 green:1.000 blue:0.941 alpha:0.6];
        selectView.hidden = YES;
        
        UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(myImageView.frame.size.width-17, 2, 15, 15)];
        selectImageView.backgroundColor = [UIColor clearColor];
        selectImageView.image = [UIImage imageNamed:@"bg_checkbox_pressed"];
        [selectView addSubview:selectImageView];
        [self addSubview:selectView];
    }
    return self;
}

@end

@implementation PublicCollectionViewCell

@synthesize myImageView;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 45, 45)];
        myImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:myImageView];
        
        _deleteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(myImageView.frame.size.width-15, 0, 15, 15)];
        _deleteImageView.backgroundColor = [UIColor clearColor];
        _deleteImageView.userInteractionEnabled = YES;
        _deleteImageView.image = [UIImage imageNamed:@"circle_public_delete"];
        _deleteImageView.hidden = YES;
        [self addSubview:_deleteImageView];
    }
    return self;
}

@end