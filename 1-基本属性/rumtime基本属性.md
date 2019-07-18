## 基础定义

[objc-750 的tar包](https://opensource.apple.com/tarballs/objc4/)

objc-private.h 定义

```c

typedef struct objc_class *Class;
typedef struct objc_object *id;


#if __OBJC2__
typedef struct method_t *Method;
typedef struct ivar_t *Ivar;
typedef struct category_t *Category;
typedef struct property_t *objc_property_t;
#else
typedef struct old_method *Method;
typedef struct old_ivar *Ivar;
typedef struct old_category *Category;
typedef struct old_property *objc_property_t;
#endif
```



#### 一  Method 方法（包含SEL 和 IMP）

在 objc-runtime-new.h 文件中 找到 method 结构体的定义

```c
struct method_t {
    SEL name;
    const char *types;
    MethodListIMP imp;

    struct SortBySELAddress :
        public std::binary_function<const method_t&,
                                    const method_t&, bool>
    {
        bool operator() (const method_t& lhs,
                         const method_t& rhs)
        { return lhs.name < rhs.name; }
    };
};
```



1 IMP  本质是函数指针 （Implementation）

是一个函数的指针，保存了方法的地址，每一个方法都对应有一个IMP

2 SEL 类方法名称的描述，只记录方法的编号不记录具体的方法，具体的方法是 IMP。



获取SEL 的两种方式

```objective-c
    SEL sel1 = NSSelectorFromString(@"dealloc");
    SEL sel2 = @selector(viewDidLoad);
```



获取IMP的两种方式

```objective-c
    // 实例方法 - (IMP)methodForSelector:(SEL)aSelector;
    NSLog(@"%p",[self methodForSelector:sel1]);
    // 类方法   + (IMP)instanceMethodForSelector:(SEL)aSelector;
    NSLog(@"%p",[[self class] instanceMethodForSelector:sel2]);
```



获取方法获取IMP

```objective-c
    // 获取一个类的实例的方法
    Method method = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    
    // 通过该实例方法IMP 函数指针
    IMP method_imp = method_getImplementation(method);
    
    NSLog(@"%p",method_imp);
```



#### 二  属性 Property

@property 修饰过的属性，修饰后变为objc_property_t

```objective-c
struct property_t {
	const char *name;
	const char *attributes;
};
```

获取属性列表 和 协议列表

```objective-c
    // 获取注册类的所有属性列表
    objc_property_t * ptys = class_copyPropertyList([obj class], &count);
    // 获取注册类的所有协议列表
    objc_property_t * pros = class_copyPropertyList([obj class], &count);

```

获取一个类的所有属性

```objective-c
// 获取一个类的所有的属性
- (NSMutableArray *)getAllPropertyNames:(id)obj
{
    unsigned int count;
    // 获取注册类的所有属性列表
    objc_property_t * ptys = class_copyPropertyList([obj class], &count);
    // 获取注册类的所有属性列表
    NSMutableArray *resArr = [NSMutableArray array];
    for (int i = 0 ; i < count ; i ++) {
        objc_property_t pty = ptys[i];
        // 获得属性名
        NSString *ptyName = [NSString stringWithFormat:@"%s",property_getName(pty)];
        NSLog(@"%@",ptyName);
        [resArr addObject:ptyName];
        
    }    
    free(ptys);
    return resArr;        
}

```



#### 三 成员变量 objc_ivar 类型 

ivar 是  objc_ivar 的指针 包含变量名，变量类型，基地址偏移量，在对成员变量寻址时使用。

```objective-c
  struct objc_ivar {
         char *ivar_name;
         char *ivar_type;
         int ivar_offset;
      #ifdef __LP64__
         int space;
      #endif
  } 
```



获取一个类所有的成员变量别表 class_copyIvarList

后去一个类所有的成员变量的名字 ivar_getName



成员变量和属性的关系，从下面可以看出来，一个属性是对应一个成员变量的，属性是根据自己的属性特性定义来对这个成员变量进行一系列的封装，getter  setter方法，线程安全，内存管理操作。

 但是有成员变量不一定有属性，当且仅当有property 修饰的时候 才会有属性。



```objective-c

@interface Student : NSObject

{
    
    NSString *lastName;
}
/** */
@property (nonatomic,strong)NSString *username;

/** */
@property (nonatomic,strong)NSString *className;


@end




    // 访问一个类的成员变量
    
    unsigned int stu_count;
    // 打印结果
    // lastname _username  _className
    Ivar *varList = class_copyIvarList([Student class], &stu_count);
    for (int i = 0 ; i < stu_count; i ++) {
        NSLog(@"%s",ivar_getName(varList[i]));
    }
	
    // 打印结果 username  className
    [self getAllPropertyNames:[Student new]];
```

