//
//  CheckOutView.m
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/17.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import "CheckOutView.h"

@interface CheckOutView ()
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (nonatomic, copy) void (^checkout)(NSString *);
@property (nonatomic, copy) void (^cancel)();
@end

@implementation CheckOutView
+ (CheckOutView *)checkOutView:(void (^)(NSString *))checkout cancel:(void (^)())cancel
{
    CheckOutView *checkOutView = [[NSBundle mainBundle] loadNibNamed:@"CheckOutView" owner:self options:nil].lastObject;
    checkOutView.checkout = checkout;
    checkOutView.cancel = cancel;
    return checkOutView;
}
- (void)popKeyboard
{
    [_textview becomeFirstResponder];
}
- (void)cancelKeyboard
{
    [_textview resignFirstResponder];
}
- (IBAction)clickCheckoutAction:(id)sender {
    if (_checkout) {
        _checkout(_textview.text);
        [self cancelKeyboard];
    }
}
- (IBAction)clickClearTextAction:(id)sender {
    _textview.text = @"";
}
- (IBAction)clickCancelAction:(id)sender {
    if (_cancel) {
        _cancel();
        [self cancelKeyboard];
    }
}
@end
