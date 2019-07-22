Tagged Pointer 是自从iPhone 5s 之后引入的特性

1 先说一下iOS的内存布局


![](https://github.com/AlexanderYeah/AT_Runtime/blob/master/3-Tagged%20Pointer/ex1.png)

* 代码区：存放编译之后的代码
* 数据段 ：字符串常量 ： NSString *hello = @"hello";已经初始化和未初始化的全局变量，静态变量
* 堆：通过alloc，malloc,calloc 动态分配的内存空间
* 栈 ：函数调用开销，局部变量

```objc
    // 静态变量 
    static int a = 1;
    // 静态变量
    static int b;
    // 部变量 栈上
    int e;
    // 局部变量 栈上
    int d = 2;
    // 字符串常量
    NSString *hello = @"hello";
    // 堆上
    NSObject *obj = [[NSObject alloc]init];
```





2  Tagged Pointer

这个技术的出现就是为了优化NSNumber，NSString 等小对象的存储，

在之前的话是一个指针代表一个地址，现在的话是直接将数据存储到指针本身，一个指针就代表一个值。

当指针不够存储数据的时候，才会使用动态分配内存的方式来存储数据。

没有了malloc 和 free 的过程，提高了执行效率

```objective-c
    NSNumber *num1 = @10;
    NSNumber *num2 = @20;
    NSNumber *num3 = @30;
//    (lldb) p num1
//    (__NSCFNumber *) $0 = 0x9d864a09dabb7827 (int)10
//    (lldb) p num2
//    (__NSCFNumber *) $1 = 0x9d864a09dabb79c7 (int)20
//    (lldb) p num3
//    (__NSCFNumber *) $2 = 0x9d864a09dabb7967 (int)30
//    (lldb)
```

