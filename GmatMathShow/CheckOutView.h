//
//  CheckOutView.h
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/17.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckOutView : UIView
+ (CheckOutView *)checkOutView:(void (^)(NSString *))checkout cancel:(void (^)())cancel;
- (void)cancelKeyboard;
- (void)popKeyboard;
@end
