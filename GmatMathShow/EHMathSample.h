//
//  EHMathSample.h
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/12.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EHMathSample : NSObject
@property (nonatomic, copy, readonly) NSString *dataNum;
@property (nonatomic, copy, readonly) NSString *dataNum2;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, assign, readonly) CGSize rect;
+ (EHMathSample *)sampleWithDict:(NSDictionary<NSString *, id> *)dict;
@end
