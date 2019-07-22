#### 一  NSObject

NSObject是OC 中的基类，除了NSProxy其他都继承自NSObject

```objective-c

@interface NSObject <NSObject> {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
    Class isa  OBJC_ISA_AVAILABILITY;
#pragma clang diagnostic pop
}
```



#### 二 对象结构体 objc_object 

在运行时，类的对象被定义为objc_object 类型，就是对象结构体

在OC 中每一个对象都是一个结构体，结构体都包含了一个isa 成员变量。

根据isa的定义可以知道，类型为isa_t 类型的

```
struct objc_object {
private:
    isa_t isa;
}

```



isa_t 的定义是什么？

是一个union的结构对象，类似于C++结构体，其内部可以定义为成员变量和函数，是一个联合类型。



#### 三 类结构体 objc_class

类也是一个对象，类的结构体objc_class 是继承自objc_object的，具备对象的所有特征。

从源码可以看出

bits结构体的data 函数，获取到class_rw_t 指针

1 supercalss 当前类的父类

```objective-c
struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags

    class_rw_t *data() { 
        return bits.data();
    }
    void setData(class_rw_t *newData) {
        bits.setData(newData);
    }
 	
}

// class_rw_t 定义
class_rw_t* data() {
	return (class_rw_t *)(bits & FAST_DATA_MASK);
}

 
```



2 cache 是处理已经调用过方法的缓存

在运行时方法调用的流程，当我们调用一个方法的时候，先不去类的方法列表去寻找，而是先去cache 中去寻找。

如果方法已经存在，直接return掉。



```c
struct cache_t {
    // 数组 存放方法的SEL 和 IMP
    struct bucket_t *_buckets;
    // 用作掩码
    mask_t _mask;
	// 当前已缓存的方法数。即数组中已使用了多少位置。
    mask_t _occupied;
}

typedef uintptr_t cache_key_t;

struct bucket_t {
private:
    cache_key_t _key;
    IMP _imp;

public:
    inline cache_key_t key() const { return _key; }
    inline IMP imp() const { return (IMP)_imp; }
    inline void setKey(cache_key_t newKey) { _key = newKey; }
    inline void setImp(IMP newImp) { _imp = newImp; }

    void set(cache_key_t newKey, IMP newImp);
};
 

```



3 class_data_bits_t

只有一个成员bits ，对类的操作几乎就是围绕它展开。

作用：64的bits，来存储与类有关的信息。

怎么存储呢？

其中包含了各种异或来说明class 的属性。把这些信息复合在一起，仅用一个UINT指针`bits`来表示。当需要取出这些信息时，用需要的对应以`FAST_`前缀开头和结尾的标志对掩码`bits`做按位与操作。



位 在内存中的三种排列方式

64 位 

|       0       |          1          |           2           |      3-46      |
| :-----------: | :-----------------: | :-------------------: | :------------: |
| FAST_IS_SWIFT | FAST_HAS_DEFAULT_RR | FAST_REQUIRES_RAW_ISA | FAST_DATA_MASK |





```c
struct class_data_bits_t {

    // Values are the FAST_ flags above.
    uintptr_t bits;
 
    public:
    class_rw_t* data() {
        // FAST_DATA_MASK 代表着一块存储结构 
        return (class_rw_t *)(bits & FAST_DATA_MASK);
    }
    void setData(class_rw_t *newData)
    {
        assert(!data()  ||  (newData->flags & (RW_REALIZING | RW_FUTURE)));
        // Set during realization or construction only. No locking needed.
        // Use a store-release fence because there may be concurrent
        // readers of data and data's contents.
        uintptr_t newBits = (bits & ~FAST_DATA_MASK) | (uintptr_t)newData;
        atomic_thread_fence(memory_order_release);
        bits = newBits;
    }

}
```





#### 四  class_ro_t  和 class_rw_t



在编译之后，class_data_bits_t 的指针指向的是一个class_ro_t的地址，这个结构体是不可变的只读。

在运行时，才会通过realizeClass 函数将bits指向class_rw_t。



在程序开始运行只有初始化Class，在这个过程中，回吧编译器存在class_data_bits_t中的class_ro_t 取出来，然后创建class_rw_t,并且把ro 赋值给rw，最后把rw 设置给bits，替代之前bits 中存储的ro。





```c
struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
    uint32_t reserved;
	const uint8_t * ivarLayout;
	const char * name;
    method_list_t * baseMethodList;
    protocol_list_t * baseProtocols;
    
    const ivar_list_t * ivars;
    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;
}


struct class_rw_t {
    uint32_t flags;
    uint32_t version; 
    // 类不可修改的原始核心
    const class_ro_t *ro;
    // 下面三个array，method,property, protocol，可以被runtime 扩展，如Category
    method_array_t methods;
    property_array_t properties;
    protocol_array_t protocols;
    
    // 和继承相关的东西
    Class firstSubclass;
    Class nextSiblingClass;
    char *demangledName;
};
```

