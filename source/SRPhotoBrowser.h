//
//  SRPhotoBrowser.h
//
//  Created by SR on 15-11-18
//  Copyright (c) 2015年 wezebra. All rights reserved.

#import <UIKit/UIKit.h>

@protocol SRPhotoBrowserDelegate;
@interface SRPhotoBrowser : ZBViewController <UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<SRPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
// 可否被删除
@property (nonatomic,assign)BOOL canDelete;

// 显示
//- (void)show;

// 带NavigationController的显示
//- (void)showWithRootViewController:(UIViewController *)vc ;

@end

@protocol SRPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(SRPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

// 删除了第index张图片,当前图片数组为
- (void)photoBrowser:(SRPhotoBrowser *)photoBrowser deleteImage:(NSUInteger)index leftPhotos:(NSArray *)photos;
@end