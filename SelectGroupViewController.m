//
//  SelectGroupViewController.m
//  SkyHospital
//
//  Created by ZY on 15-1-6.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import "SelectGroupViewController.h"
#import "SelectImageViewController.h"
//#import "ToolsFunction.h"
//#import "AppDelegate.h"
#import<AssetsLibrary/AssetsLibrary.h>

@interface SelectGroupViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isViewDidAppear;
    NSMutableArray * groupArray;
    NSMutableArray * groupImageArray;
}
@property(nonatomic, retain)UITableView * mTableView;

@end

@implementation SelectGroupViewController

@synthesize mTableView;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.view.backgroundColor = [UIColor whiteColor];
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    groupArray = [[NSMutableArray alloc]init];
    isViewDidAppear = NO;
    [self initMtableView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if(isViewDidAppear == NO)
    {
        SelectImageViewController * selectImage = [[SelectImageViewController alloc]init];
        selectImage.saveImagePath = self.saveImagePath;
        selectImage.maxPhotoNumber = self.maxPhotoNumber;
        selectImage.completeBlock = self.completeBlock;
        [selectImage setGroupBlock:^(NSMutableArray * data,NSMutableArray *image){
            [self myBlockFunction:data withImage:image];
        }];
        [self.navigationController pushViewController:selectImage animated:NO];
        [self moveUpTransition:YES forLayer:[UIApplication sharedApplication].delegate.window.layer];
        isViewDidAppear = YES;
    }
}

-(void)initMtableView
{
    mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    mTableView.backgroundColor = [UIColor clearColor];
    mTableView.delegate = self;
    mTableView.dataSource = self;
        
    [self.view addSubview:mTableView];
}

-(void)myBlockFunction:(NSMutableArray *)data withImage:(NSMutableArray *)image
{
    groupArray = data;
    groupImageArray = image;
    [self.mTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return groupArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:Identifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        UIImageView * imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(5, 5, 70, 70);
        imageView.backgroundColor = [UIColor clearColor];
        imageView.tag = 400;
        [cell.contentView addSubview:imageView];
        
        UILabel * titleLabel = [[UILabel alloc]init];
        titleLabel.frame = CGRectMake(80, cell.contentView.frame.size.height/2, 150, 40);
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.tag = 500;
        [cell.contentView addSubview:titleLabel];
    }
    
    UIImageView * imageView = (UIImageView *)[cell.contentView viewWithTag:400];
    imageView.image = [groupImageArray objectAtIndex:indexPath.row];
    
    UILabel * titleLabel = (UILabel *)[cell.contentView viewWithTag:500];
    NSString * name = [[groupArray objectAtIndex:indexPath.row] objectAtIndex:0];
    NSString * count = [[groupArray objectAtIndex:indexPath.row] objectAtIndex:2];
    titleLabel.text = [NSString stringWithFormat:@"%@(%@)",[name substringFromIndex:5],[count substringFromIndex:14]];
    
    //[ToolsFunction setCellAccessoryView:cell];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    /*
     ALAssetsGroup *group = [groups objectAtIndex:index];
     
     CGImageRef posterImageRef = [group posterImage];
     
     UIImage *posterImage = [UIImage
     
     imageWithCGImage:posterImageRef];
    */
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString * name = [[groupArray objectAtIndex:indexPath.row] objectAtIndex:0];
    
    SelectImageViewController * selectImage = [[SelectImageViewController alloc]init];
    selectImage.saveImagePath = self.saveImagePath;
    selectImage.maxPhotoNumber = self.maxPhotoNumber;
    selectImage.completeBlock = self.completeBlock;
    selectImage.groupType = [name substringFromIndex:5];
    [self.navigationController pushViewController:selectImage animated:YES];
    [self moveUpTransition:YES forLayer:[UIApplication sharedApplication].delegate.window.layer];
}

// Animation
- (void)moveUpTransition:(BOOL)bUp forLayer:(CALayer*)layer {
    CATransition *transition = [CATransition animation];
    if (bUp) {
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
    } else {
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
    }
    [layer addAnimation:transition forKey:nil];
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
