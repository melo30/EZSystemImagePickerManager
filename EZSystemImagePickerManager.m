//
//  EZSystemImagePickerManager.m
//  EZRecord
//
//  Created by 陈诚 on 2019/4/12.
//  Copyright © 2019 陈诚. All rights reserved.
//

#import "EZSystemImagePickerManager.h"

@interface EZSystemImagePickerManager () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/** 来源控制器 */
@property (nonatomic, strong) UIViewController *originViewController;

/** 取出的图片 */
@property (nonatomic, strong) UIImage *tempImage;

@end

@implementation EZSystemImagePickerManager

- (instancetype)initWithViewController:(UIViewController *)vc {
    if (self = [super init]) {
        _originViewController = vc;
    }
    return self;
}

#pragma mark - 快速创建一个图片选择弹出窗
- (void)quickAlertSheetPickerImage {
    __weak typeof(self)weak_self = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weak_self openCamera];
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从手机相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weak_self openPhoto];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:photoAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    
    [self.originViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 打开相机
- (void)openCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.originViewController presentViewController:self.imagePicker animated:YES completion:^{
        NSLog(@"相机打开");
    }];
}

#pragma mark - 打开相册
- (void)openPhoto {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.originViewController presentViewController:self.imagePicker animated:YES completion:^{
        NSLog(@"打开相册");
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *originImage = info[UIImagePickerControllerOriginalImage];
    self.tempImage = [self fixOrientation:originImage];
    
    //回调
    if (self.didSelectImageBlock) {
        self.didSelectImageBlock(self.tempImage);
    }
    
    //拍到的照片随带保存到相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(self.tempImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//系统指定的回调方法,必须要实现，不然会崩溃
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil;
    if (error != nil) {
        msg = @"保存图片失败";
    }else {
        msg = @"保存图片成功";
    }
    [MBProgressHUD showHUDAddedTo:self.imagePicker.view animated:YES];
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        /// 转场动画方式
        //      _imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePicker.allowsEditing = YES; //允许编辑
        _imagePicker.videoMaximumDuration = 15 ; //视频时长默认15s
        _imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }
    return _imagePicker;
}

- (void)setIsVideo:(BOOL)isVideo{
    _isVideo = isVideo;
    if (isVideo == YES) {
        /// 媒体类型
        _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
    }else{
        /// 媒体类型
        _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    }
}

#pragma mark - 矫正图片方向
- (UIImage*)fixOrientation:(UIImage*)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.height, aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.width, aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage* img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
