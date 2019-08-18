# CoreAnimation
Core Animation，中文翻译为核心动画，它是一组非常强大的动画处理API，使用它能做出非常炫丽的动画效果，而且往往是事半功倍。也就是说，使用少量的代码就可以实现非常强大的功能。

从图中可以看出，最底层是图形硬件(GPU)；上层是OpenGL和CoreGraphics，提供一些接口来访问GPU；再上层的CoreAnimation在此基础上封装了一套动画的API。最上面的UIKit属于应用层，处理与用户的交互。

![框架](https://upload-images.jianshu.io/upload_images/14477290-b5e6b7fd1e842175.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


# Core Animation相关类
![类](https://upload-images.jianshu.io/upload_images/14477290-fe37ecca294b8207.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
CAAnimation作为虚基类实现了CAMediaTiming协议。CAAnimation有三个子类CAAnimationGroup、CAPropertyAnimation、CATrasition。其中CAPropertyAnimation也有两个子类CABasicAnimation、CAKeyFrameAnimation。

而其中CAAnimation、CAPropertyAnimation做为虚类，我们日常开发中无法使用。因此我们可用的类有CABasicAnimation、CAKeyFrameAnimation、CAAnimationGroup、CATrasition。

## CABasicAnimation
基本动画的动画效果主要是通过（fromValue和toValue）、keyPath来控制，fromValue是所改变值的初始值、toValue是目标值。

```
CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
moveAnimation.duration = 0.8;//动画时间
//动画起始值和终止值的设置
moveAnimation.fromValue = @(300);
moveAnimation.toValue = @(300-30);
//一个时间函数，表示它以怎么样的时间运行
moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
moveAnimation.repeatCount = HUGE_VALF;
moveAnimation.repeatDuration = 2;
moveAnimation.removedOnCompletion = NO;
moveAnimation.fillMode = kCAFillModeForwards;
//添加动画，后面有可以拿到这个动画的标识
[self.imageView.layer addAnimation:moveAnimation forKey:@"moveAnimationKey"];
```
keyPath有以下属性：
```
transform.scale (比例转换)
transform.scale.x
transform.scale.y
transform.rotation(旋转) 
transform.rotation.x(绕x轴旋转)
transform.rotation.y(绕y轴旋转)
transform.rotation.z(绕z轴旋转)
opacity (透明度)
margin
backgroundColor(背景色)
cornerRadius(圆角)
borderWidth(边框宽)
bounds
contents
contentsRect
cornerRadius
frame
hidden
mask
masksToBounds
shadowColor(阴影色)
shadowOffset
shadowOpacity
shadowOpacity
```

## CAKeyFrameAnimation
CABasicAnimation 只能从一个数值（fromValue）变换成另一个数值（toValue）,而 CAKeyframeAnimation 则会使用一个数组(values) 保存一组关键帧, 也可以给定一个路径(path)制作动画。
```
CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
NSMutableArray *values = [[NSMutableArray alloc]initWithCapacity:3];
[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1.0)]];
[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
animation.values = values;
animation.duration = 0.5;
animation.removedOnCompletion = YES;
[self.imageView.layer addAnimation:animation forKey:nil];
```


## CAAnimationGroup
动画组，是CAAnimation的子类，可以保存一组动画对象，将CAAnimationGroup对象加入层后，组中所有动画对象可以同时并发运行
```
CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
animationGroup.animations = @[animation1,animation2];
animationGroup.duration = 4;
animation.repeatCount = 9;
[self.imageView.layer addAnimation:animationGroup forKey:@"changeColor"];
```

## CATrasition
CATransition是CAAnimation的子类，用于做转场/过渡动画，能够为层提供移出屏幕和移入屏幕的动画效果。
```
    CATransition *transition = [CATransition animation];
    transition.startProgress = 0;//开始进度
    transition.endProgress = 1;//结束进度
    transition.type = kCATransitionReveal;//过渡类型
    transition.subtype = kCATransitionFromLeft;//过渡方向
    transition.duration = 1.f;
    
    UIColor *color = [UIColor colorWithRed:arc4random_uniform(255) / 255.0 green:arc4random_uniform(255) / 255.0 blue:arc4random_uniform(255) / 255.0 alpha:1.f];
    self.imageView.layer.backgroundColor = color.CGColor;
    
    [self.imageView.layer addAnimation:transition forKey:@"transition"];
```

## 总结
其他的复杂动画都是由上面这些简单的动画组合而成的，在拿到效果图时可以先拆解一下。
