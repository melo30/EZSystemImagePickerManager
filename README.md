# EZSystemImagePickerManager
一个系统的拍照相册Manager

平时项目里面每次写系统相册选择都感觉很恶心🤮...就封装一个...由于本身定制化也不高就没放入cocoaPods私有库...拉下来用就好了...

使用方法：

1.拉下来 #import "EZSystemImagePickerManager.h"


2.全局变量 @property (nonatomic, strong) EZSystemImagePickerManager *manager;


3.初始化并传入当前viewController

- (EZSystemImagePickerManager *)manager {

    if (!_manager) {
    
        _manager = [[EZSystemImagePickerManager alloc] initWithViewController:self];
        
    }
    
    return _manager;
    
}



4.在弹出按钮点击事件里

  [self.manager quickAlertSheetPickerImage];
  
  [self.manager setDidSelectImageBlock:^(UIImage * _Nonnull image) {
  //得到的image回调
            
   }];
