//
//  EHMathManager.m
//  iosMath
//
//  Created by KMF-ZXX on 2016/12/5.
//
//

#import "EHMathManager.h"

#define kMathMaxWidth [UIScreen mainScreen].bounds.size.width - 20.0

#define kMathBeginSign @"<p>"
#define kMathEndSign @"</p>"
#define kMathOriSin @"$$"
#define kSpaceKey @"\\ "
#define kLineBreakKey @"\\\\"

/// property words keys
#define kWord @"word"
#define kLength @"length"
#define kLocation @"location"


#define kParagraph @"paragraph"
#define kProperty @"property"

#define kPropertySignMath @"math"
#define kPropertySignWords @"words"

#define kMathDefaultFontSize 15.0
#define kAmendArgument 50

#define kSingleQuotes @"&rsquo;"

@interface EHMathManager ()
@property (nonatomic, strong) MTMathUILabel *mathlbl;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *words;//!< 并非严格意义上的单词，而是按空格切割的字符段，数学公式单独为一段(不会按空格切割)
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) MTMathUILabelMode lblMode;
@property (nonatomic, assign) MathFontName fontName;
@property (nonatomic, strong) NSString *lastLatex;
@end


@implementation EHMathManager

#pragma mark - life
+ (EHMathManager *)manager
{
    return [[EHMathManager alloc] init];
}
- (instancetype)init
{
    if (self = [super init]) {
        _mathlbl = [[MTMathUILabel alloc] init];
        _words = [NSMutableArray arrayWithCapacity:0];
        _defaultFontSize = kMathDefaultFontSize;
        _defaultWidth = kMathMaxWidth;
        _lblMode = kMTMathUILabelModeText;
        _fontName = MathFontTypeLatinmodern;
    }
    return self;
}

#pragma mark - public methords
- (NSString *)parseLatex:(NSString *)latex
{
    /* 已修复问题汇总
     stringByReplacingOccurrencesOfString:@"＜" withString:@"<"
     stringByReplacingOccurrencesOfString:@"＞" withString:@">"
     stringByReplacingOccurrencesOfString:@"</p>" withString:@""
     stringByReplacingOccurrencesOfString:@"<p>" withString:@""
     stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"\'"   //本条未完全修复,多余 ; 未修复
     stringByReplacingOccurrencesOfString:@"[br\\]" withString:@"  \\\\"]
     stringByReplacingOccurrencesOfString:@"[br]" withString:@"  \\\\"]
     stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "]
     stringByReplacingOccurrencesOfString:@"\\mathbf" withString:@" "]
     stringByReplacingOccurrencesOfString:@"≠" withString:@"\\neq "]
     stringByReplacingOccurrencesOfString:@"≤" withString:@"\\leq "]
     stringByReplacingOccurrencesOfString:@"≥" withString:@"\\geq "]
     stringByReplacingOccurrencesOfString:@"│" withString:@"\\mid "]
     stringByReplacingOccurrencesOfString:@"π" withString:@"\\pi "]
     stringByReplacingOccurrencesOfString:@"○" withString:@"O"]
     stringByReplacingOccurrencesOfString:@"※" withString:@"\\ast "]
     stringByReplacingOccurrencesOfString:@"⊙" withString:@"\\bigodot "]
     stringByReplacingOccurrencesOfString:@"×" withString:@"\\times "]
     stringByReplacingOccurrencesOfString:@"║" withString:@"\\| "]
     stringByReplacingOccurrencesOfString:@"Θ" withString:@"\\Theta "]
     stringByReplacingOccurrencesOfString:@"△" withString:@"\\Delta "]
     stringByReplacingOccurrencesOfString:@"ζ" withString:@"\\zeta "]
     stringByReplacingOccurrencesOfString:@"η" withString:@"\\eta "]
     stringByReplacingOccurrencesOfString:@"ψ" withString:@"\\psi "]
     stringByReplacingOccurrencesOfString:@"ξ" withString:@"\\xi "]
     stringByReplacingOccurrencesOfString:@"ν" withString:@"\\upsilon "]
     stringByReplacingOccurrencesOfString:@"ε" withString:@"\\varepsilon "]
     stringByReplacingOccurrencesOfString:@"–" withString:@"-"]
     
     ，中文逗号无法解析
     */
    return [self parseLatex:[[[latex stringByReplacingOccurrencesOfString:@"[br/]" withString:@" \\\\ " ]
                              stringByReplacingOccurrencesOfString:@"'" withString:@"{\\quotes}"]
                             stringByReplacingOccurrencesOfString:@"\r" withString:@""]
                   fontSize:_defaultFontSize
                   maxWidth:_defaultWidth
                    lblMode:_defaultLblMode
                   fontName:_defaultFontName];
}
- (NSString *)parseLatex:(NSString *)latex
                fontSize:(CGFloat)fontSize
                maxWidth:(CGFloat)maxWidth
                 lblMode:(MTMathUILabelMode)lblMode
                fontName:(MathFontName)fontname
{
    _fontSize = fontSize > 0 ? fontSize : _defaultFontSize;
    _maxWidth = maxWidth > 0 ? maxWidth : _defaultWidth;
    _lblMode = lblMode;
    _lastLatex = latex;
    _fontName = fontname;
    [self parseParagraphStringsToWords:[self parseLatexToParagraphs:latex]
                              fontSize:_fontSize
                             labelMode:_lblMode
                              fontName:_fontName];
    NSString *resultString = [self addLineBreakKey];
    [self colMathStrSize:resultString
                fontSize:_fontSize
               labelMode:_lblMode
                fontName:_fontName];
    return resultString;
}

#pragma mark - private-tools methords
- (NSMutableArray<NSDictionary<NSString *, NSString *> *> *)parseLatexToParagraphs:(NSString *)latex
{
    if (_words.count > 0) {
        [_words removeAllObjects];;
    }else {
        _words = [NSMutableArray arrayWithCapacity:0];
    }
    /// 字符段数组，按照数学公式标记切割，公式单独成段，公式之前，公式与公式之间，公式之后所有字符单独成段
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *paragraph_strings = [NSMutableArray arrayWithCapacity:0];
    
    BOOL odd_even_check = [latex hasPrefix:kMathOriSin];
    NSArray *temp = [latex componentsSeparatedByString:kMathOriSin];
    NSMutableArray<NSString *> *temp_paragraph_strings = [NSMutableArray arrayWithCapacity:1];
    for (NSString *t in temp) {
        if (t.length > 0) {
            [temp_paragraph_strings addObject:t];
        }
    }
    NSInteger location = 0;
    for (NSInteger i = 0; i < temp_paragraph_strings.count; i++) {
        if ([temp_paragraph_strings[i] length] == 0) {
            continue;
        }
        NSString *property = nil;
        NSString *paragraph = [temp_paragraph_strings[i] stringByReplacingOccurrencesOfString:@"$" withString:@"\\$"];//将美元符号保留，例如 $5,000 表示5000美元
        //        NSString *property = odd_even_check ? i%2 == 0 ? kPropertySignMath : kPropertySignWords : i%2 == 0 ? kPropertySignWords : kPropertySignMath ;
        if (odd_even_check) {
            if (i%2 == 0) {
                property = kPropertySignMath;
            }else {
                property = kPropertySignWords;
            }
        }else {
            if (i%2 == 0) {
                property = kPropertySignWords;
            }else {
                property = kPropertySignMath;
            }
        }
        [paragraph_strings addObject:@{kParagraph: paragraph,
                                       kProperty: property,
                                       kLocation: @(location)}];
        location += [temp_paragraph_strings[i] length];
    }
    
    /*
    /// 标记必须成对出现，如出现不成对出现标记，则按数量少的进行匹配（有可能会出现显示混乱）
    /// 获取数学公式所有开始标记
    NSRegularExpression *regular_begin_sign = [[NSRegularExpression alloc] initWithPattern:kMathBeginSign options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *results_begin_sign = [regular_begin_sign matchesInString:latex options:0 range:NSMakeRange(0, latex.length)];
    /// 获取数学公式所有结束标记
    NSRegularExpression *regular_end_sign = [[NSRegularExpression alloc] initWithPattern:kMathEndSign options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *results_end_sign = [regular_end_sign matchesInString:latex options:0 range:NSMakeRange(0, latex.length)];
    /// 最大循环匹配次数
    NSInteger loop_cap = results_begin_sign.count < results_end_sign.count ? results_begin_sign.count : results_end_sign.count;
    for (NSInteger i = 0; i < loop_cap; i++) {
        [paragraph_strings addObject:@{kParagraph: [latex substringWithRange:NSMakeRange(i == 0 ? 0 : results_end_sign[i-1].range.location + results_end_sign[i-1].range.length,
                                                                                         i == 0 ? results_begin_sign[i].range.location : results_begin_sign[i].range.location - results_end_sign[i-1].range.location - results_end_sign[i-1].range.length)],
                                       kProperty: kPropertySignWords,
                                       kLocation: @(i == 0 ? 0 : results_end_sign[i-1].range.location + results_end_sign[i-1].range.length)}];
        [paragraph_strings addObject:@{kParagraph: [latex substringWithRange:NSMakeRange(i == 0 ? results_begin_sign[i].range.location + results_begin_sign[i].range.length : results_begin_sign[i].range.location + results_begin_sign[i].range.length,
                                                                                         i == 0 ? results_end_sign[i].range.location - results_begin_sign[i].range.location - results_begin_sign[i].range.length : results_end_sign[i].range.location - results_begin_sign[i].range.location - results_begin_sign[i].range.length)],
                                       kProperty: kPropertySignMath,
                                       kLocation: @(i == 0 ? results_begin_sign[i].range.location + results_begin_sign[i].range.length : results_begin_sign[i].range.location + results_begin_sign[i].range.length)}];
        if (i == loop_cap - 1) {
            [paragraph_strings addObject:@{kParagraph: [latex substringWithRange:NSMakeRange(results_end_sign[i].range.location + results_end_sign[i].range.length,
                                                                                             latex.length - results_end_sign[i].range.location - results_end_sign[i].range.length)],
                                           kProperty: kPropertySignWords,
                                           kLocation: @(results_end_sign[i].range.location + results_end_sign[i].range.length)}];
        }
    }
    */
    return paragraph_strings;
}
- (void)parseParagraphStringsToWords:(NSMutableArray<NSDictionary<NSString *, NSString *> *> *)paragraph_strings
                            fontSize:(CGFloat)fontSize
                           labelMode:(MTMathUILabelMode)lblMode
                            fontName:(MathFontName)fontname
{
    for (NSInteger i = 0; i < paragraph_strings.count; i++) {
        NSString *paragraph_string = paragraph_strings[i][kParagraph];
        NSInteger paragraph_location = [paragraph_strings[i][kLocation] integerValue];
        if ([paragraph_strings[i][kProperty] isEqualToString:kPropertySignWords]) {
            NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:@" " options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray<NSTextCheckingResult *> *results = [regular matchesInString:paragraph_string options:0 range:NSMakeRange(0, paragraph_string.length)];
            /// 将字符串按空格分解，分别计算每段的长度，并记住位置,同时替换空格符
            for (NSInteger i = 0; i < results.count; i++) {
                NSRange range = NSMakeRange(i == 0 ? i : results[i-1].range.location + 1,
                                            i == 0 ? results[i].range.location + 1 : results[i].range.location - results[i-1].range.location);
                NSString *word = [paragraph_string substringWithRange:range];
                NSDictionary *dict = @{kWord: word,//[word stringByReplacingOccurrencesOfString:@" " withString:kSpaceKey],
                                       kLength: @([self colMathStrSize:word
                                                              fontSize:fontSize
                                                             labelMode:lblMode
                                                              fontName:fontname].width),
                                       kLocation: @(range.location + range.length + paragraph_location),
                                       kProperty: kPropertySignWords};
                [_words addObject:dict];
            }
            if (results.lastObject.range.location + 1 < paragraph_string.length) {
                NSRange range = NSMakeRange(results.lastObject.range.location + 1,
                                            paragraph_string.length - results.lastObject.range.location - 1);
                NSString *word = [paragraph_string substringWithRange:range];
                NSDictionary *dict = @{kWord: word,//[word stringByReplacingOccurrencesOfString:@" " withString:kSpaceKey],
                                       kLength: @([self colMathStrSize:word
                                                              fontSize:fontSize
                                                             labelMode:lblMode
                                                              fontName:fontname].width),
                                       kLocation: @(range.location + range.length + paragraph_location),
                                       kProperty: kPropertySignWords};
                [_words addObject:dict];
            }
        }else {
            NSDictionary *dic = @{kWord: paragraph_string,
                                  kLength: @([self colMathStrSize:paragraph_string
                                                         fontSize:fontSize
                                                        labelMode:lblMode
                                                         fontName:fontname].width),
                                  kLocation: paragraph_strings[i][kLocation],
                                  kProperty: kPropertySignMath};
            [_words addObject:dic];
        }
    }
}
- (NSString *)addLineBreakKey
{
    CGFloat row_addup_length = 0;
    NSMutableString *resultString = [NSMutableString string];
    for (NSInteger i = 0; i < _words.count; i++) {
        row_addup_length += [_words[i][kLength] floatValue];
        if (row_addup_length > _maxWidth - kAmendArgument || [_words[i][kWord] containsString:kLineBreakKey]) {
            row_addup_length = [_words[i][kLength] floatValue];
            if (![_words[i][kWord] containsString:kLineBreakKey]) {
                [resultString appendString:kLineBreakKey];
            }
        }
        [self appendingWord:_words[i][kWord]
             toResultString:resultString
             stringProperty:[_words[i][kProperty] isEqualToString:kPropertySignWords]];
    }
    return [resultString stringByReplacingOccurrencesOfString:@"\\text{\\\\ }" withString:@" \\\\ "];
}
- (void)appendingWord:(NSString *)word
       toResultString:(NSMutableString *)resultString
       stringProperty:(BOOL)isWord
{
    if (word.length <=0 || nil == word || nil == resultString) {
        return;
    }
    if (isWord) {
        [resultString appendString:[NSString stringWithFormat:[self getDisplayStyle:0], word]];
    }else {
        [resultString appendString:[NSString stringWithFormat:[self getDisplayStyle:6], word]];
    }
}
- (NSString *)getDisplayStyle:(NSInteger)index
{
    switch (index) {
        case 0:
            return @" \\text{%@}";
            break;
        case 1:
            return @" \\mathbf{%@}";
            break;
        case 2:
            return @" \\mathrm{%@}";
            break;
        case 3:
            return @" \\mathcal{%@}";
            break;
        case 4:
            return @" \\mathfrak{%@}";
            break;
        case 5:
            return @" \\mathsf{%@}";
            break;
        case 6:
            return @" \\bm{%@}";
            break;
        case 7:
            return @" \\mathtt{%@}";
            break;
        default:
            return @"%@";
            break;
            break;
    }
}
- (CGSize)colMathStrSize:(NSString *)mathStr
                fontSize:(CGFloat)fontSize
               labelMode:(MTMathUILabelMode)lblMode
                fontName:(MathFontName)fontname
{
    _mathlbl.fontSize = fontSize;
    _mathlbl.font = [[MTFontManager fontManager] fontWithMathFontName:fontname size:fontSize];
    _mathlbl.latex = mathStr;
    _mathlbl.labelMode = lblMode;
    _mathlbl.frame = CGRectZero;
    return _mathlbl.rect;
}

#pragma mark - property-setter-getter
- (CGSize)rect
{
    return _mathlbl.rect;
}
- (void)setDefaultWidth:(CGFloat)defaultWidth
{
    _defaultWidth = defaultWidth;
    _maxWidth = defaultWidth;
}
- (void)setDefaultFontSize:(CGFloat)defaultFontSize
{
    _defaultFontSize = defaultFontSize;
    _fontSize = defaultFontSize;
}
- (void)setDefaultLblMode:(MTMathUILabelMode)defaultLblMode
{
    _defaultLblMode = defaultLblMode;
    _lblMode = defaultLblMode;
}

@end
