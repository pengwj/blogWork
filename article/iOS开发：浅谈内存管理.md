## 内存分布
*  堆：一般由程序员分配释放，若程序员不释放，则可能会引起内存泄漏。其类似于链表。
*  栈：由编译器自动分配释放，存放函数的参数值，局部变量等值。其操作方式类似于数据结构中的栈。

## 内存管理原理
OC语言使用引用计数来管理内存，每个对象都有一个可以递增和递减的计数器。如果有其他对象持用该对象的话，那该对象就递增其引用计数；用完以后就递减其计数，当引用计数为0时，就销毁该对象。

## MRC与ARC
Xcode4.2默认设定为对所有的文件ARC有效。ARC有效指的是编译器会在编译时，自动在代码中加上retain、release等语句管理内存。本质上与MRC是同一套内存管理逻辑，只是开启ARC后，由编译器帮我们管理内存而已。

## 所有权修饰符
ARC有效时，id类型和任何对象类型（对象类型就是指向NSObject这样的Objective-C类的指针）都必须附加所有权修饰符，所有权修饰符一共有四种：
*  __strong修饰符； 
*  __weak修饰符； 
*  __unsafe_unretained修饰符； 
*  __autoreleasing修饰符；

#####  __strong修饰符：
默认情况下，使用的是__strong修饰符。 
它表示的是对对象的“强引用”。持有强引用的变量在超出其作用域时被废弃，随着强引用的失效，引用的对象会随之释放。

#####  __weak修饰符： 
只使用_strong修饰符，有可能产生“循环引用”的问题。__weak修饰符与__strong修饰符相反，提供弱引用。弱引用不能持有对象实例。

#####  __unsafe_unretained修饰符
__unsafe_unretained修饰符与__weak修饰符一样不持有对象实例。但是赋值给附有__unsafe_unretained修饰符变量时，如果其值不存在时，程序会立即崩溃。

#####  __autoreleasing修饰符
__autoreleasing修饰符等价于在ARC无效时调用对象的autorelease方法。

## 属性声明与所有权修饰符的对应关系
属性声明的属性 | 所有权修饰符
-|-
assign |  __unsafe_unretained修饰符
copy | __strong修饰符(但是赋值的是被复制的对象)
retain | __strong修饰符
strong | __strong修饰符
unsafe_unretained | __unsafe_unretained修饰符
weak | __weak修饰符

## weak与strong的区别
strong类似于retain，会将对象的引用计数器+1，分配内存地址。
weak类似于指针，只是单纯的指向某个地址，但是本身并未分配内存地址。当指向的地址被销毁时，该指针会自动nil。

## weak与assign的区别
##### 1、修饰变量类型的区别
* weak 只可以修饰对象。如果修饰基本数据类型，编译器会报错。
* assign 可修饰对象，和基本数据类型。当需要修饰对象类型时，MRC时代使用unsafe_unretained。当然，unsafe_unretained也可能产生野指针，所以它名字是"unsafe_”。
##### 2、是否产生野指针的区别
* weak 不会产生野指针问题。因为weak修饰的对象释放后（引用计数器值为0），指针会自动被置nil，之后再向该对象发消息也不会崩溃。 weak是安全的。
* assign 如果修饰对象，会产生野指针问题；如果修饰基本数据类型则是安全的。修饰的对象释放后，指针不会自动被置空，此时向对象发消息会崩溃。

## strong与copy
* strong对应的setter方法,是将_property先release([_property release]),然后将参数retain([property retain]),最后_property = property.
* copy对应的setter方法,是将_property先release([_property release]),然后将参数内容copy([property copy]),创建一块新的内存地址,最后_property = property.

## weak的实现
weak的实现是基于哈希表，对象中的属性被weak修饰时，会以对象的地址为key，属性的地址为value，存储到哈希表中。当对象被销毁时，运行时会通过哈希表找到所有用weak修饰的属性，将其指针自动置为nil。

## 浅拷贝与深拷贝
##### 概念：
1. 浅拷贝
浅拷贝就是对内存地址的复制，让目标对象指针和源对象指向同一片内存空间，当内存销毁的时候，指向这片内存的几个指针需要重新定义才可以使用，要不然会成为野指针。

2. 深拷贝
深拷贝是指拷贝对象的具体内容，而内存地址是自主分配的，拷贝结束之后，两个对象虽然存的值是相同的，但是内存地址不一样，两个对象也互不影响，互不干涉。

##### 总结：
这里贴一个网友的总结
![葵花宝典.png](https://upload-images.jianshu.io/upload_images/14477290-28eca4a89816626d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## Tip：
由于文中很多知识均来自于书籍
[Objective-C高级编程 iOS与OS X多线程和内存管理](https://union-click.jd.com/jdc?e=&p=AyIGZRtYFAcXBFIZWR0yEgdWH1IdBBM3EUQDS10iXhBeGlcJDBkNXg9JHU4YDk5ER1xOGRNLGEEcVV8BXURFUFdfC0RVU1JRUy1OVxUCEQNcE10UMmJ8U2QbRXFtZw9PHHF1eVkjYgVVXGILWStcFgQWAGUYWhUDFQBVG1kRMiIHVisJe9qksY2%2B6gnWuIiAk8wlAhsHVBJdFwYSBGUbXxIDEw9WHFwcBRAPZRxbHDJJUjscWRFXEwdVSQ8UAkFQZStbFQEWDl0dWiUBIjdlG2sWMlBpUh5dQAcXVAcTUhJRF1cHEwsQBkBQAB1dEAIXDgJJC0UyEAZUH1I%3D&t=W1dCFFlQCxxKQgFHREkdSVJKSQVJHFRXFk9FUlpGQUpLCVBaTFhbXQtWVmpSWRtbFgYbD1Ma)
所以这篇文章只能算是一篇学习笔记，因为本人能力有限，如有错误，请直接留言指出。

实在是能力有限写不出比较有价值的东西，只好把网友写好的文章学习总结了一下，然后直接贴出来。本来都不好意思发表出来，但碍于自己夸下了海口说最近6个月每周一篇文章，所以这篇文章就勉强发了出来。后面还是要继续努力，不仅要坚持写博客，还要写出一些有意义有价值的东西来。
