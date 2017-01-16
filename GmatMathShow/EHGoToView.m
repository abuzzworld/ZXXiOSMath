//
//  EHGoToView.m
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/16.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import "EHGoToView.h"

@interface EHGoToView ()
@property (weak, nonatomic) IBOutlet UITextField *inputTF;
@property (nonatomic, copy) void (^inputNum)(NSString *);
@property (nonatomic, copy) void (^cancel)();
@end

@implementation EHGoToView

+ (EHGoToView *)gotoView:(void (^)(NSString *))inputNum cancel:(void (^)())cancel
{
    EHGoToView *gotoV = [[NSBundle mainBundle] loadNibNamed:@"EHGoToView" owner:self options:nil].lastObject;
    gotoV.inputNum = inputNum;
    gotoV.cancel = cancel;
    return gotoV;
}
- (void)cancelKeyboard
{
    [_inputTF resignFirstResponder];
}
- (IBAction)gotoInputTopic:(id)sender {
    if (_inputNum) {
        _inputNum(_inputTF.text);
        [self cancelKeyboard];
    }
}
- (IBAction)cancel:(id)sender {
    if (_cancel) {
        _cancel();
        [self cancelKeyboard];
    }
}
@end
