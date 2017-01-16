//
//  EHMathSample.m
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/12.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import "EHMathSample.h"
#define kMathOriSin @"$$" //@"frac1"

@interface EHMathSample()
@property (nonatomic, copy) NSString *mDataNum;
@property (nonatomic, copy) NSString *mDataNum2;
@property (nonatomic, copy) NSString *mContent;
@property (nonatomic, assign) CGSize mRect;
@end

@implementation EHMathSample
+ (EHMathSample *)sampleWithDict:(NSDictionary<NSString *, id> *)dict
{
    EHMathSample *mathSample = [[EHMathSample alloc] init];
    mathSample.mDataNum = dict[@"num"];
    mathSample.mDataNum2 = dict[@"num2"];
    mathSample.mContent = dict[@"content"];
    mathSample.mRect = [dict[@"size"] CGSizeValue];
    return mathSample;
}
- (NSString *)dataNum
{
    return _mDataNum;
}
- (NSString *)dataNum2
{
    return _mDataNum2;
}
- (NSString *)content
{
    return _mContent;
}
- (CGSize)rect
{
    return _mRect;
}
@end
