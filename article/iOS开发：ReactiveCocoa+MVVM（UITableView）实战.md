## 前言
上一篇[文章]([https://www.jianshu.com/p/42666b1f4c05](https://www.jianshu.com/p/42666b1f4c05)
)中，笔者简单的阅读了ReactiveCocoa官方文档，了解了ReactiveCocoa的基本使用后。这篇文章主要探讨一下，如何基于MVVM的设计模式在含有UITableView界面中使用RAC绑定数据。

## MVVM
MVVM本质上是基于MVC的一个改进版，它是在传统MVC模式上添加了一个ViewModel。ViewModel可以取出 Model 的数据同时帮忙处理 View 中由于需要展示内容而涉及的业务逻辑，为Controller减压。

![MVVM](https://upload-images.jianshu.io/upload_images/14477290-a8e91c83d1bbba85.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 实战
下面笔者将基于ReactiveCocoa+MVVM+UITableView，实现一个常见的列表展示，以及按钮点击改变cell中的字体颜色。
源码地址：
[https://github.com/pengwj/blogWork/tree/master/code/ReacttiveObjC-MVVM-tableview](https://github.com/pengwj/blogWork/tree/master/code/ReacttiveObjC-MVVM-tableview)

#### Controller
移除网络请求以及数据处理后的Controller异常的简洁。我看很多人将tablevie的delegate、datasoure代理方法都放到了ViewModel中，但是考虑到这样的话ViewModel就绑定了View，所以最终决定将代理方法都放在VC中，具体可以下载我的代码看看。
```
// 核心代码如下
- (void)initViewModel {
    
    _viewModel = [MainViewModel new];
    @weakify(self)
    [_viewModel.fetchProductCommand.executing subscribeNext:^(NSNumber *executing) {
        NSLog(@"command executing:%@", executing);
        if (!executing.boolValue) {
            @strongify(self)
            [self.tableView.mj_header endRefreshing];
        }
    }];
    
    [_viewModel.fetchMoreProductCommand.executing subscribeNext:^(NSNumber *executing) {
        if (!executing.boolValue) {
            @strongify(self);
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    
    [_viewModel.errors subscribeNext:^(NSError *error) {
        NSLog(@"something error:%@", error.userInfo);
        //TODO: 这里可以选择一种合适的方式将错误信息展示出来
    }];
    
}

- (void)bindViewModel {
    @weakify(self);
    
    [RACObserve(self.viewModel, dataArray) subscribeNext:^(id x) {
        @strongify(self);
        
        NSLog(@"bindViewModel-dataArray");
        [self.tableView reloadData];
    }];
    
}
```

#### Model
model层相对MVC模式没有改变，只是简单的赋值操作。
```
//MainModel.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainModel : NSObject

@property (nonatomic, copy) NSString *rtTitle;
@property (nonatomic, copy) NSString *rtSelect;

+ (instancetype)mainModelWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
```

```
// MainModel.m
+ (instancetype)mainModelWithDic:(NSDictionary *)dic
{
    MainModel *model = [[MainModel alloc] init];
    model.rtTitle = dic[@"title"];
    model.rtSelect = dic[@"select"];
    
    return model;
}
```

#### View
View中主要做了数据绑定，监听了Model以及一些控件响应事件
```
// MainCell.m
- (void)bindData
{
    @weakify(self)
    [RACObserve(self, model.rtTitle) subscribeNext:^(id x) {
        
        @strongify(self)
        self.rtLabel.text = self.model.rtTitle;
        
    }];
    
    [RACObserve(self, model.rtSelect) subscribeNext:^(id x) {
        
        if ([self.model.rtSelect isEqualToString:@"0"]) {
            self.rtLabel.textColor = [UIColor yellowColor];
        } else {
            self.rtLabel.textColor = [UIColor redColor];
        }
    }];
    
    self.rtButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input){
        NSLog(@"按钮被点击");
        
        if ([self.model.rtSelect isEqualToString:@"0"]) {
            self.model.rtSelect = @"1";
        } else {
            self.model.rtSelect = @"0";
        }
        
        return [RACSignal empty];
    }];
}
```

#### ViewModel
 ViewModel中需要实例化网络请求的RARACCommand，以及监听网络请求回来的数据，并对数据做相应的逻辑处理。
```
- (void)initCommed
{
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    
    @weakify(self)
    _fetchProductCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.pageIndex = 0;
        return [[[APIClient sharedClient]
                        fetchProductWithPageIndex:self.pageIndex]
                        takeUntil:self.cancelCommand.executionSignals];
    }];
    
    _fetchMoreProductCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        self.pageIndex = self.pageIndex+1;
        return [[[APIClient sharedClient] fetchProductWithPageIndex:self.pageIndex] takeUntil:self.cancelCommand.executionSignals];
    }];
    
}

- (void)initSubscribe {
    
    @weakify(self);
    [[_fetchProductCommand.executionSignals switchToLatest] subscribeNext:^(id responseObject) {
        @strongify(self);
        
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        
        NSInteger code = [[responseDict objectForKey:@"code"] integerValue];
        
        if (code == 0) {
            
            NSArray *infoArray = [responseDict objectForKey:@"info"];
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            
            [infoArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic,NSUInteger idx,BOOL * _Nonnull stop){
                
                MainModel *model = [MainModel mainModelWithDic:dic];
                [tempArray addObject:model];
                
            }];

            /// ⚠️⚠️⚠️注意这里需要通过KVC的方式对数组进行操作
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.dataArray.count, [tempArray count])];
            [[self mutableArrayValueForKey:@"dataArray"] insertObjects:tempArray atIndexes:indexSet];
            
        } else {
            
            [self.errors sendNext:[NSError new]];
        }

    }];
    
    [[_fetchMoreProductCommand.executionSignals switchToLatest] subscribeNext:^(id responseObject) {
        @strongify(self);
        
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSInteger code = [[responseDict objectForKey:@"code"] integerValue];
        
        if (code == 0) {
            
            NSArray *infoArray = [responseDict objectForKey:@"info"];
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];

            [infoArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic,NSUInteger idx,BOOL * _Nonnull stop){
                
                MainModel *model = [MainModel mainModelWithDic:dic];
                [tempArray addObject:model];

            }];
            
            /// ⚠️⚠️⚠️注意这里需要通过KVC的方式对数组进行操作
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.dataArray.count, [tempArray count])];
            [[self mutableArrayValueForKey:@"dataArray"] insertObjects:tempArray atIndexes:indexSet];
            
        } else {
            
            [self.errors sendNext:[NSError new]];
        }
    }];
    
    [[RACSignal merge:@[_fetchProductCommand.errors, self.fetchMoreProductCommand.errors]] subscribe:self.errors];
}
```

## 遇到的坑
直接获取NSMutableArray进行操作不会触发RAC的监听信号，所以这里需要通过KVC来添加、移除数据。
```
// 通过KVC获取数组
- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;

// eg 
// 正确的例子
[[self mutableArrayValueForKey:@"dataArray"] addObjectsFromArray:tempArray];

// 错误的例子
[self.dataArray addObjectsFromArray:tempArray];
```

## 总结
可能是由于这个是前几年比较火的技术，我在网上查找了很多资料都没有一个比较完整、统一的实现方法。主要集中如下：
1. UITableView的代理方法、数据源回调方法是否需要封装到ViewModel中
2. dataArray数据存储数组是放在ViewModel中，还是放在VC中
3. Cell的数据绑定理应是应用RAC监听Model的变化，但是部分文章的实现依然是主动调用方法去刷新
最终笔者选择了一个还比较符合心目中对MVVM理解的[文章](https://www.cnblogs.com/manji/p/4846591.html)进行学习，然后实现了这个demo。

ReactiveCocoa发展之际可能刚好遇到swift横空出世，导致RAC在OC还没有完全普及，大量开发者就转向swift以及RxSwift了。目前网上搜索RAC的文章都是几年前的，而RxSwift则都是最新的文章。这里在此立个flag，要开始学习swift啦。

## 推荐阅读：
#### 文章
[RACObserving an NSMutableArray](https://github.com/ReactiveCocoa/ReactiveCocoa/issues/1197)
 [一次MVVM+ReactiveCocoa实践](https://www.cnblogs.com/manji/p/4846591.html)
[ReactiveCocoa+MVVM实战](https://www.jianshu.com/p/cb1eaccb5b6f)
[iOS如何为NSMutableArray添加KVO](https://blog.csdn.net/caryaliu/article/details/49284185)

#### 源码
[MVVMReactiveCocoa](https://github.com/DreamcoffeeZS/MVVMReactiveCocoa)
[MVVMReactiveCocoaDemo](https://github.com/wujunyang/MVVMReactiveCocoaDemo)
[MVVMDemo](https://github.com/defaultyuan/MVVMDemo)
[MVVMReactiveCocoa](https://github.com/leichunfeng/MVVMReactiveCocoa)
