//
//  SRPhotoLoadingView.h
//
//  Created by SR on 15-11-18
//  Copyright (c) 2015年 wezebra. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinProgress 0.0001

@class SRPhotoBrowser;
@class SRPhoto;

@interface SRPhotoLoadingView : UIView
@property (nonatomic) float progress;

- (void)showLoading;
- (void)showFailure;
@end