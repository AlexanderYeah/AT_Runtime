//
//  ViewController.m
//  RuntimeDemo
//
//  Created by coder on 2019/7/18.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Student.h"
@interface ViewController ()

{
    NSString *age;
    
}

/** */
@property (nonatomic,strong)NSString *username;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // 获取一个类的实例的方法
    Method method = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    
    // 通过该实例方法IMP 函数指针
    IMP method_imp = method_getImplementation(method);
    
    NSLog(@"%p",method_imp);

    
    // 获取SEL 的方式
    SEL sel1 = NSSelectorFromString(@"dealloc");
    SEL sel2 = @selector(viewDidLoad);
    
    // 获取IMP的两种方式
    // 实例方法 - (IMP)methodForSelector:(SEL)aSelector;
    NSLog(@"%p",[self methodForSelector:sel1]);
    // 类方法   + (IMP)instanceMethodForSelector:(SEL)aSelector;
    NSLog(@"%p",[[self class] instanceMethodForSelector:sel2]);
    
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
    
    
    
}




// 运行时创建一个类 并且给类添加属性
- (void)createClassName:(NSString *)clsName{
    
    // 继承自NSObject 类名为Dog

    Class Cls = objc_allocateClassPair([NSObject class], clsName.UTF8String, 0);
    BOOL isSuccess = class_addIvar(Cls, "_name", sizeof(int), sizeof(int), @encode(int));
    
    if (isSuccess){
        NSLog(@"添加成员变量成功");
    }
    
    // 完成Dog 类的创建 objc_registerClassPair
    objc_registerClassPair(Cls);
    
}





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


@end
