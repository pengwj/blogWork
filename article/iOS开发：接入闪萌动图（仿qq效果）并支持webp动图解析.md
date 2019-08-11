# 目标
1、接入闪萌动图
2、仿qq动图效果
3、支持webp

# demo链接
明天提供demo

# 接入闪萌api
闪萌的api需要在他们官网http://www.weshineapp.com，找客服领取测试用的id、密钥。

# 仿qq动图效果
主要布局采用```UICollectionView```，大家可以看我demo的实现，我项目中是在输入框文字变换的回调中刷新请求接口的。另外就是需要10秒钟不操作，弹窗自动收回。
```
//添加定时器
- (void)refreshTimer
{
    _timerValue = 0;

    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDown) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

//执行任务
- (void)timerDown
{
    self.timerValue++;
    if (self.timerValue >= 10) {
        [self hideSelf];
    }
}

//定时器的停止
- (void)finishedTimer
{
    self.timerValue = 0;
    
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - UIScrollViewDelegate
- ( void)scrollViewDidScroll:( UIScrollView *)scrollView
{
    // 重新开始计时
    [self refreshTimer];
}
```

# 支持webp
这个是临时加进来的需求，开始我想着应该很简单，结果没想到还蛮坑的。

webp是谷歌在2010年推出的新一代图片格式，在压缩方面比当前JPEG格式更优越，在质量相同的情况下，WebP格式图像的体积要比JPEG格式图像小40%。

## 支持webp的显示
下面两个方案我都实现过，其中方案1操作起来更简单一些（demo中选择的也是这个方案），但是由于项目中的SDWebImage版本低于3.0.0，所以只好选择了修改SD的库，也就是方案2。

### 方案1
使用[SDWebImageWebPCoder](https://github.com/SDWebImage/SDWebImageWebPCoder)+[SDWebImage](https://github.com/SDWebImage/SDWebImage)即可实现webp的动图（静态图）加载。但这个方案比较蛋疼的是SDWebImageWebPCoder比较依赖SDWebImage的实现，中间引用了一大堆SDWebImage的方法，完全没办法独立使用，如果SD用的老版本，那这个方案基本可以放弃了。

#### 添加pod
```
pod 'SDWebImageWebPCoder'
pod 'SDWebImage', '~> 5.0'
```
然后执行```pod install```
但是库去要去拉取谷歌的libwebp文件会失败，所以需要我们进行还原操作。具体操作如下。

#### 操作步骤：
此操作步骤来自于[iOSCoder_XH](https://www.jianshu.com/p/8349ea784f0e)，下面复制一下主要是为了备份。
1、 查看 mac 中 cocoapods 本地库路径:
pod repo
2、在本地库中, 并找到对应的 libwebp 版本的文件
find ~/.cocoapods/repos/master -iname libwebp
3、打开上一步查找的路径
open /Users/xxxxxxx/.cocoapods/repos/master/Specs/1/9/2/libwebp
4、在文件下找到之前pod install失败的libwebp版本文件夹
5、打开文件libwebp.podspec.json，修改git的地址
"source": {
"git": "[https://chromium.googlesource.com/webm/libwebp](https://links.jianshu.com/go?to=https%3A%2F%2Fchromium.googlesource.com%2Fwebm%2Flibwebp)",
"tag": "v1.0.2"
},
改为
"source": {
"git": "[https://github.com/webmproject/libwebp.git](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fwebmproject%2Flibwebp.git)",
"tag": "v1.0.2"
},
保存
6、重新pod install


#### 使用方法
这里单独拎出来主要是感觉这个库的使用有点怪，官网例子也写的不太清楚。
在你需要展示webp文件的位置，添加coder
```
// Add coder
SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
[[SDImageCodersManager sharedManager] addCoder:webPCoder];
```
然后再使用SD加载图片的方法即可支持webp图片的播放。
```
UIImageView *imageView;
NSURL *webpURL;
[imageView sd_setImageWithURL:webpURL];
```
是不是很清爽，这里也支持一下```SDWebImageWebPCoder```，开发者好像还是一个国内的小伙伴，感谢他们的无私奉献。

### 方案2
如果项目中SDWbImage的版本比较旧的时候，可以考虑一下方案2。方案2主要是修改了SDWebImage解析WebP数据的方法```sd_imageWithWebPData```，然后用YYImage去解析数据，解析后通过SD的方法返回。

#### 开启SDWebImage的WebP参数
在```Build Settings```中搜索```Preprocessor Macros```，添加```"SD_WEBP=1"```,添加这个参数后，SDWebImage才会执行webp相关解析代码。

#### 添加YYImage
```
pod 'YYImage'
```
然后执行```pod install```

#### 修改SDWebImage的```sd_imageWithWebPData```方法
```
// 添加YYImage头文件
#import <YYImage/YYImage.h>
```
修改```sd_imageWithWebPData```方法如下
```
+ (UIImage *)sd_imageWithWebPData:(NSData *)data {

    YYImage *image = [[YYImage alloc] initWithData:data scale:0];
    
    return image;
}
```


#### 修改SDWebImage的```SDScaledImageForKey```方法
该方法在```SDWebImageCompat.m```文件中。
之所以修改这里，是因为SDWebImage会在这里对图片进行绘制处理，主要是为了适配不同的屏幕scale。所以我们需要在这里直接返回一下。
【注意⚠️⚠️⚠️：不同的SD版本修改的方法可能不同，需要大家自己看项目中SD源码】
```
inline UIImage *SDScaledImageForKey(NSString *key, UIImage *image) {
    if (!image) {
        return nil;
    }
    
// 添加的代码如下（判断是YYImage直接返回）
    if ([image isKindOfClass:NSClassFromString(@"YYImage")]) {
        return image;
    }
//  添加的代码如上   

    if ([image.images count] > 0) {
        NSMutableArray *scaledImages = [NSMutableArray array];

        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:SDScaledImageForKey(key, tempImage)];
        }

        return [UIImage animatedImageWithImages:scaledImages duration:image.duration];
    }
    else {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGFloat scale = 1.0;
            if (key.length >= 8) {
                // Search @2x. or @3x. at the end of the string, before a 3 to 4 extension length (only if key len is 8 or more @2x./@3x. + 4 len ext)
                NSRange range = [key rangeOfString:@"@2x." options:0 range:NSMakeRange(key.length - 8, 5)];
                if (range.location != NSNotFound) {
                    scale = 2.0;
                }
                
                range = [key rangeOfString:@"@3x." options:0 range:NSMakeRange(key.length - 8, 5)];
                if (range.location != NSNotFound) {
                    scale = 3.0;
                }
            }

            UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
            image = scaledImage;
        }
        return image;
    }
}
```

#### 使用如下
主要是需要替换```UIImageView```为```YYAnimatedImageView```，其他的正常使用即可。
```
// 引入YYAnimatedImageView.h头文件
#import <YYImage/YYAnimatedImageView.h>

// 初始化YYAnimatedImageView
@property (nonatomic, strong) YYAnimatedImageView *gifImageView;
```

```
    NSURL *url  = [NSURL URLWithString:@"闪萌动图webp地址"];
    [self.gifImageView sd_setImageWithURL:url completed:nil];
```

## 将webp转换成gif并保存到本地
核心代码如下：
```
        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:self.gifImageView.animatedImageData scale:0];
        NSData *gifData = [YYImageEncoder encodeImageWithDecoder:decoder type:YYImageTypeGIF quality:1];
```
使用```YYImageDecoder```先解压webp图片，然后用```YYImageEncoder```的```encodeImageWithDecoder```方法将webp格式的动图转换成gif格式的Data，然后保存到相册中。

全部代码如下：
```  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:self.emojiImage.animatedImageData scale:0];
        NSData *gifData = [YYImageEncoder encodeImageWithDecoder:decoder type:YYImageTypeGIF quality:1];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:gifData options:nil];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(success && !error){
                    [SVProgressHUD showSuccessWithStatus:@"保存动图成功"];
                }else
                    [SVProgressHUD showErrorWithStatus:@"保存动图失败,请重试"];
            });
            
        }];
        
    });
```

## 总结
遇到各个博客没有比较成熟的解决方案时，记得优先看开源库、系统库的相关头文件。
