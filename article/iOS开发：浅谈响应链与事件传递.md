## 基本概念
##### 响应者:
在iOS中，响应者为能响应事件的UIResponder子类对象，如UIButton、UIView等。
##### 响应链:
响应链是由链接在一起的响应者（UIResponse子类）组成的。默认情况下，响应链是由第一响应者，到application对象以及中间所有响应者一起组成的。
##### 事件传递:
获得响应链后，将事件由第一响应者往application传递的过程即为事件传递。

![响应链](https://upload-images.jianshu.io/upload_images/14477290-74a39afeec656243.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 响应者链执行的过程
##### 1、寻找第一响应者
顺着视图树结构，由根节点开始遍历所有的子控件，通过```hitTest:withEvent:```方法找到第一响应者，从第一响应者到application对象的一系列响应者即为响应链
##### 2、寻找最终响应对象
将响应事件从第一响应者顺着响应链传递，如果第一响应者无法响应将继续向父控件传递，直到找到最终响应对象。

## 如何寻找第一响应者
1. 当iOS程序发生触摸事件后，系统会利用Runloop将事件加入到UIApplication的任务队列中，具体过程可以参考[深入理解RunLoop](https://blog.ibireme.com/2015/05/18/runloop/)
2. UIApplication分发触摸事件到UIWindow，然后UIWindow依次向下分发给UIView
3. UIView调用```hitTest:withEvent:```方法看看自己能否处理事件，以及触摸点是否在自己上面。
4. 如果满足条件，就遍历UIView上的子控件。重复上面的动作。
5. 直到找到最顶层的一个满足条件（既能处理触摸事件，触摸点又在上面）的子控件，此子控件就是我们需要找到的第一响应者。

## hitTest:withEvent:的处理流程
（上面的查找其实就是由该方法递归调用实现的）
1. 首先调用当前视图的pointInside:withEvent:方法判断触摸点是否在当前视图内； 
2. 若返回NO,则hitTest:withEvent:返回nil; 
3. 若返回YES,则向当前视图的所有子视图(subviews)发送hitTest:withEvent:消息，所有子视图的遍历顺序是从最顶层视图一直到到最底层视图，即从subviews数组的末尾向前遍历，直到有子视图返回非空对象或者全部子视图遍历完毕； 
4. 若第一次有子视图返回非空对象，则hitTest:withEvent:方法返回此对象，处理结束； 
5. 如所有子视图都返回非，则hitTest:withEvent:方法返回自身(self)。 

##  hitTest:withEvent:方法的伪代码
```
//返回最适合处理事件的视图，最好在父视图中指定子视图的响应
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled || !self.hidden || self.alpha <= 0.01) {
        return nil;
    }
    
    if ([self pointInside:point withEvent:event]) {
        
        for (UIView *subView in [self.subviews reverseObjectEnumerator]) {
            CGPoint subPoint = [subView convertPoint:point fromView:self];
            
            UIView *bestView = [subView hitTest:subPoint withEvent:event];
            if (bestView) {
                return bestView;
            }
        }
        return self;
    }

    return nil;
}

```

##  事件的响应流程
通过上面的 ```hitTest:withEvent:``` 寻找到第一响应者后，需要逆着寻找第一响应者的方向（从第一响应者->UIApplication）来响应事件。
##### 流程如下
1. 首先通过 ```hitTest:withEvent:``` 确定第一响应者，以及相应的响应链
2. 判断第一响应者能否响应事件，如果第一响应者能进行响应则事件在响应链中的传递终止。如果第一响应者不能响应则将事件传递给 nextResponder也就是通常的superview进行事件响应
3. 如果事件继续上报至UIWindow并且无法响应，它将会把事件继续上报给UIApplication
4. 如果事件继续上报至UIApplication并且也无法响应，它将会将事件上报给其Delegate
5. 如果最终事件依旧未被响应则会被系统抛弃

##  需要思考的点
为什么会出现在响应链中，但是无法响应事件。
1. 这里容易产生误解，就是寻找第一响应者的过程其实只判断该视图是否具有响应触摸事件的能力，但是并没有判断是否可以响应该event。
2. 第一响应者对event的具体处理，是在事件响应的过程中进行判定的。

## 视图不响应检查要点
1. hidden = YES 视图被隐藏
2. userInteractionEnabled = NO 不接受响应事件
3. alpha <= 0.01,透明视图不接收响应事件
4. 子视图超出父视图范围
5. 需响应视图被其他视图盖住
6. 是否重写了其父视图以及自身的hitTest方法
7. 是否重写了其父视图以及自身的pointInside方法

## 参考文章
[iOS事件响应链传递的一些理解](https://blog.csdn.net/zyzxrj/article/details/53326482)

[Using Responders and the Responder Chain to Handle Events](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events)

[iOS响应链和传递机制](https://blog.csdn.net/agonie201218/article/details/71155240) 

