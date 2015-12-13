//
//  SRPhotoToolbar.h
//  FingerNews
//
//  Created by SR on 15-9-24.
//  Copyright (c) 2015年 wezebra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRPhotoToolbar : UIView
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
@end
