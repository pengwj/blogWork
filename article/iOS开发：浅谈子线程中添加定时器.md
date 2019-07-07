## 目标
开启一个子线程，并添加一个定时器，在进入界面时启动定时器，在退出界面时销毁定时器。

## demo地址
[https://github.com/pengwj/blogWork/tree/master/code/TimerTest](https://github.com/pengwj/blogWork/tree/master/code/TimerTest)

## 注意点
1、定时器默认添加在NSDefaultRunLoopMode，界面滑动时会导致定时器停止执行。
2、子线程中RunLoop默认不启动，所以需要往里面添加任务，然后手动启动runloop。

## RunLoop
每一个线程创建的时候，都至少会创建一个RunLoop，孙源大佬的视频中有提到RunLoop可以嵌套，这里就不展开了。
##### 系统默认注册五个Mode的RunLoop
* kCFRunLoopDefaultMode：app的默认mode，一般代码执行都在这个mode先运行的。
* UITrackingRunLoopMode：界面滑动mode，为了提升滑动时的流畅度，当界面滚动时（多用于ScrollView的滑动触摸）系统会强制切换到该mode下。
* UIInitializationRunLoopMode：在app刚启动时会调用该mode，执行启动相关操作，启动后就不再使用。
* GSEventReceiveRunLoopMode：接收内部系统事件的mode，开发中通常用不上。
* kCFRunLoopCommonModes：组合mode，并不是一个实际的mode，当注册该mode时会同时在kCFRunLoopDefaultMode和UITrackingRunLoopMode两个mode中注册。

##### 界面滑动时强制切换到UITrackingRunLoopMode
iOS系统为了避免滑动时需要处理太多的事件，单独为其设置了一个mode，当界面滑动时，强制切换到UITrackingRunLoopMode下，其他mode中的事件均不可执行。而定时器默认是添加到kCFRunLoopDefaultMode下，所以在滑动时mode切换到UITrackingRunLoopMode，定时器停止运行，在停止滑动后才会继续运行。
#####如何保障定时器在滑动时也可以持续的运行
在上面讲到当注册kCFRunLoopCommonModes时，该mode时会同时在kCFRunLoopDefaultMode和UITrackingRunLoopMode两个mode中注册，这样就可以保障定时器在滑动以及不滑动时均可以持续运行。
```
 [[NSRunLoop currentRunLoop] addTimer:strongSelf.timer forMode:NSRunLoopCommonModes];
```
##### 在子线程中我们像上面那样添加定时器会发现定时器不会执行
上面的代码可以将定时器加到runloop中，但是子线程中runloop默认未开启，所以代码最终不会执行。我们需要单独启动runloop。
```            
// 错误的示范
[[NSRunLoop currentRunLoop] run];
strongSelf.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerDown) userInfo:nil repeats:YES];            
[[NSRunLoop currentRunLoop] addTimer:strongSelf.timer forMode:NSRunLoopCommonModes];            
```
##### 如果我们按照上面的代码，会发现定时器依旧不执行
这里需要简单了解一下runloop，runloop本质上是一个while循环，当其有任务时，就会执行，没有任务会休息，如果按照上面的代码，当执行```[[NSRunLoop currentRunLoop] run];```时，runloop被启动，发现没有任务，就会继续进入休眠状态，后面添加定时器的代码就会失效。所以我们需要先添加timer，然后再启动runloop。
```
// 正确的示范            
strongSelf.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerDown) userInfo:nil repeats:YES];            
[[NSRunLoop currentRunLoop] addTimer:strongSelf.timer forMode:NSRunLoopCommonModes];            
[[NSRunLoop currentRunLoop] run];
```
##### 定时器的停止
定时器会导致当前的target引用计数+1，所以当停止定时器时，需要对定时器进行置空操作。
```        
[strongSelf.timer invalidate];        
strongSelf.timer = nil;
```
