//
//  EHMathManager.m
//  iosMath
//
//  Created by KMF-ZXX on 2016/12/5.
//
//

#import "EHMathManager.h"

#define kMathMaxWidth [UIScreen mainScreen].bounds.size.width - 20.0

#define kMathOriSin @"$$"
#define kLaTeXLineBreakKey @" \\\\ "
#define kOriLineBreakKey @"[br/]"
#define kSpaceKey @" "

#define kWord @"word"
#define kParagraph @"paragraph"
#define kProperty @"property"

#define kPropertySignMath @"math"
#define kPropertySignWords @"words"

#define kMathDefaultFontSize 15.0
#define kAmendArgument 50
#define kCharacterWidthRatio 0.95// 1.02
#define kMathWidthRatio 1.2// 1.1


@interface EHMathManager ()
@property (nonatomic, strong) MTMathUILabel *mathlbl;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *words;//!< 并非严格意义上的单词，而是按空格切割的字符段，数学公式单独为一段(不会按空格切割)
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) MTMathUILabelMode lblMode;
@property (nonatomic, assign) MathFontName fontName;
@property (nonatomic, strong) NSString *lastLatex;
@property (nonatomic, assign) CGFontRef cgfontRef;
@property (nonatomic, assign) CTFontRef ctfontRef;
@end


@implementation EHMathManager
#pragma mark static func
static BOOL CheckOriStr(NSString *oriStr, NSInteger index, NSInteger length, NSString *verifyStr)
{
    return index >= 0 && oriStr.length > index + length && [[oriStr substringWithRange:NSMakeRange(index, length)] isEqualToString:verifyStr];
}

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
- (void)dealloc
{
    CGFontRelease(_cgfontRef);
    CFRelease(_ctfontRef);
}

#pragma mark - public methords
- (NSString *)parseLatex:(NSString *)latex
{
    if (nil == latex || latex.length <= 0 || ![latex isKindOfClass:[NSString class]]) {
        return latex;
    }
    NSString *latex_add_newlinesymbol = [self addNewLineKeyTo:[latex stringByReplacingOccurrencesOfString:@"\r" withString:@""]];
    return [self parseLatex:[[latex_add_newlinesymbol stringByReplacingOccurrencesOfString:kOriLineBreakKey withString:kLaTeXLineBreakKey ]
                             stringByReplacingOccurrencesOfString:@"'" withString:@"{\\quotes}"]
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
    NSString *resultString = [self connectWords];
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
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *paragraph_strings = [NSMutableArray arrayWithCapacity:0];
    
    BOOL odd_even_check = [latex hasPrefix:kMathOriSin];
    NSArray *temp = [latex componentsSeparatedByString:kMathOriSin];
    NSMutableArray<NSString *> *temp_paragraph_strings = [NSMutableArray arrayWithCapacity:1];
    for (NSString *t in temp) {
        if (t.length > 0) {
            [temp_paragraph_strings addObject:t];
        }
    }
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
                                       kProperty: property}];
    }
    return paragraph_strings;
}
- (void)parseParagraphStringsToWords:(NSMutableArray<NSDictionary<NSString *, NSString *> *> *)paragraph_strings
                            fontSize:(CGFloat)fontSize
                           labelMode:(MTMathUILabelMode)lblMode
                            fontName:(MathFontName)fontname
{
    for (NSInteger i = 0; i < paragraph_strings.count; i++) {
        NSString *paragraph_string = paragraph_strings[i][kParagraph];
        if ([paragraph_strings[i][kProperty] isEqualToString:kPropertySignWords]) {
            BOOL is_has_surffix_spackkey = [paragraph_string hasSuffix:kSpaceKey];
            NSArray *words = [paragraph_string componentsSeparatedByString:kSpaceKey];
            for (NSInteger i = 0; i < words.count; i++) {
                if (i == words.count - 1 && [words[i] isEqualToString:@""]) {
                    continue;
                }
                NSDictionary *dict = @{kWord: i == words.count - 1 ? is_has_surffix_spackkey ? [NSString stringWithFormat:@"%@ ", words[i]] : words[i] : [NSString stringWithFormat:@"%@ ", words[i]],
                                       kProperty: kPropertySignWords};
                [_words addObject:dict];
            }
        }else {
            NSDictionary *dic = @{kWord: paragraph_string,
                                  kProperty: kPropertySignMath};
            [_words addObject:dic];
        }
    }
}
- (NSString *)connectWords
{
    NSMutableString *resultString = [NSMutableString string];
    for (NSInteger i = 0; i < _words.count; i++) {
        [self appendingWord:_words[i][kWord]
             toResultString:resultString
             stringProperty:[_words[i][kProperty] isEqualToString:kPropertySignWords]];
    }
    return [resultString stringByReplacingOccurrencesOfString:@"\\text{\\\\ }" withString:kLaTeXLineBreakKey];
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
- (NSString *)addNewLineKeyTo:(NSString *)oriStr
{
    NSMutableString *resultStr = oriStr.mutableCopy;
    CGFloat length = 0;
    
    NSMutableString *math_cache = [NSMutableString string];
    NSMutableArray<NSNumber *> *subs = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary<NSString *,NSNumber *> *word_chars_width = [NSMutableDictionary dictionaryWithCapacity:0];
    
    BOOL math_begin = false;
    BOOL math_end = false;
    
    for (NSInteger i = 0; i < oriStr.length; i++) {
        UniChar ch = [oriStr characterAtIndex:i];
        CGGlyph glyph = 0;
        CGSize glyphSize;
        if ((ch >= 0x4E00) && (ch <= 0x9FFF)) {
            glyphSize = CGSizeMake(_fontSize * 1.05, 0);
        }else if (ch == '[' && !math_begin) {
            if (CheckOriStr(oriStr, i, 5, kOriLineBreakKey)) {
                i+=4;
                length = 0;
                continue;
            }
        }else if (ch == '$' && !math_begin) {
            math_begin = CheckOriStr(oriStr, i, 2, kMathOriSin);
            if (math_begin) {
                i++;
                continue;
            }
        }else if (ch == '$' && math_begin && !math_end) {
            math_end = CheckOriStr(oriStr, i, 2, kMathOriSin);
            if (math_end) {
                math_begin = false;
                math_end = false;
                i++;
                
                CGFloat math_width = [self colMathStrSize:math_cache
                                                 fontSize:_fontSize
                                                labelMode:_lblMode
                                                 fontName:_fontName].width;
                math_width = math_width < 22 ? math_width * (kMathWidthRatio) : math_width * (kMathWidthRatio - 0.05);
                length += math_width;
//                printf("%s--%.2f--%.2f\n", math_cache.UTF8String, math_width, length);
                if (length >= _maxWidth) {
                    length = math_width;
                    [subs addObject:@(i - math_cache.length - 3 - 1)];
                }
                math_cache = [NSMutableString string];
                continue;
            }
        }else {
            CTFontGetGlyphsForCharacters(self.ctfontRef, &ch, &glyph, 1);
            CTFontGetAdvancesForGlyphs(self.ctfontRef, kCTFontHorizontalOrientation, &glyph, &glyphSize, 1);
        }
        if (math_begin) {
            [math_cache appendString:[NSString stringWithFormat:@"%c", ch]];
        }else {
            if (ch == '=' || ch == '-' || ch == '+' || ch == '<' || ch == '>' || ch == ':') {
                glyphSize = CGSizeMake(31.0, 0);
            }else if (ch == ',' || ch == ' ') {
                glyphSize = CGSizeMake(glyphSize.width * 1.2, glyphSize.height);
            }else
            word_chars_width[[NSString stringWithFormat:@"%zd", i]] = @(glyphSize.width * kCharacterWidthRatio);
            length += glyphSize.width * kCharacterWidthRatio;
//            printf("%--c--%.2f--%.2f\n", ch, glyphSize.width * kCharacterWidthRatio, length);
        }
        if (length >= _maxWidth) {
            BOOL flag = true;
            NSInteger j = i;
            length = 0;
            while (flag && j >= 0) {
                UniChar ch = [oriStr characterAtIndex:j];
                if (ch == ' ' || ((ch >= 0x4E00) && (ch <= 0x9FFF))) {
                    [subs addObject:@(j)];
                    flag = false;
                }else if (ch == ',' || ch == '.' || ch == '?' || ch == ';' || ch == ':') {
                    if (CheckOriStr(oriStr, j + 1, 1, kSpaceKey)) {
                        [subs addObject:@(j + 1)];
                    }else if (CheckOriStr(oriStr, i + 1, 5, kOriLineBreakKey)) {
                        // 需要插入换行的地方为'.'，且'.'之后已经有[br/]，则什么都不做
                    }else {
                        [subs addObject:@(j)];
                    }
                    flag = false;
                }else if (ch == '$') {
                    if (CheckOriStr(oriStr, j - 1, 2, kMathOriSin)) {
                        [subs addObject:@(j+1)];
                        flag = false;
                    }
                }else {
                    length += [word_chars_width[[NSString stringWithFormat:@"%zd", j]] doubleValue];
                }
                j--;
            }
        }
    }
    for (NSInteger i = subs.count - 1; i >= 0; i--) {
        NSInteger index = [subs[i] integerValue];
        UniChar ch = [oriStr characterAtIndex:index];
        if (CheckOriStr(oriStr, i, 5, kOriLineBreakKey)) {
            continue;
        }
        if (ch == ' ') {
            [resultStr replaceCharactersInRange:NSMakeRange(index, 1) withString:kOriLineBreakKey];
        }else {
//            if (index + 1 >= 0 && [[oriStr substringWithRange:NSMakeRange(index, 1)] isEqualToString:@" "]) {
//                [resultStr replaceCharactersInRange:NSMakeRange(index-1, 1) withString:kOriLineBreakKey];
//            }else {
                    if (index + 1 == oriStr.length) {
                        continue;
                    }else {
                        [resultStr insertString:kOriLineBreakKey atIndex:index+1];
                    }
//            }
        }
    }
    return resultStr;
}
- (NSString *)getFontName:(MathFontName)fontName
{
    switch (fontName) {
        case MathFontTypeLatinmodern:
            return @"latinmodern-math";
            break;
        case MathFontTypeXits:
            return @"xits-math";
            break;
        case MathFontTypeTexgyretermes:
            return @"texgyretermes-math";
            break;
    }
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
- (CTFontRef)ctfontRef
{
    if (_ctfontRef == NULL) {
        NSBundle* bundle = [MTFont fontBundle];
        NSString* fontPath = [bundle pathForResource:[self getFontName:_fontName] ofType:@"otf"];
        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename(fontPath.UTF8String);
        _cgfontRef =  CGFontCreateWithDataProvider(fontDataProvider);
        _ctfontRef = CTFontCreateWithGraphicsFont(_cgfontRef, _fontSize, NULL, NULL);
    }
    return _ctfontRef;
}

@end
