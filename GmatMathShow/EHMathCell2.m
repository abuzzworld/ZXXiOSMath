//
//  EHMathCell2.m
//  GmatMathShow
//
//  Created by zxx.abuzzworld on 2017/1/13.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import "EHMathCell2.h"

@interface EHMathCell2 ()
@property (weak, nonatomic) IBOutlet UILabel *num1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *num2Lbl;
@property (weak, nonatomic) IBOutlet MTMathUILabel *mathLbl;

@end

@implementation EHMathCell2
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)addSubview:(UIView *)view
{
    if (![view isKindOfClass:[NSClassFromString(@"_UITableViewCellSeparatorView") class]] && view) {
        [super addSubview:view];
    }
}
- (void)setMathSmaple:(EHMathSample *)mathSmaple
{
    _mathSmaple = mathSmaple;
    _num1Lbl.text = mathSmaple.dataNum;
    _num2Lbl.text = mathSmaple.dataNum2;
    _mathLbl.latex = mathSmaple.content;
    _mathLbl.labelMode = kMTMathUILabelModeDisplay;
    _mathLbl.font = [[MTFontManager fontManager] fontWithMathFontName:MathFontTypeLatinmodern size:18];
}
@end
