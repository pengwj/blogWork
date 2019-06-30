## 贝塞尔曲线
贝塞尔曲线(Bézier curve)，又称贝兹曲线或贝济埃曲线，是应用于二维图形应用程序的数学曲线。贝塞尔曲线是依据四个位置任意的点坐标绘制出的一条光滑曲线。具体原理可以看看文章底部[第一篇参考文章](https://www.jianshu.com/p/8f82db9556d2)。

## UIBezierPath简介
在iOS开发中，贝塞尔曲线的具体实现封装在Core Graphics框架中。为了方便开发者使用，苹果单独将贝塞尔相关方法封装到了UIBezierPath类中。

## 创建UIBezierPath对象
##### 创建一个对象
```
+ (instancetype)bezierPath;
```

##### 根据CGPath创建对象
```
+ (instancetype)bezierPathWithCGPath:(CGPathRef)CGPath;
```

##### 创建一个矩形路径
```
+ (instancetype)bezierPathWithRect:(CGRect)rect;
```
##### 创建一个椭圆或者圆
```
+ (instancetype)bezierPathWithOvalInRect:(CGRect)rect;
```
##### 创建一个带有圆角的矩形
```
/**
 @param rect 矩形区域
 @param cornerRadii 圆角半径
 */
+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
```
##### 创建一个带有圆角的矩形
```
/**
 @param rect 矩形区域
 @param corners 枚举：哪个角是圆角(多个时用 ‘|’分开)
 @param cornerRadii 圆角半径
 */
+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;
```
##### 创建一个圆弧路径
```
/**
 @param center 圆心
 @param radius 半径
 @param startAngle 开始角度（0-M_PI）
 @param endAngle 结束角度
 @param clockwise 是否顺时针
 */
+ (instancetype)bezierPathWithArcCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;
```

## 添加UIBezierPath路径
##### 添加一段直线
```
/**
 @param point 结束点
 */
- (void)addLineToPoint:(CGPoint)point;
```

##### 添加一段圆弧
```
/**
 @param center 中心点
 @param radius 半径
 @param startAngle 开始角度
 @param endAngle 结束角度
 @param clockwise 是否顺时针
 */
- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise NS_AVAILABLE_IOS(4_0);
```
##### 添加一段二次贝塞尔曲线
```
/**
 @param endPoint 结束点
 @param controlPoint 控制点
 */
- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;
```

##### 添加一段三次贝塞尔曲线
```
/**
 @param endPoint 结束点
 @param controlPoint1 控制点1
 @param controlPoint2 控制点2
 */
- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;
```

## stroke 和 fill 方法的区别
路径的绘制两种方式，一种是描绘（stroke），一种是填充（fill ）。前者是只绘制图形（一段段的线条），后者除了线条还包含内部的区域。具体效果如下图：

![stroke.jpeg](https://upload-images.jianshu.io/upload_images/14477290-641e2fd183dfca14.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![fill.jpeg](https://upload-images.jianshu.io/upload_images/14477290-e2b571c33f242ac1.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## UIBezierPath绘制的应用
### 回顾一下上面的方法
先总结一下，UIBezierPath的方法大概可以分为两大类：
1. 通过实例化方法直接获取已经处理好的相应UIBezierPath曲线，比如：获取矩形、带圆角的矩形、圆形等
```
+ (instancetype)bezierPathWithRect:(CGRect)rect;

+ (instancetype)bezierPathWithOvalInRect:(CGRect)rect;

+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;
```
2. 通过添加曲线、直线等基础方法来自定义UIBezierPath曲线
```
- (void)moveToPoint:(CGPoint)point;

- (void)addLineToPoint:(CGPoint)point;

- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise NS_AVAILABLE_IOS(4_0);

- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;

- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;
```
### 自定义UIBezierPath曲线
1. 创建一个UIBezierPath对象
2. 使用moveToPoint:方法设置曲线的起点
3. 添加直线或者曲线去定义路径
4. 设置UIBezierPath对象的相关属性
  
```
// 画三角形
- (void)drawTrianglePath {

  // 1. 创建一个UIBezierPath对象
  UIBezierPath *path = [UIBezierPath bezierPath];

  // 2. 使用moveToPoint:方法设置曲线的起点
  [path moveToPoint:CGPointMake(20, 20)];
  
  // 3. 添加直线或者曲线去定义路径
  [path addLineToPoint:CGPointMake(self.frame.size.width - 40, 20)];
  [path addLineToPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height - 20)];
  
  // 最后的闭合线是可以通过调用closePath方法来自动生成的，也可以调用-addLineToPoint:方法来添加
  //  [path addLineToPoint:CGPointMake(20, 20)];
  
  [path closePath];
  
  // 4. 设置UIBezierPath对象的相关属性
  // 设置线宽
  path.lineWidth = 1.5;
  // 设置填充颜色
  UIColor *fillColor = [UIColor greenColor];
  [fillColor set];
  [path fill];
  // 设置画笔颜色
  UIColor *strokeColor = [UIColor blueColor];
  [strokeColor set];
  // 根据我们设置的各个点连线
  [path stroke];
}
```

## 参考资料
[贝塞尔曲线原理(实现图真漂亮)](https://www.jianshu.com/p/8f82db9556d2)

[UIBezierPath-UIKit|Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uibezierpath)

[iOS UIBezierPath使用——贝塞尔曲线](https://www.jianshu.com/p/e136c3e65c29)

[iOS之UIBezierPath贝塞尔曲线属性简介](https://www.cnblogs.com/xianfeng-zhang/p/7736508.html)



