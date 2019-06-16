## 备受唾弃的图片圆角处理方式
* 图片圆角最常见的处理方式如下
```
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 15;
```
操作起来方便简洁，也是小编之前常用的处理方式，但是作为消耗性能的小怪兽，当数据量比较大的时候对性能的消耗还是十分大的，所以我们今天来尝试一下其他的解决方案。

## 解决方案
##### 方案一
* 如果是图片的话，可以用贝塞尔曲线、Core Graphics在上下文上，将图片进行剪切，然后将剪切后的图片赋值给UImageView 

##### 方案二
* 如果不是图片、或者加载网络图片时，我们就无法剪切图片了，这个时候我们可以通过设置UIView的``` self.layer.mask```属性，来设置圆角

## 具体代码
### 方案一
##### 实现方式1： 使用贝塞尔曲线UIBezierPath和Core Graphics框架画出圆角
```
    //开始对imageView进行画图
    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0.0);
    
    CGFloat radius = self.imageView.bounds.size.width;
    
    //创建贝塞尔曲线（此处有多种创建方式）
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds cornerRadius:radius];
    
    //设置path为绘制范围
    [path addClip];
    
    // 开始绘制
    [self.imageView drawRect:self.imageView.bounds];
    
    // 从上下文上获取剪裁后的照片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束画图
    UIGraphicsEndImageContext();

```
##### 实现方式2： 使用贝塞尔曲线UIBezierPath和Core Graphics框架画出圆角
```
    //开始对imageView进行画图
    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 1.0);
    
    // 获得图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 设置一个范围
    CGRect rect = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    
    // 根据一个rect创建一个椭圆
    CGContextAddEllipseInRect(ctx, rect);
    
    // 裁剪
    CGContextClip(ctx);
    
    // 将原照片画到图形上下文
    [self.imageView.image drawInRect:rect];
    
    // 从上下文上获取剪裁后的照片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    self.imageView.image = newImage;
```

##### 实现方式3： 使用Core Graphics框架画出圆角
```
    //开始对imageView进行画图
    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 1.0);
    
    // 获得图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 设置一个范围
    CGRect rect = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    
    // 根据一个rect创建一个圆
    CGContextAddEllipseInRect(ctx, rect);
    
    // 裁剪
    CGContextClip(ctx);
    
    // 将原照片画到图形上下文
    [self.imageView.image drawInRect:rect];
    
    // 从上下文上获取剪裁后的照片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    self.imageView.image = newImage;
```

### 方案二
##### 实现方式： 直接设置UIView的``` .layer.mask ```属性，给UIView设置一个mask，让其圆角显示
```
    //UIBezierPath的获取方法有很多，大家可以根据自己的需求来定制
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:self.imageView.bounds.size];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    
    //设置大小
    maskLayer.frame = self.imageView.bounds;
    
    //设置图形样子
    maskLayer.path = maskPath.CGPath;
    
    self.imageView.layer.mask = maskLayer;
```

## 优缺点比较
1.  单纯的从加载网络图片的需求而言，对网络图片的裁剪需要我们处理的地方较多，方案二更有优势。
2.  对于不是UIImageView的圆角需求而言，也比较推荐方案二。
至于方案二应该也有他的缺点，但是在目前的使用过程中还没有发现。

## 性能测试
~~今天太晚了要休息了，性能测试和具体原理探讨先放放，看看后面有没有时间补一下~~

## 具体原理
~~今天太晚了要休息了，性能测试和具体原理探讨先放放，看看后面有没有时间补一下~~

## 参考文章
 [iOS设置圆角的方法及指定圆角的位置](https://www.cnblogs.com/weiming4219/p/7680715.html)
 
 [iOS UIBezierPath知识介绍](https://www.cnblogs.com/breezemist/p/3487770.html)
 
[UIBezierPath介绍](https://www.jianshu.com/p/6c9aa9c5dd68)



