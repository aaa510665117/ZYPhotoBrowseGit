//
//  PreViewPhotoView.m
//  SkyHospital
//
//  Created by ZY on 15-1-7.
//  Copyright (c) 2015年 GrayWang. All rights reserved.
//

#import "PreViewPhotoView.h"
//#import "AppDelegate.h"
#import "ZoomImageView.h"
#import "PreViewState.h"

@interface PreViewPhotoView()<UIScrollViewDelegate>
@property(nonatomic, retain)UIScrollView * mScrollView;
@property (nonatomic, assign) CGFloat backgroundScale;
@property (nonatomic, strong) NSMutableArray *imgViews;

@property(nonatomic, retain)UIImageView * changImageView;

@property(nonatomic, retain)UIImageView * numControImageView;
@property(nonatomic, retain)UILabel * totalCount;
@property(nonatomic, retain)UILabel * currentCount;

@end

@implementation PreViewPhotoView
@synthesize changImageView,numControImageView;
@synthesize totalCount,currentCount;

- (id)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self initMyView];
    }
    return self;
}

- (void)initMyView {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.backgroundScale = 0.8;
    
    //平移手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    pan.maximumNumberOfTouches = 1;
    //先屏蔽掉平移手势,后期下拉进行删除图片操作
    //[self addGestureRecognizer:pan];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self initMyView];
    }
    return self;
}

- (UIImageView *)currentView {
    return [_imgViews objectAtIndex:(_mScrollView.contentOffset.x / _mScrollView.frame.size.width + 0.5)];
}

-(void)showWithImageViews:(NSArray *)images withSelectImageView:(UIImageView *)selectedView
{
    if(images != nil)
    {
        NSMutableArray *imgViews = [NSMutableArray array];
        for(id obj in images) {
            if([obj isKindOfClass:[UIImageView class]]) {
                [imgViews addObject:obj];
                
                UIImageView *view = obj;
                
                PreViewState *state = [PreViewState viewStateForView:view];
                [state setStateWithView:view];
                view.userInteractionEnabled = NO;
            }
        }
        _imgViews = [imgViews copy];
    }
    else
    {
        return;
    }
    //让其中的数组都相应事件
    [_mScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    NSInteger currentPage = [_imgViews indexOfObject:selectedView];

    if(_mScrollView == nil) {
        _mScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mScrollView.pagingEnabled = YES;
        _mScrollView.showsHorizontalScrollIndicator = NO;
        _mScrollView.showsVerticalScrollIndicator   = NO;
        _mScrollView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
        _mScrollView.delegate = self;
        
        numControImageView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-35, [UIScreen mainScreen].bounds.size.height-35, 30, 30)];
        numControImageView.backgroundColor = [UIColor colorWithRed:0.493 green:0.500 blue:0.483 alpha:0.6];
        numControImageView.layer.masksToBounds = YES;
        numControImageView.layer.cornerRadius  = 15;
        
        totalCount = [[UILabel alloc]initWithFrame:CGRectMake(numControImageView.frame.size.width/2-1, numControImageView.frame.size.height/2-5, 15, 15)];
        totalCount.backgroundColor = [UIColor clearColor];
        totalCount.font = [UIFont systemFontOfSize:13];
        totalCount.textColor = [UIColor blackColor];
        totalCount.text = [NSString stringWithFormat:@"/%d",_imgViews.count];;
        [numControImageView addSubview:totalCount];
        
        currentCount = [[UILabel alloc]initWithFrame:CGRectMake(2, 5, 17, 17)];
        currentCount.backgroundColor = [UIColor clearColor];
        currentCount.font = [UIFont systemFontOfSize:16];
        currentCount.textColor = [UIColor blackColor];
        currentCount.textAlignment = NSTextAlignmentCenter;
        currentCount.text = @"1";
        [numControImageView addSubview:currentCount];
    }
    [self addSubview:_mScrollView];
    self.alpha = 0;
    
    // 将rect从view中转换到当前视图中,返回在当前视图中的rect
    selectedView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [window addSubview:self];
    
    CGFloat fullW = window.frame.size.width;
    CGFloat fullH = window.frame.size.height;
    
    changImageView = [[UIImageView alloc]init];
    if(_selectFrameView != nil)
    {
        UIImageView * selectChangImage = [_selectFrameView objectAtIndex:(_mScrollView.contentOffset.x / _mScrollView.frame.size.width + 0.5)];

        changImageView.frame = [window convertRect:selectChangImage.frame fromView:selectChangImage.superview];
        changImageView.image = selectChangImage.image;
    }
    else
    {
        changImageView.frame = CGRectMake(fullW/2-1, fullH/2-1, 1, 1);
        changImageView.image = selectedView.image;
    }
    [window addSubview:changImageView];
    
    
    [UIView animateWithDuration:0.5
                     animations:^{

                        //转换imageView的大小
                        CGSize size = (changImageView.image) ? changImageView.image.size : changImageView.frame.size;
                        CGFloat ratio = MIN(fullW / size.width, fullH / size.height);      //相对比例
                        CGFloat W = ratio * size.width;
                        CGFloat H = ratio * size.height;
                        changImageView.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
                         
                         self.alpha = 1;

                         //缩放之前的状态
                         window.rootViewController.view.transform = CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale);
                         //重置作用,不然你变换用的坐标系统不是屏幕坐标系统（即绝对坐标系统），而是上一次变换后的坐标系统
                         selectedView.transform = CGAffineTransformIdentity;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         changImageView.alpha = 0;
                         
                         _mScrollView.contentSize = CGSizeMake(_imgViews.count * fullW, 0);
                         _mScrollView.contentOffset = CGPointMake(currentPage * fullW, 0);
                         
                         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
                         [gesture setNumberOfTapsRequired:1];

                         [_mScrollView addGestureRecognizer:gesture];
                         
                         // 双击事件
                         UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                            action:@selector(doubleTapScrollView:)];
                         [doubleTapGesture setNumberOfTapsRequired:2];
                         
                         [_mScrollView addGestureRecognizer:doubleTapGesture];

                         [gesture requireGestureRecognizerToFail:doubleTapGesture];
                         
                         for(UIImageView *view in _imgViews){
                             view.transform = CGAffineTransformIdentity;
                             
                             CGSize size = (view.image) ? view.image.size : view.frame.size;
                             CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             view.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
                             
                             
                             ZoomImageView *tmp = [[ZoomImageView alloc] initWithFrame:CGRectMake([_imgViews indexOfObject:view] * fullW, 0, fullW, fullH)];
                             tmp.imageView = view;
                             
                             [_mScrollView addSubview:tmp];
                             
                         }
                         [self addSubview:numControImageView];

                     }
     ];

}

-(void)doubleTapScrollView:(UIGestureRecognizer *)gesture
{
    float newScale = 1 * 1.5;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [_mScrollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)tappedScrollView:(UITapGestureRecognizer *)sender {
    //[self prepareToDismiss];
    [self dismissWithAnimate];
}

- (void)prepareToDismiss {
    UIImageView *currentView = [_imgViews objectAtIndex:(_mScrollView.contentOffset.x / _mScrollView.frame.size.width + 0.5)];

    /*
    if([self.delegate respondsToSelector:@selector(imageViewer:willDismissWithSelectedView:)]) {
        [self.delegate imageViewer:self willDismissWithSelectedView:currentView];
    }
    */
    for(UIImageView *view in _imgViews) {
        
        if(view != currentView) {
            PreViewState *state = [PreViewState viewStateForView:view];
            view.transform = CGAffineTransformIdentity;
            view.frame = state.frame;
            view.transform = state.transform;
            [state.superview addSubview:view];
        }
        
    }
}

- (void)dismissWithAnimate {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    
    UIImageView * image = [_imgViews objectAtIndex:(_mScrollView.contentOffset.x / _mScrollView.frame.size.width + 0.5)];
    
    CGFloat fullW = window.frame.size.width;
    CGFloat fullH = window.frame.size.height;
    
    CGSize size = (image.image) ? image.image.size : image.frame.size;
    CGFloat ratio = MIN(fullW / size.width, fullH / size.height);      //相对比例
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    changImageView.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
    changImageView.image = image.image;

    changImageView.alpha = 1;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         changImageView.frame = CGRectMake(fullW/2-1, fullH/2-1, 1, 1);
                         self.alpha = 0;
                         window.rootViewController.view.transform =  CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         [changImageView removeFromSuperview];
                         [self removeFromSuperview];
                     }
     ];
}

- (void)didPan:(UIPanGestureRecognizer *)sender {
    static UIImageView *currentView = nil;
    
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        currentView = [self currentView];
    }
    
    if(currentView) {
        if(sender.state == UIGestureRecognizerStateEnded) {
            if(_mScrollView.alpha<0.5)
            {
                if(_isHasRemove)
                {
                    [_imgViews removeObject:currentView];
                }
                else
                {
                    [self dismissWithAnimate];
                }
            }
            currentView = nil;
        } else {
            CGPoint p = [sender translationInView:self];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, p.y);
            transform = CGAffineTransformScale(transform, 1 - fabs(p.y)/1000, 1 - fabs(p.y)/1000);
            currentView.transform = transform;
            
            CGFloat r = 1-fabs(p.y)/200;
            _mScrollView.alpha = MAX(0, MIN(1, r));
        }
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    int page = (_mScrollView.contentOffset.x / _mScrollView.frame.size.width + 0.5);
    currentCount.text = [NSString stringWithFormat:@"%d",page+1];
    currentCount.frame = CGRectMake(2, -17, 17, 17);

    [UIView animateWithDuration:0.5 animations:^{
    
        currentCount.frame = CGRectMake(2, 5, 17, 17);

    } completion:^(BOOL finished){
        
        currentCount.text = [NSString stringWithFormat:@"%d",page+1];

    }];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(_mScrollView.contentOffset.x > 20 || (_mScrollView.contentOffset.x > 50 && _mScrollView.contentOffset.x < 300))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeScrollZoom"
                                                            object:nil];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
