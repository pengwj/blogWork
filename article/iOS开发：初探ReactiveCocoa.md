## 前言
----
上次接触ReactiveCocoa已经是三年前的事情了，最近公司开新项目了，我选择了MVVM+ReactiveCocoa架构，但是开始撸代码时发现RAC的接口好像变化很大，就再此学习一下。

## 框架引入
----
##### 框架介绍
为了适应Objective-C、swift，ReactiveCocoa将代码拆分为四个库：ReactiveCocoa（集中于UI）、ReactiveSwift（swift版）、ReactiveObjC（OC版）、ReactiveObjCBridge（桥接）。

笔者新项目是以OC语言开发的，主要是讲解ReactiveObjC的使用

##### 框架集成
笔者采用cocoapods来管理的，这里吐槽一下，ReactiveObjC的介绍页面居然都没有相应的集成语句。
```
pod 'ReactiveObjC'
```

## 主要的类
----
ReactiveCocoa主要由下面四个核心组件组成：
1. 信号源：RACStream以及其子类
2. 订阅者：实现RACSubscriber协议的类
3. 调度器：RACScheduler以及其子类
4. 清洁工：RACDisposable以及其子类

### 信号源
#### RACStream
RACStream是一个抽象的类，任何对象的序列都可以理解为stream，在开发中我们一般是应用他的子类[RACSignal](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACSignal.h)
、[RACDisposable](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACDisposable.h)来进行开发。

#### RACSignal
RACSignal是我们开发中用的最多的一个类，RACSignal通常表示将要交付的数据，必须要有订阅者订阅后才可以发送数据。
RACSignal可以向订阅者发送以下三种不同的事件： 
1. **next** 事件:该事件从流中提供一个新值，以传递给下一个订阅者。
2. **error** 事件：该事件表示在信号结束前出现了错误，该事件可以携带一个NSError对象传递。
3. **completed**事件：该事件表示信号已经完成，清洁工将开始销毁相应对象。
在日常开发中，一般是由一个或者多个**next** 事件，以及一个**error** 事件或者**completed**事件组成。

##### RACSignal提供了以下操作符（可理解为方法）方便我们处理信号：(该示例代码来自：[ReactiveCocoa文档](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/Documentation/BasicOperators.md#merging))
1. [+merge](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACSignal+Operations.h) merge操作符：将多个信号集中到一个信号中，任意一个信号中有数据到达就触发一下。
```
RACSubject *letters = [RACSubject subject];
RACSubject *numbers = [RACSubject subject];
RACSignal *merged = [RACSignal merge:@[ letters, numbers ]];

// Outputs: A 1 B C 2
[merged subscribeNext:^(NSString *x) {
    NSLog(@"%@", x);
}];

[letters sendNext:@"A"];
[numbers sendNext:@"1"];
[letters sendNext:@"B"];
[letters sendNext:@"C"];
[numbers sendNext:@"2"];
```

2.  [-flatten](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACStream.h): flatten操作符表示将多个信号集中到一个信号中，类似于merge
```
RACSubject *letters = [RACSubject subject];
RACSubject *numbers = [RACSubject subject];
RACSignal *signalOfSignals = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
    [subscriber sendNext:letters];
    [subscriber sendNext:numbers];
    [subscriber sendCompleted];
    return nil;
}];

RACSignal *flattened = [signalOfSignals flatten];

// Outputs: A 1 B C 2
[flattened subscribeNext:^(NSString *x) {
    NSLog(@"%@", x);
}];

[letters sendNext:@"A"];
[numbers sendNext:@"1"];
[letters sendNext:@"B"];
[letters sendNext:@"C"];
[numbers sendNext:@"2"];
```

3. [-flattenMap](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACStream.h)：flattenMap操作符会创建多信号
```
RACSignal *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;

[[letters
    flattenMap:^(NSString *letter) {
        return [database saveEntriesForLetter:letter];
    }]
    subscribeCompleted:^{
        NSLog(@"All database entries saved successfully.");
    }];
```

4. [-then](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACSignal+Operations.h) then操作符：创建并启动一个信号，执行后替换信号中的数据。
```
RACSignal *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;

// The new signal only contains: 1 2 3 4 5 6 7 8 9
//
// But when subscribed to, it also outputs: A B C D E F G H I
RACSignal *sequenced = [[letters
    doNext:^(NSString *letter) {
        NSLog(@"%@", letter);
    }]
    then:^{
        return [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence.signal;
    }];
```

#### RACSubject
RACSubject是RACSignal的子类，可以创建一个可以手动控制的信号。

##### RACSubject提供了以下操作符（可理解为方法）方便我们处理信号
1. [+combineLatest:](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACSignal+Operations.h) combineLatest操作符：监视多个信号，然后在发生变化时从所有信号中发送最新的值。
```
RACSubject *letters = [RACSubject subject];
RACSubject *numbers = [RACSubject subject];
RACSignal *combined = [RACSignal
    combineLatest:@[ letters, numbers ]
    reduce:^(NSString *letter, NSString *number) {
        return [letter stringByAppendingString:number];
    }];

// Outputs: B1 B2 C2 C3
[combined subscribeNext:^(id x) {
    NSLog(@"%@", x);
}];

[letters sendNext:@"A"];
[letters sendNext:@"B"];
[numbers sendNext:@"1"];
[numbers sendNext:@"2"];
[letters sendNext:@"C"];
[numbers sendNext:@"3"];
```

2.  [-switchToLatest](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACSignal+Operations.h) ：switchToLatest操作符：只监控最新的sendNext发送的信号
```
RACSubject *letters = [RACSubject subject];
RACSubject *numbers = [RACSubject subject];
RACSubject *signalOfSignals = [RACSubject subject];

RACSignal *switched = [signalOfSignals switchToLatest];

// Outputs: A B 1 D
[switched subscribeNext:^(NSString *x) {
    NSLog(@"%@", x);
}];

[signalOfSignals sendNext:letters];
[letters sendNext:@"A"];
[letters sendNext:@"B"];

[signalOfSignals sendNext:numbers];
[letters sendNext:@"C"];
[numbers sendNext:@"1"];

[signalOfSignals sendNext:letters];
[numbers sendNext:@"2"];
[letters sendNext:@"D"];
```


#### RACSequence
RACSequence表示序列的一个流数据，他为Cocoa中常见的集合都添加了``` -rac_sequence```方法，并且提供了很多方法以便我们处理数据。

##### RACSequence提供了以下操作符（可理解为方法）方便我们处理数据：
1.  [-map操作符](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACStream.h) :遍历RACSequence中的数据并返回一个带有新数据的流。
```
RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;

// Contains: AA BB CC DD EE FF GG HH II
RACSequence *mapped = [letters map:^(NSString *value) {
    return [value stringByAppendingString:value];
}];
```

2.  [-filter操作符](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACStream.h)：一般是用来过滤数据的。
```
RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;

// Contains: 2 4 6 8
RACSequence *filtered = [numbers filter:^ BOOL (NSString *value) {
    return (value.intValue % 2) == 0;
}];
```
3. [-concat操作符](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACStream.h)：将一个流包含的值添加到另外一个流中。
```
RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;
RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;

// Contains: A B C D E F G H I 1 2 3 4 5 6 7 8 9
RACSequence *concatenated = [letters concat:numbers];
```
4.  [-flatten操作符](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACStream.h)：将多个流的数据联合起来，并添加到一个新的流中。（此处可以多个流一起添加，此处的解释是RACSequence的应用，该方法在RACSignal中等同于[merged](https://github.com/ReactiveCocoa/ReactiveCocoa/tree/v2.5/Documentation#merging)）

5.  [-flattenMap操作符](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/v2.5/ReactiveCocoa/RACStream.h)：flattenMap将一个流中的每个值转换成一个新的流，即``` -map: ```后执行```-flatten```操作。


### 订阅者
#### RACSubscriber协议
所有遵守了RACSubscriber协议的对象都可以成为订阅者（Subscriber），订阅者订阅信号后可以收到相应信号的所有事件。

订阅的方法如下：
```
// 仅订阅next类型事件：
- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock;
// 仅订阅next和error类型事件：
- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock;
// 同时订阅三种类型事件：
- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock;
// 以及其他订阅方法
- (RACDisposable *)subscribeError:(void (^)(NSError *error))errorBlock;	
- (RACDisposable *)subscribeCompleted:(void (^)(void))completedBlock;	
- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock completed:(void (^)(void))completedBlock;	- (RACDisposable *)subscribeError:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock;

```

### 调度器
####  RACScheduler
RACScheduler是基于GCD的串行队列实现的，用来统一调度消息订阅过程中的任务。

### 清洁工
#### RACDisposable
RACDisposable 常用于信号取消订阅时，当订阅取消时，他将执行一些资源回收的工作。

## 其他的方法
----
### Commands命令类
#### RACCommand
RACCommand常用于绑定UI界面触发命令，并执行相应信号。他为常见的UI控件添加了```rac_command```属性，并传递相应信号。
```
// target-action
self.button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    NSLog(@" 按钮被点击 ");
    return [RACSignal empty];
}];
```

### 添加KVO
```
[RACObserve(self, username) subscribeNext:^(id x) {
    NSLog(@" 成员变量 username 被修改成了：%@", x);
}];
```

### 添加Notification
```
[[[NSNotificationCenter defaultCenter] 
    rac_addObserverForName:UIKeyboardDidChangeFrameNotification         
                    object:nil] 
    subscribeNext:^(id x) {
        NSLog(@" 键盘 Frame 改变 ");
    }
];
```

### 添加Delegate
```
[[self rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(id x) {
    debugLog(@"viewWillAppear 方法被调用 %@", x);
}];
```

## 感受
----
本来今天的计划是阅读一下源码，然后写一篇有些技术深度的文章，但是在花了一天的时间，看完官方的[introduction](https://github.com/ReactiveCocoa/ReactiveObjC#introduction
)、[Documentation](https://github.com/ReactiveCocoa/ReactiveObjC/tree/master/Documentation)，以及相关资料后，发现自己实在是能力有限，希望再接再厉。
不过在阅读英文文档的过程中，发现自己的英文阅读能力好像比自己想象中好很多。另外也发现了swift在行业的影响力越来越大了，后面看来要开始拥抱swift了。

## 推荐阅读
https://github.com/ReactiveCocoa/ReactiveObjC/tree/master/Documentation
https://github.com/ReactiveCocoa/ReactiveObjC#introduction
http://blog.leichunfeng.com/blog/2015/12/25/reactivecocoa-v2-dot-5-yuan-ma-jie-xi-zhi-jia-gou-zong-lan/ 
https://www.jianshu.com/p/596e2dac20fb
https://www.jianshu.com/p/4e3dd049cfc8
