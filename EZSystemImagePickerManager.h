//
//  EZSystemImagePickerManager.h
//  EZRecord
//
//  Created by 陈诚 on 2019/4/12.
//  Copyright © 2019 陈诚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZSystemImagePickerManager : NSObject

/** 选择图片回调 */
@property (nonatomic, copy) void (^didSelectImageBlock) (UIImage *image);

/** 相册选择器对象 */
@property (nonatomic, strong) UIImagePickerController *imagePicker;

/** 最大视频时长 */
@property (nonatomic, assign) NSTimeInterval videoMaximumDuration;

/** 是否为视频 */
@property (nonatomic, assign) BOOL isVideo;

/** 创建一个管理类对象,把外面的viewController传进来盘它 */
- (instancetype)initWithViewController:(UIViewController *)vc;

/** 快速创建一个图片选择弹出框 */
- (void)quickAlertSheetPickerImage;

/** 打开相机 */
- (void)openCamera;

/** 打开相册 */
- (void)openPhoto;

@end

NS_ASSUME_NONNULL_END
