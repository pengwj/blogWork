# 前言
上周尝试着对新项目进行了组件化的尝试，开始选择的是蘑菇街的方案（[文章1](https://limboy.me/tech/2016/03/10/mgj-components.html)、[文章2](https://limboy.me/tech/2016/03/14/mgj-components-continued.html)），但是后来发现所有的组件都需要在```+(void)load```方法中注册，这个让我十分抵触，然后因为项目时间原因，就暂时方式了该方案。今天在看```戴铭大神```的博客是发现了[基于CTMediator 扩展的ArchitectureDemo](https://github.com/ming1016/ArchitectureDemo)，然后想起来```casatwy大神```当时也有一套解决方案 [iOS应用架构谈 组件化方案](https://casatwy.com/iOS-Modulization.html)，今天就来学习一下，然后写个练习的demo。

# 重点
本文内容基本都是基于casatwy的文章[在现有工程中实施基于CTMediator的组件化方案](https://casatwy.com/modulization_in_action.html)的练习，大家可以对照的看一下。

# 实现步骤
##### 在[github](https://github.com/)上创建私有仓库
![WJPrivatePods.png](https://upload-images.jianshu.io/upload_images/14477290-b28fb1f556afc83f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 添加私有仓库索引到本地
```
pod repo add WJPrivatePods https://github.com/pengwj/WJPrivatePods.git
```

##### 在本地新建文件夹
在本地新建文件夹WJCTMediatorProject，然后下载casatwy的源码[https://github.com/ModulizationDemo/MainProject](https://github.com/ModulizationDemo/MainProject)文件夹中。目录结构如下：
```
WJCTMediatorProject
└── MainProject
```
MainProject下载后，在MainProject目录下执行一下```pod install```拉取一下工程依赖的库，然后设置```File->Workspace Setting->Build System```为```Legacy Build System```。

##### ~~配置私有库文件工具脚本~~
由于casatwy提供的工具脚本，```github.com:casatwy/ConfigPrivatePod.git```好像已经无法拉取了，所有后面需要我们手动配置私有库。这里就先不配置了。

##### 创建私有Pod工程和Category工程
跟着casatwy的博客来，此次组件化的实施目标就是把A业务组件化出来，首页和B业务都还放在主工程。
为了把A业务抽出来作为组件，我们需要为此做两个私有Pod：A业务Pod（以后简称A Pod）、方便其他人调用A业务的CTMediator category的Pod（以后简称A_Category Pod）。

##### 先创建A Pod
由于没有私有库配置脚本，我们需要通过```pod lib create NAME```来新建A Pod，通过cd指令到Project目录下，然后执行```pod lib create NAME```指令。
```
pod lib create A
```
A为我们的NAME。执行后需要填写一些信息，如下图。
![pod lib create.png](https://upload-images.jianshu.io/upload_images/14477290-e5ea30181810a29a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此时你的主工程应该就没有A业务的代码了，然后你的A工程应该是这样：
![A工程](https://upload-images.jianshu.io/upload_images/14477290-a5724a447c9de5bd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 创建A_Categoty pod
重复上一步操作，通过cd指令到Project目录下，然后执行```pod lib create NAME```指令创建名为A_Categoty的pod。

##### 配置A_Categoty
然后去A_Category下，在Podfile中添加一行pod "CTMediator"，在A_Category.podspec文件的后面添加s.dependency "CTMediator"，然后执行pod install --verbose。

接下来打开A_Category.xcworkspace，把Example同目录下的名为A_Category的目录拖放到Xcode对应的位置下。
![A_Category](https://upload-images.jianshu.io/upload_images/14477290-9b455008d64b903a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后在这里新建基于CTMediator的Category：CTMediator+A。最后你的A_Category工程应该是这样的：
![CTMediator+A](https://upload-images.jianshu.io/upload_images/14477290-f147e1a789760f9f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 配置主工程
去主工程的Podfile下添加pod "A_Category", :path => "../A_Category"来本地引用A_Category。
把主工程中的AViewController头文件引用改成#import <A_Category/CTMediator+A.h>

然后执行```pod install```拉取一下A_Category链接。这个时候主工程依然无法编译通过。

打开主工程，在```Development Pods```目录下面找到```CTMediator+A.h```，在里面添加一个方法：
```
- (UIViewController *)A_aViewController;
```
再去CTMediator+A.m中，补上这个方法的实现：
```
- (UIViewController *)A_aViewController
{
    /*
        AViewController *viewController = [[AViewController alloc] init];
     */
    return [self performTarget:@"A" action:@"viewController" params:nil shouldCacheTarget:NO];
}
```
最后把主工程调用```AViewController ```的地方改为基于CTMediator Category的实现：
```
UIViewController *viewController = [[CTMediator sharedInstance] A_aViewController];
[self.navigationController pushViewController:viewController animated:YES];
```
编译一下，如果能运行成功，并出现下面界面，就表示已经完成了对主工程的改造。
![主工程运行结果](https://upload-images.jianshu.io/upload_images/14477290-d13bc6d9aac4481f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 添加Target-Action，并让A工程编译通过
打开A_Category工程和A工程，在A工程中创建一个文件夹：Targets，然后看到A_Category里面有performTarget:@"A"，所以我们新建一个对象，叫做Target_A。
然后又看到对应的Action是viewController，于是在Target_A中新建一个方法：Action_viewController。这个Target对象是这样的：
```
头文件：
#import <UIKit/UIKit.h>

@interface Target_A : NSObject

- (UIViewController *)Action_viewController:(NSDictionary *)params;

@end

实现文件：
#import "Target_A.h"
#import "AViewController.h"

@implementation Target_A

- (UIViewController *)Action_viewController:(NSDictionary *)params
{
    AViewController *viewController = [[AViewController alloc] init];
    return viewController;
}

@end
```
##### 添加B_Category
同上面```创建A_Categoty pod```和```配置A_Categoty```的步骤，CTMediator+B的实现如下：
```
//头文件：
#import <CTMediator/CTMediator.h>
#import <UIKit/UIKit.h>

@interface CTMediator (B)

- (UIViewController *)B_viewControllerWithContentText:(NSString *)contentText;

@end

//实现文件：
#import "CTMediator+B.h"

@implementation CTMediator (B)

- (UIViewController *)B_viewControllerWithContentText:(NSString *)contentText
{
    /*
        BViewController *viewController = [[BViewController alloc] initWithContentText:@"hello, world!"];
     */
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"contentText"] = contentText;
    return [self performTarget:@"B" action:@"viewController" params:params shouldCacheTarget:NO];
}

@end

```
文件目录如下：
![B_Category](https://upload-images.jianshu.io/upload_images/14477290-1342c4d3ba9b7e1a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后我们对应地在A工程中修改头文件引用为#import <B_Category/CTMediator+B.h>，并且把调用的代码改为：

```
    UIViewController *viewController = [[CTMediator sharedInstance] B_viewControllerWithContentText:@"hello, world!"];
    [self.navigationController pushViewController:viewController animated:YES];
```
再编译一下，发现编译依然失败了，这是因为A工程中没有导入相关pod。打开A工程的Podfile文件，添加如下的配置项。然后执行```pod install```
```
 //  后面的“path”需要注意一下，这个需要根据你的项目情况配置
  pod "B_Category", :path => "../../B_Category"
// 这个是casatwy源码中依赖的布局库
  pod 'HandyFrame'
```
##### 新增Target_B对象
打开主工程```MainProject```,然后新建Target_B对象
```
//Target_B头文件：
#import <UIKit/UIKit.h>

@interface Target_B : NSObject

- (UIViewController *)Action_viewController:(NSDictionary *)params;

@end

//Target_B实现文件：
#import "Target_B.h"
#import "BViewController.h"

@implementation Target_B

- (UIViewController *)Action_viewController:(NSDictionary *)params
{
    NSString *contentText = params[@"contentText"];
    BViewController *viewController = [[BViewController alloc] initWithContentText:contentText];
    return viewController;
}

@end
```

然后编译运行一下MainProject，看看能不能成功跳转，如果不能成功跳转可以按照下面顺序检查一下```Podfile```文件。
###### 
```
// MainProject的Podfile文件
  pod 'HandyFrame'
  pod "A_Category", :path => "../A_Category"
  pod "B_Category", :path => "../B_Category"
  pod "A",:path => "../A"
  pod 'CTMediator'
```
```
// A工程的Podfile文件
  pod "B_Category", :path => "../../B_Category"
  pod 'HandyFrame'
```
```
// A_Category工程的Podfile文件
  pod 'A_Category', :path => '../'
  pod "CTMediator"
```
```
// B_Category工程的Podfile文件
  pod 'B_Category', :path => '../'
  pod "CTMediator"
```
这里先上传一份未发版的工程文件，大家可以对照一下。
[https://github.com/pengwj/blogWork/blob/master/code/WJCTMediatorProject.zip](https://github.com/pengwj/blogWork/blob/master/code/WJCTMediatorProject.zip)

##### 私有Pod发版
~~我们创建了三个私有Pod：A、A_Category、B_Category，接下来我们要给这三个私有Pod发版，发版之前去podspec里面确认一下版本号和dependency。~~
私有库发版折腾失败了，还在研究中。。。

# 推荐阅读
[iOS应用架构谈 组件化方案](https://casatwy.com/iOS-Modulization.html)
[在现有工程中实施基于CTMediator的组件化方案](https://casatwy.com/modulization_in_action.html)
[iOS关于CTMediator组件化实践的详解篇](https://www.jianshu.com/p/b1c6d070c92b)
[iOS组件化开发之路（CTMediator），涉及到cocoapods本地库、远程私有库、远程公开库](https://www.jianshu.com/p/846ba27b75d0)


