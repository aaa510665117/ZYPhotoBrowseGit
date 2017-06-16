//
//  SelectImageViewController.m
//  SkyHospital
//
//  Created by ZY on 15-1-5.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import "SelectImageViewController.h"
#import "SelectImageCollectionViewCell.h"
//#import "ToolsFunction.h"
#import<AssetsLibrary/AssetsLibrary.h>
//#import "Definition.h"
#import "PreViewPhotoView.h"

// 缩略图的上边距
#define CIRCLE_THUMBNAILVIEW_IMAGE_TOPMARGIN    5
// 缩略图的下边距
#define CIRCLE_THUMBNAILVIEW_IMAGE_DOWNMARGIN   5
// 缩略图的左边距
#define CIRCLE_THUMBNAILVIEW_IMAGE_LEFTMARGIN   5
// 缩略图的间距
#define CIRCLE_THUMBNAILVIEW_IMAGE_MARGIN       5
// 缩略图的宽度
#define CIRCLE_THUMBNAILVIEW_IMAGE_WIDTH       46
// 缩略图的高度
#define CIRCLE_THUMBNAILVIEW_IMAGE_HEIGHT      46
// 缩略图缩放时最长边的长度
#define CIRCLE_IMAGE_LONGEST_LENGHT            1024.0f

#define MAX_PHOTO_NUM_CIRCLE                    9

@interface SelectImageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray * temp;
    NSMutableArray * dataArray;
    NSMutableArray * selectImageArray;
    NSMutableArray * groupArray;
    NSMutableArray * groupImageArray;
    BOOL isViewDidLoad;
}

@property(nonatomic, retain)UICollectionViewFlowLayout * flowLayout;
@property(nonatomic, retain)UICollectionView * collection;
@property(nonatomic, retain)UILabel * photoCount;

@end

@implementation SelectImageViewController
@synthesize collection,flowLayout,photoCount;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *canelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    canelButton.backgroundColor = [UIColor clearColor];
    canelButton.titleLabel.font = [UIFont systemFontOfSize: 16];
    canelButton.frame = CGRectMake(0, 0, 48, 22);
    [canelButton setTitle:@"取消" forState:UIControlStateNormal];
    [canelButton addTarget:self action:@selector(clickCanelButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchNaviButton = [[UIBarButtonItem alloc]initWithCustomView:canelButton];
    
    self.navigationItem.rightBarButtonItems = @[searchNaviButton];
    
    // Do any additional setup after loading the view.
    temp = [[NSMutableArray alloc]init];
    dataArray = [[NSMutableArray alloc]init];
    selectImageArray = [[NSMutableArray alloc]init];
    groupArray = [[NSMutableArray alloc]init];
    groupImageArray = [[NSMutableArray alloc]init];
    _groupType = [[NSString alloc]init];
    [self initView];
    [self getImgs];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    UIImage *navigationBarBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nav_bg_ios7" ofType:@"png"]];
    
    [[UINavigationBar appearance] setBackIndicatorImage:navigationBarBackgroundImage];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg_ios7"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if([_groupType isEqualToString:@""])
    {
        [self getGroup];
    }
}

-(void)clickCanelButton
{
    long index=[[self.navigationController viewControllers]indexOfObject:self];
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
}

-(void)initView
{
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //flowLayout.itemSize = CGSizeMake(20, 100);
    flowLayout.minimumInteritemSpacing = 0;//列距
    
    collection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44) collectionViewLayout:flowLayout];
    [collection registerClass:[SelectImageCollectionViewCell class] forCellWithReuseIdentifier:@"GradientCell"];
    collection.delegate = self;
    collection.dataSource = self;
    collection.backgroundColor = [UIColor clearColor];
        
    [self.view addSubview:collection];
    
    UIView * underView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    underView.backgroundColor = [UIColor colorWithRed:0.899 green:0.931 blue:0.846 alpha:1.000];
    
    UIButton * preview = [[UIButton alloc]initWithFrame:CGRectMake(10, underView.frame.size.height/2-15, 60, 30)];
    [preview setBackgroundImage:[UIImage imageNamed:@"confirm_button_nor"] forState:UIControlStateNormal];
    [preview setBackgroundImage:[UIImage imageNamed:@"confirm_button_pre"] forState:UIControlStateSelected];
    [preview setTitle:@"预览" forState:UIControlStateNormal];
    preview.layer.cornerRadius = 6.0;
    preview.layer.masksToBounds = YES;
    [preview addTarget:self action:@selector(clickPreView) forControlEvents:UIControlEventTouchUpInside];
    [underView addSubview:preview];
    
    photoCount = [[UILabel alloc]initWithFrame:CGRectMake(underView.frame.size.width/2-50, underView.frame.size.height/2-10, 100, 20)];
    photoCount.backgroundColor = [UIColor clearColor];
    photoCount.font = [UIFont systemFontOfSize:15];
    photoCount.textAlignment = NSTextAlignmentCenter;
    photoCount.text = [NSString stringWithFormat:@"共%lu张照片",dataArray.count];
    [underView addSubview:photoCount];
    
    UIButton * sureButton = [[UIButton alloc]initWithFrame:CGRectMake(underView.frame.size.width-70, underView.frame.size.height/2-15, 60, 30)];
    [sureButton setBackgroundImage:[UIImage imageNamed:@"confirm_button_nor"] forState:UIControlStateNormal];
    [sureButton setBackgroundImage:[UIImage imageNamed:@"confirm_button_pre"] forState:UIControlStateSelected];
    [sureButton setTitle:@"完成" forState:UIControlStateNormal];
    sureButton.layer.cornerRadius = 6.0;
    sureButton.layer.masksToBounds = YES;
    [sureButton addTarget:self action:@selector(clickSureButton) forControlEvents:UIControlEventTouchUpInside];
    [underView addSubview:sureButton];
    
    [self.view addSubview:underView];
}

-(void)clickPreView
{
    NSMutableArray * imageArray = [[NSMutableArray alloc]init];
    
    for(int i=0; i<selectImageArray.count; i++)
    {
        ALAssetsLibrary *assetLibraryT=[[ALAssetsLibrary alloc] init];
        NSURL * urlT=[NSURL URLWithString:[selectImageArray objectAtIndex:i]];
        [assetLibraryT assetForURL:urlT resultBlock:^(ALAsset *asset)  {
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            UIImageView * imageView = [[UIImageView alloc]init];
            imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            imageView.backgroundColor = [UIColor clearColor];
            imageView.image = image;
            [imageArray addObject:imageView];
            
            if(imageArray.count == selectImageArray.count)
            {
                PreViewPhotoView * preView = [[PreViewPhotoView alloc]init];
                [preView showWithImageViews:imageArray withSelectImageView:[imageArray objectAtIndex:0]];
            }
            
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }];
    }

}

-(void)clickSureButton
{
    //完成
    // 保存到临时目录中（在显示这个view时已经建好文件夹）
    
    NSMutableArray * imageArray = [[NSMutableArray alloc]init];
    
    for(int i=0; i<selectImageArray.count; i++)
    {
        ALAssetsLibrary *assetLibraryT=[[ALAssetsLibrary alloc] init];
        NSURL * urlT=[NSURL URLWithString:[selectImageArray objectAtIndex:i]];
        [assetLibraryT assetForURL:urlT resultBlock:^(ALAsset *asset)  {
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];

            // 将图片处理成最长边不能超过1024
            CGSize sizeFixed = [self imageSizeFix:image.size];
            image = [self scaleImageSize:image toSize:sizeFixed];
            [self saveImage:image];
            [imageArray addObject:image];
            
            if(imageArray.count == selectImageArray.count)
            {
                _completeBlock(imageArray);
            }
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }];
    }
    
    long index=[[self.navigationController viewControllers]indexOfObject:self];
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
}

#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage
{
    //为nil说明这些图片不需要保存至沙盒，直接进行处理
    if(self.saveImagePath == nil)
    {
        return;
    }
    
    static int num = 1;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if ([manager fileExistsAtPath:self.saveImagePath isDirectory:&isDirectory])
    {
        NSArray *filesArray = [manager contentsOfDirectoryAtPath:self.saveImagePath error:nil];
        if ([filesArray count] > 0)
        {
            [filesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray * tmp = [obj componentsSeparatedByString:@"."];
                NSString * numStr = [tmp objectAtIndex:0];
                
                if(num <= [numStr intValue])
                {
                    num = [numStr intValue];
                    num++;
                }
            }];
        }
    }
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    NSString *fullPath = [self.saveImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg",num]];
    
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}

//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectImageCollectionViewCell *cell = (SelectImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GradientCell" forIndexPath:indexPath];
    
        //------------------------根据图片的url反取图片－－－－－

    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    NSURL *url=[NSURL URLWithString:[dataArray objectAtIndex:indexPath.row]];
    
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
        
        __block UIImage *image=[UIImage imageWithCGImage:asset.thumbnail];
        
        cell.myImageView.image=image;
        
        if([selectImageArray containsObject:[dataArray objectAtIndex:indexPath.row]])
        {
            cell.selectView.hidden = NO;
            cell.unSelectView.hidden = YES;
        }
        else
        {
            cell.selectView.hidden = YES;
            cell.unSelectView.hidden = NO;
        }
        
    }failureBlock:^(NSError *error) {
        NSLog(@"error=%@",error);
    }
        ];
    //}
    //－－－－－－－－－－－－－－－－－－－－－

    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60, 60);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectImageCollectionViewCell * cell = (SelectImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if([selectImageArray containsObject:[dataArray objectAtIndex:indexPath.row]])
    {
        [selectImageArray removeObject:[dataArray objectAtIndex:indexPath.row]];
        cell.selectView.hidden = YES;
        cell.unSelectView.hidden = NO;
    }
    else
    {
        if(selectImageArray.count > _maxPhotoNumber)
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"不能添加更多图片哦～"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            [alert show];
            return;
        }
        
        [selectImageArray addObject:[dataArray objectAtIndex:indexPath.row]];
        cell.selectView.hidden = NO;
        cell.unSelectView.hidden = YES;
    }
    
    if(selectImageArray.count != 0)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"已选择%ld张",(unsigned long)selectImageArray.count];
    }
    else
    {
        self.navigationItem.title = @"";
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)getImgs{
    
    dispatch_async(dispatch_get_main_queue(), ^{

        //[ToolsFunction showWaitingPromptViewWithString:@"请稍等"];
        
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };
        
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result,NSUInteger index, BOOL *stop){
            if (result!=NULL)
            {
                
                if ([[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {
                    
                    NSString *urlstr=[NSString stringWithFormat:@"%@",[result defaultRepresentation].url];//图片的url
                    /*result.defaultRepresentation.fullScreenImage//图片的大图
                     result.thumbnail                            //图片的缩略图小图
                     //                    NSRange range1=[urlstr rangeOfString:@"id="];
                     //                    NSString *resultName=[urlstr substringFromIndex:range1.location+3];
                     //                    resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
                     */
                    
                    //[temp addObject:urlstr];
                    //去重
                    if(![dataArray containsObject:urlstr])
                    {
                        [dataArray addObject:urlstr];
                    }
                    
                    [collection reloadData];

                }
            }
            /*
            //去掉相同的--优化
            [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if([dataArray containsObject:obj])
                {
                    
                }
                else
                {
                    [dataArray addObject:obj];
                }
            }];
             */
            [collection reloadData];
            
            
            //底部定位
            NSInteger section = [self numberOfSectionsInCollectionView:self.collection] - 1;
            NSInteger item = [self collectionView:self.collection numberOfItemsInSection:section] - 1;
            NSIndexPath*  lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [collection scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            
            photoCount.text = [NSString stringWithFormat:@"共%lu张照片",(unsigned long)dataArray.count];
            
            //[ToolsFunction removeMaskView];

        };
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop){
            
            if (group!=nil)
            {
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                
                NSString *g1=[g substringFromIndex:16 ] ;
                NSArray *arr=[NSArray arrayWithArray:[g1 componentsSeparatedByString:@","]];
                NSString * name = [[arr objectAtIndex:0] substringFromIndex:5];
                NSString * type = [[arr objectAtIndex:1] substringFromIndex:6];
                if([_groupType isEqualToString:@""])
                {
                    if([type isEqualToString:@"Saved Photos"])
                    {
                        [group enumerateAssetsUsingBlock:groupEnumerAtion];
                    }
                }
                else
                {
                    if([_groupType isEqualToString:name])
                    {
                        [group enumerateAssetsUsingBlock:groupEnumerAtion];
                    }
                }
            }
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:failureblock];
        
    });
    

}

-(void)getGroup
{
    @autoreleasepool
    {
        ALAssetsLibraryAccessFailureBlock failureblock =
        ^(NSError *myerror)
        {
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop)
        {
            if (group!=nil)
            {
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71

                NSString *g1=[g substringFromIndex:16 ] ;
                NSArray *arr=[NSArray arrayWithArray:[g1 componentsSeparatedByString:@","]];
                
                //去掉照片流
                if(![[[arr objectAtIndex:1] substringFromIndex:6] isEqualToString:@"Photo Stream"])
                {
                    [groupArray addObject:arr];
                    
                    CGImageRef posterImageRef = [group posterImage];
                    
                    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
                    [groupImageArray addObject:posterImage];
                }
                
            }
            
            _groupBlock(groupArray,groupImageArray);
        };
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];

        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                          usingBlock:libraryGroupsEnumeration
                                          failureBlock:failureblock];
    }
}



- (CGSize)imageSizeFix:(CGSize)sourceImageSize{
    
    float imageHeight = sourceImageSize.height;
    float imageWidth = sourceImageSize.width;
    float rate = 0.0;
    
    if ((imageWidth > CIRCLE_IMAGE_LONGEST_LENGHT) ||
        (imageHeight > CIRCLE_IMAGE_LONGEST_LENGHT))
    {
        if (imageWidth > imageHeight)
        {
            rate = CIRCLE_IMAGE_LONGEST_LENGHT / imageWidth;
            imageWidth = CIRCLE_IMAGE_LONGEST_LENGHT;
            imageHeight = imageHeight * rate;
        }
        else {
            rate = CIRCLE_IMAGE_LONGEST_LENGHT / imageHeight;
            imageHeight = CIRCLE_IMAGE_LONGEST_LENGHT;
            imageWidth = imageWidth * rate;
        }
    }
    
    return CGSizeMake(imageWidth, imageHeight);
    
}

-(void)setBlock:(void (^)(NSMutableArray *))block
{
    if(block)
    {
        _completeBlock = block;
    }
}

-(void)setGroupBlock:(GroupBlock)groupBlock
{
    if(groupBlock)
    {
        _groupBlock = groupBlock;
    }
}

// 把image缩放到给定的size
- (UIImage *)scaleImageSize:(UIImage *)sourceImage toSize:(CGSize)imageSize
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(imageSize);
    // 绘制改变大小的图片
    [sourceImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
