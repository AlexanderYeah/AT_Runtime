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
    
    NSNumber *num1 = @5;
    NSNumber *num2 = @2;
    NSNumber *num3 = @3;
//    (lldb) p num1
//    (__NSCFNumber *) $0 = 0x9d864a09dabb7827 (int)10
//    (lldb) p num2
//    (__NSCFNumber *) $1 = 0x9d864a09dabb79c7 (int)20
//    (lldb) p num3
//    (__NSCFNumber *) $2 = 0x9d864a09dabb7967 (int)30
//    (lldb)
    NSLog(@"\num1=%p\num2=%p\num3=%p", num1, num2, num3);
    
    [num3 class];
    
    
    
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//
//    for (int i = 0; i < 100; i++) {
//        dispatch_async(queue, ^{
//            self.username = [NSString stringWithFormat:@"abcdefghijk"];
//        });
//    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            
            // objc_release 发生崩溃
            @synchronized (self) {
                self.username = [NSString stringWithFormat:@"abcdefghijk"];
            }
            
        });
    }
    
    
}






@end
