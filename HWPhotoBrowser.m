//
//  HWPhotoBrowser.m
//  HaiwanSale
//
//  Created by 海玩 on 15/12/29.
//  Copyright © 2015年 Haiwan. All rights reserved.
//

#import "HWPhotoBrowser.h"
#import "UIView+PBExtend.h"
#import "HWEvaPhoto.h"
#import "UIImageView+WebCache.h"

@interface HWPhotoBrowser ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *showImgScrollView;

//@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UILabel *indexLabel;

@property (nonatomic, assign) CGFloat lastScale;

@property (nonatomic,strong) UIButton *deleteBtn;

@end

@implementation HWPhotoBrowser

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.showImgScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.showImgScrollView.showsHorizontalScrollIndicator = NO;
        self.showImgScrollView.showsVerticalScrollIndicator = NO;
        self.showImgScrollView.pagingEnabled = YES;
        self.showImgScrollView.delegate = self;
        [self addSubview:self.showImgScrollView];
        
        self.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-50)/2, 40, 50, 15)];
        self.indexLabel.textColor = [UIColor whiteColor];
        self.indexLabel.textAlignment = NSTextAlignmentCenter;
        self.indexLabel.font = kHWFont3;
        [self addSubview:self.indexLabel];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteBtn setImage:[UIImage imageNamed:@"evaDelete"] forState:UIControlStateNormal];
        self.deleteBtn.frame = CGRectMake(SCREEN_WIDTH-44, 30, 34, 40);
        
        [self.deleteBtn addTarget:self action:@selector(deletePhoto) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.deleteBtn];
        self.deleteBtn.hidden = YES;
        
//        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-50)/2, KSH-30, 50, 10)];
//        self.pageControl.numberOfPages = 1;
//        [self addSubview:self.pageControl];
        
    }
    return self;
}

- (void)deletePhoto {
    NSLog(@"------");
    if (self.deletePhotoAction) {
        self.deletePhotoAction(self.currentIndex);
    }
    
}

- (void)setIsNeedDelete:(BOOL)isNeedDelete {
    _isNeedDelete = isNeedDelete;
    if (isNeedDelete) {
        self.deleteBtn.hidden = NO;
    }else {
        self.deleteBtn.hidden = YES;
    }
}

- (void)setImgArr:(NSArray *)imgArr {
    
    if ([imgArr isKindOfClass:[NSArray class]]) {
        if (imgArr.count > 0) {
                _imgArr = imgArr;
                
                for (UIView *view in self.showImgScrollView.subviews) {
                    [view removeFromSuperview];
                }
                
                NSInteger count = imgArr.count;
                for (int i = 0; i< count;i++) {
                    HWEvaPhoto *photo = imgArr[i];
                    UIImage *img = photo.image;
                    
                    UIScrollView *backImageViewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, 65, self.bounds.size.width, self.bounds.size.height-65)];
                    backImageViewScrollView.showsHorizontalScrollIndicator = NO;
                    backImageViewScrollView.showsVerticalScrollIndicator = NO;
                    backImageViewScrollView.delegate = self;
                    backImageViewScrollView.minimumZoomScale = 1.0;
                    backImageViewScrollView.bouncesZoom = YES;
                    backImageViewScrollView.maximumZoomScale = 2.0;
                    backImageViewScrollView.contentMode = UIViewContentModeCenter;
                    [self.showImgScrollView addSubview:backImageViewScrollView];
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.bounds.size.height-65)];
                    if ([photo.downloadUrl isKindOfClass:[NSString class]]) {
                        [imageView sd_setImageWithURL:[NSURL URLWithString:photo.downloadUrl]];
                    }else {
                        imageView.image = img;
                    }
                    
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                    imageView.multipleTouchEnabled = YES;
                    imageView.userInteractionEnabled = YES;
                    [backImageViewScrollView addSubview:imageView];
                
                        UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc]
                                                                 
                                                                 initWithTarget:self action:@selector(saveImage:)];
                        
                        // 为imageView添加手势处理器
                        
                        [imageView addGestureRecognizer:gesture];
                
                    
                }
                self.showImgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*count, 0);
                self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(self.currentIndex+1),(unsigned long)imgArr.count];
            

        }
    }
}

- (void)saveImage:(UILongPressGestureRecognizer *)longGes {
    if (_isNeedSave) {
        if(longGes.state == UIGestureRecognizerStateBegan){
            UIImageView *imageV = (UIImageView *)longGes.view;
            UIImage *image = imageV.image;
            if (image) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(saveImageWithImage:)]) {
                    [self.delegate saveImageWithImage:image];
                }
            }
            
        }
    }
    
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            return view;
        }
    }
    return nil;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    NSLog(@"%f", scrollView.zoomScale);
    //if(scrollView.zoomScale <=1) scrollView.zoomScale = 1.0f;
    //if(scrollView.zoomScale <=1) scrollView.zoomScale = 1.0f;
    
    UIImageView *imgView;
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            imgView = (UIImageView *)view;
        }
        
    }
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = imgView.frame;
    CGSize contentSize = scrollView.contentSize;
    
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    
    // center horizontally
    if (imgFrame.size.width <= boundsSize.width)
    {
        centerPoint.x = boundsSize.width/2;
    }
    
    // center vertically
    if (imgFrame.size.height <= boundsSize.height)
    {
        centerPoint.y = boundsSize.height/2;
    }
    
    imgView.center = centerPoint;
    
}


- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        
        [self.showImgScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*currentIndex, 0)];
        //self.pageControl.currentPage = currentIndex;
        self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)currentIndex+1, (unsigned long)self.imgArr.count];
    }
}

- (void)setInitRect {
    
    
    UIView *backView = self.showImgScrollView.subviews[self.currentIndex];
    for (UIView *view in backView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            CGRect rect = view.frame;
            view.frame = CGRectMake(_initRect.origin.x, _initRect.origin.y, _initRect.size.width, _initRect.size.height);
            [UIView animateWithDuration:0.3 animations:^{
                view.frame = rect;
            }];

        }
    }
}

- (void)changeImageViewFrame {
    UIScrollView *backView = (UIScrollView *)self.showImgScrollView.subviews[self.currentIndex];
    
    for (UIView *view in backView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            __weak HWPhotoBrowser *weakSelf = self;
            [UIView animateWithDuration:0.3 animations:^{
                if (backView.zoomScale > 1) {
                    backView.zoomScale = 1;
                }
                view.frame = CGRectMake(_initRect.origin.x, _initRect.origin.y, _initRect.size.width, _initRect.size.height);
                weakSelf.backgroundColor = [UIColor clearColor];
            } completion:^(BOOL finished) {
                weakSelf.hidden = YES;
            }];

        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if (scrollView == self.showImgScrollView) {
        
        UIScrollView *scView = self.showImgScrollView.subviews[self.currentIndex];
        [scView setZoomScale:1.0];
        
        CGPoint offset = scrollView.contentOffset;
        NSInteger index = offset.x / SCREEN_WIDTH;
        self.currentIndex = index;
        //self.pageControl.currentPage = index;
        self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)index+1,(unsigned long)self.imgArr.count];
        if (!self.noNeedMoveFrame) {
            self.initRect = CGRectMake(10+55*index, self.initRect.origin.y, self.initRect.size.width, self.initRect.size.height);
        }
    }
}

@end
