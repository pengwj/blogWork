# 前言
截止上周，终于把剑指offer简单的看完了。因为一直对算法有一种恐惧感，所以这次没有看具体的代码实现，只是大概的看了一下算法思路，对算法有个具体的印象。看完后，发现算法其实也没有想象中那么可怕。

昨天开始二刷，这此对自己的要求是看懂代码实现，并能借助编译器实现大部分的算法。那么问题就来了，剑指offer的算法实现都是C++实现的，而我的C++在大学课程结束后就全还给老师了。所以如果为了好好刷算法的话，重新学习一下C或者C++，看来是必不可少的了。

# Xcode编译C++
Xcode已经集成了gcc编译环境，所以我们可以直接通过Xcode练习算法，具体步骤如下图。
## 1. 新建工程
![新建工程](https://upload-images.jianshu.io/upload_images/14477290-df5560512598a7a9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 2.选择工程类型
macOS->Command Line Tool
![选择工程类型](https://upload-images.jianshu.io/upload_images/14477290-a0b60763baa41d44.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 3. 选择语言
语言选择C++
![选择语言](https://upload-images.jianshu.io/upload_images/14477290-19f48cd7db601231.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 剑指offer题目
这里练习记忆一下

## 面试题1:赋值运算符函数
```
题目：如下为类型CMyString的声明，请为该类型添加赋值运算符函数。
class CMyString
{
public:
    CMyString(char* pData = nullptr);
    CMyString(const CMyString& str);
    ~CMyString(void);
        
private:
    char* m_pData;
};
```
实现：
```
CMyString& CMyString::operator=(const CMyString &str)
{
    if (this != &str) {
        CMyString strTemp(str);
        
        char* pTemp = strTemp.m_pData;
        strTemp.m_pData = m_pData;
        m_pData = pTemp;
    }
    return *this;
}
```
## 面试题2:实现Singleton模式
```
题目：设计一个类，我们只能生成该类的一个实例。
```
实现：
```
1、利用静态构造函数 
public sealed class Singleton4
{
    private Singleton4()
    {
        
    }
    
    private static Singleton4 instance = new Singleton4();
    public static Singleton4 Instance
    {
        get
        {
            return instance;
        }
    }
    
}

2、实现按需创建实例
public sealed class Singleton5
{
    private Singleton5()
    {
        
    }
    
    public static Singleton5 Instance
    {
        get
        {
            return Nested.instance;
        }
    }
    
    class Nested
    {
        static Nested()
        {
            
        }
        
        internal static readonly Singleton5 instance = new Singleton5();
    }
    
}
```
## 面试题3:数组中重复的数字
```
题目：找出数组中重复的数字
在一个长度为n的数组里的所有数字都在1～n-1的范围内。数组中某些数字是重复的，但不知道有几个数字重复了，也不知道每个数字重复了几次。请找出数组中任意一个重复的数字。例如，如果输入长度为7的数组{2，3，1，0，2，5，3}，那么对应的输出是重复的数字2或者3.
```
实现：
```

bool duplicate(int numbers[],int length,int* duplication)
{
    if (numbers == nullptr || length<=0) {
        return false;
    }
    
    for (int i=0; i<length; ++i) {
        while (numbers[i]!=i) {
            if (numbers[i] == numbers[numbers[i]]) {
                *duplication = numbers[i];
                return true;
            }
            
            // swap
            int temp = numbers[i];
            numbers[i] = numbers[temp];
            numbers[temp] = temp;
        }
    }
    return false;
}
//总算遇到了一个凭我浅薄的C语言基础能理解的算法了
```

# 总结
没啥好说的了，多多练习，从零开始咯
