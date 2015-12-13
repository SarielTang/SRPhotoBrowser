//
//  SRPhotoBrowser.m
//
//  Created by SR on 15-11-18
//  Copyright (c) 2015年 wezebra. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "SRPhotoBrowser.h"
#import "SRPhoto.h"
//#import "SDWebImageManager+SR.h"
#import <SDWebImage/SDWebImageManager.h>
#import "SRPhotoView.h"
#import "SRPhotoToolbar.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface SRPhotoBrowser () <SRPhotoViewDelegate,UIActionSheetDelegate>
{
    // 滚动的view
	UIScrollView *_photoScrollView;
    // 所有的图片view
	NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    // 工具条
//    SRPhotoToolbar *_toolbar;
    
    // 一开始的状态栏
    BOOL _statusBarHiddenInited;
}
@end

@implementation SRPhotoBrowser

#pragma mark - Lifecycle
//- (void)loadView
//{
//    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
//    // 隐藏状态栏
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//    self.view = [[UIView alloc] init];
//    self.view.frame = [UIScreen mainScreen].bounds;
//	self.view.backgroundColor = [UIColor colorWithHexString:MAIN_COLOR_BG];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasBackItem = YES;
    
    if (self.canDelete) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCurrentImage)];
    }
    [self.backScrollView removeFromSuperview];
    self.backScrollView = nil;
    [self.contentView removeFromSuperview];
    self.contentView = nil;
    
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
//    [self createToolbar];
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    if (self.canDelete) {
        self.title = [NSString stringWithFormat:@"%ld / %ld", _currentPhotoIndex + 1, _photos.count];
    }else {
        self.title = @"查看";
    }
    
    self.navigationController.navigationBarHidden = NO;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}

- (void)deleteCurrentImage {
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"要删除这张照片吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex!=actionSheet.cancelButtonIndex)
    {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.photos];
        [array removeObjectAtIndex:_currentPhotoIndex];
        
        if ([self.delegate respondsToSelector:@selector(photoBrowser:deleteImage:leftPhotos:)]) {
            [self.delegate photoBrowser:self deleteImage:_currentPhotoIndex leftPhotos:array];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//- (void)show
//{
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    [window addSubview:self.view];
//    [window.rootViewController addChildViewController:self];
//
//    if (_currentPhotoIndex == 0) {
//        [self showPhotos];
//    }
//}

//// 带NavigationController的显示
//- (void)showWithRootViewController:(UIViewController *)vc {
//    [vc.navigationController pushViewController:self animated:YES];
//}

#pragma mark - 私有方法
//#pragma mark 创建工具条
//- (void)createToolbar
//{
//    CGFloat barHeight = 44;
//    CGFloat barY = self.view.frame.size.height - barHeight;
//    _toolbar = [[SRPhotoToolbar alloc] init];
//    _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
//    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    _toolbar.photos = _photos;
//    [self.view addSubview:_toolbar];
//    
//    [self updateTollbarState];
//}

#pragma mark 创建UIScrollView
- (void)createScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
	_photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
	_photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_photoScrollView.pagingEnabled = YES;
	_photoScrollView.delegate = self;
	_photoScrollView.showsHorizontalScrollIndicator = NO;
	_photoScrollView.showsVerticalScrollIndicator = NO;
	_photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
	[self.view addSubview:_photoScrollView];
//    [_photoScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
    for (int i = 0; i<_photos.count; i++) {
        SRPhoto *photo = _photos[i];
        photo.index = i;
        photo.firstShow = i == _currentPhotoIndex;
    }
}

#pragma mark 设置选中的图片
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    for (int i = 0; i<_photos.count; i++) {
        SRPhoto *photo = _photos[i];
        photo.firstShow = i == currentPhotoIndex;
    }
    
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

#pragma mark - SRPhotoView代理
- (void)photoViewSingleTap:(SRPhotoView *)photoView
{
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    CGFloat animationTime = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    if (self.navigationController.navigationBarHidden) {
        [UIView animateWithDuration:animationTime animations:^{
            self.navigationController.navigationBarHidden = NO;
        }];
    }else {
        [UIView animateWithDuration:animationTime animations:^{
            self.navigationController.navigationBarHidden = YES;
        }];
    }
    
//    // 移除工具条
//    [_toolbar removeFromSuperview];
}

- (void)photoViewDidEndZoom:(SRPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)photoViewImageFinishLoad:(SRPhotoView *)photoView
{
//    _toolbar.currentPhotoIndex = _currentPhotoIndex;
    if (self.canDelete) {
        self.title = [NSString stringWithFormat:@"%ld / %ld", _currentPhotoIndex + 1, _photos.count];
    }
}

#pragma mark 显示照片
- (void)showPhotos
{
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
	int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
	int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = _photos.count - 1;
	
	// 回收不再显示的ImageView
    NSInteger photoViewIndex;
	for (SRPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
		if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            photoView.zoomScale = 1.0;
			[_reusablePhotoViews addObject:photoView];
			[photoView removeFromSuperview];
		}
	}
    
	[_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
	
	for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
		if (![self isShowingPhotoViewAtIndex:index]) {
			[self showPhotoViewAtIndex:index];
		}
	}
}

#pragma mark 显示一个图片view
- (void)showPhotoViewAtIndex:(int)index
{
    SRPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[SRPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    SRPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

#pragma mark 加载index附近的图片
- (void)loadImageNearIndex:(int)index
{
    if (index > 0) {
        SRPhoto *photo = _photos[index - 1];
//        [SDWebImageManager downloadWithURL:photo.url];
        [[SDWebImageManager sharedManager] downloadImageWithURL:photo.url options:SDWebImageLowPriority|SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        }];
    }
    
    if (index < _photos.count - 1) {
        SRPhoto *photo = _photos[index + 1];
//        [SDWebImageManager downloadWithURL:photo.url];
        [[SDWebImageManager sharedManager] downloadImageWithURL:photo.url options:SDWebImageLowPriority|SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        }];
    }
}

#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
	for (SRPhotoView *photoView in _visiblePhotoViews) {
		if (kPhotoViewIndex(photoView) == index) {
           return YES;
        }
    }
	return  NO;
}

#pragma mark 循环利用某个view
- (SRPhotoView *)dequeueReusablePhotoView
{
    SRPhotoView *photoView = [_reusablePhotoViews anyObject];
	if (photoView) {
		[_reusablePhotoViews removeObject:photoView];
	}
	return photoView;
}

//#pragma mark 更新toolbar状态
//- (void)updateTollbarState
//{
//    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
//    _toolbar.currentPhotoIndex = _currentPhotoIndex;
//}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self showPhotos];
//    [self updateTollbarState];
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    if (self.canDelete) {
        self.title = [NSString stringWithFormat:@"%ld / %ld", _currentPhotoIndex + 1, _photos.count];
    }
}
@end