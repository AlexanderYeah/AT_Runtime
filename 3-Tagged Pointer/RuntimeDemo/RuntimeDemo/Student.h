//
//  Student.h
//  RuntimeDemo
//
//  Created by coder on 2019/7/18.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject
{
    
    NSString *lastName;
}
/** */
@property (nonatomic,strong)NSString *username;

/** */
@property (nonatomic,strong)NSString *className;


@end

NS_ASSUME_NONNULL_END
