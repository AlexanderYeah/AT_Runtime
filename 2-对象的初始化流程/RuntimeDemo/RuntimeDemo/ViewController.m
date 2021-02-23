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
    

	
	[self performSelector:@selector(run) withObject:@"alex" withObject:@"25"];
	
	

// 动态创建一个类
	Class Dog = objc_allocateClassPair([NSObject class], "Dog", 0);
	// 判断是否添加成功
	BOOL isSuccess = class_addIvar(Dog, "name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
	// 注册
	objc_registerClassPair(Dog);
	
	if (isSuccess){
		id obj = [[Dog alloc]init];
		[obj setValue:@"jerry" forKey:@"name"];
	
	}


}













// 此时动态添加一个方法 传递一个参数进去
- (void)test:(NSString *)name age:(NSString *)age
{
	NSLog(@"test this %@  %@ ",name,age);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
	if (sel == NSSelectorFromString(@"run")) {
	
		Method testM = class_getInstanceMethod([self class], NSSelectorFromString(@"test:age:"));
		class_addMethod([self class], sel, method_getImplementation(testM), method_getTypeEncoding(testM));
		
	}
	return [super resolveInstanceMethod:sel];
}



@end
