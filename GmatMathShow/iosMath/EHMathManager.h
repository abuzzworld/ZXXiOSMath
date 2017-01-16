//
//  EHMathManager.h
//  iosMath
//
//  Created by KMF-ZXX on 2016/12/5.
//
//

#import <Foundation/Foundation.h>
#import "IosMath.h"
#define kTestString @"aldkfj lkdfl zoud ldfjla kdkk k llkj lkdlfa lkkj qiorei apopi <p>x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}</p> daakfhj sfkjlsd lskdfls <p>x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}</p> llkj lkdlfa lkkj qiorei apopi daakfhj sfkjlsd lskdfls llkj lkdlfa lkkj qiorei apopi daakfhj sfkjlsd lskdfls llkj lkdlfa lkkj qiorei apopi daakfhj sfkjlsd lskdfls l sfksd: <p>x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}</p>dfdslf lakdl adakldalf dalfald adaf."

@interface EHMathManager : NSObject
@property (nonatomic, assign, readonly) CGSize rect;                //!< 展示字符串MTMathUILabel将要需要的宽高
@property (nonatomic, assign) CGFloat defaultFontSize;              //!< 此属性必须与要显示的MTMathUILabel的fontSize值相同
@property (nonatomic, assign) CGFloat defaultWidth;                 //!< 此属性必须与要显示的MTMathUILabel的width相同
@property (nonatomic, assign) MTMathUILabelMode defaultLblMode;     //!< 此属性必须与要显示的MTMathUILabel的lblMode值相同
@property (nonatomic, assign) MathFontName defaultFontName;         //!< 此属性必须与要显示的MTMathUILabel的font值相同

+ (EHMathManager *)manager;
/// 返回处理完毕的字符串，缺醒三个默认参数可以通过属性设置，如不设置则采用默认值
- (NSString *)parseLatex:(NSString *)latex;
/**
 *  返回处理完毕的字符串，后三个参数如不填，则使用上一次调用此方法的参数，如无上一次，则使用默认值
 *
 *  @param  fontSize    默认为15号(此属性必须与要显示的mathLbl的fontSize值相同)
 *  @param  maxWidth    展示字符串的view的宽度(此属性必须与要显示的mathLbl的width相同)
 *  @param  lblMode     显示模式(此属性必须与要显示的mathLbl的lblMode值相同)
 *  @param  fontname    此属性必须与要显示的MTMathUILabel的font值相同
 *  @return 处理好的字符串
 */
- (NSString *)parseLatex:(NSString *)latex
                fontSize:(CGFloat)fontSize
                maxWidth:(CGFloat)maxWidth
                 lblMode:(MTMathUILabelMode)lblMode
                fontName:(MathFontName)fontname;
@end
