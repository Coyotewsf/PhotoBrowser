//
//  HWPhotoBrowser.h
//  HaiwanSale
//
//  Created by 海玩 on 15/12/29.
//  Copyright © 2015年 Haiwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HWPhotoBrowserDelegate <NSObject>

- (void)saveImageWithImage:(UIImage *)img;

@end

@interface HWPhotoBrowser : UIView

@property (nonatomic, strong) NSArray *imgArr;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL isNeedDelete;

@property (nonatomic, assign) CGRect initRect;

@property (nonatomic, copy) void(^deletePhotoAction)(NSInteger);

@property (nonatomic, assign) id<HWPhotoBrowserDelegate> delegate;

@property (nonatomic, assign) BOOL isNeedSave;

@property (nonatomic, assign) BOOL noNeedMoveFrame;
- (void)changeImageViewFrame;
- (void)setInitRect;
@end
