//
//  EHMathCell.m
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/12.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import "EHMathCell.h"

@interface EHMathCell ()
@property (weak, nonatomic) IBOutlet UILabel *numLbl;
@property (weak, nonatomic) IBOutlet MTMathUILabel *mathLbl;
@end

@implementation EHMathCell
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
    _numLbl.text = mathSmaple.dataNum;
    _mathLbl.latex = mathSmaple.content;
    _mathLbl.labelMode = kMTMathUILabelModeDisplay;
    _mathLbl.font = [[MTFontManager fontManager] fontWithMathFontName:MathFontTypeLatinmodern size:18];
}
@end
