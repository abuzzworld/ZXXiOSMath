//
//  EHGoToView.h
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/16.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHGoToView : UIView

+ (EHGoToView *)gotoView:(void(^)(NSString *inputNum))inputNum cancel:(void(^)())cancel;
- (void)cancelKeyboard;
- (void)popKeyboard;
@end
