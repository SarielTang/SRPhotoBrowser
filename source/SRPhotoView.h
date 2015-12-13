//
//  SRZoomingScrollView.h
//
//  Created by SR on 15-11-18
//  Copyright (c) 2015年 wezebra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRPhotoBrowser, SRPhoto, SRPhotoView;

@protocol SRPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(SRPhotoView *)photoView;
- (void)photoViewSingleTap:(SRPhotoView *)photoView;
- (void)photoViewDidEndZoom:(SRPhotoView *)photoView;

@end

@interface SRPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) SRPhoto *photo;
// 代理
@property (nonatomic, weak) id<SRPhotoViewDelegate> photoViewDelegate;
@end