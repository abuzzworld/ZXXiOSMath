//
//  ViewController.m
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/12.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import "ViewController.h"
#import "HTMLParser.h"
#import "EHMathSample.h"
#import "EHMathCell.h"

#define kMathShowLink @"http://code1.kmf.com/dist/libs/mathjax/2.0/MathJax_question.html"
#define kPrintErrorInfo NSLog(@"Error: %@",error); error = nil;
#define kMathCellIdentifier @"kMathCellIdentifier"
#define kMathFontSize 18

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<EHMathSample *> *dataSource;
@property (nonatomic, strong) EHMathManager *mathManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
    _mathManager = [EHMathManager manager];
    _mathManager.defaultFontSize = kMathFontSize;
    _mathManager.defaultWidth = [UIScreen mainScreen].bounds.size.width - 70;
    _mathManager.defaultLblMode = kMTMathUILabelModeDisplay;
    _mathManager.defaultFontName = MathFontTypeLatinmodern;
    _dataSource = @[].mutableCopy;
    [self gumboParser:[self getHtmlString]];
    [self.view addSubview:self.tableView];
}
- (NSString *)getHtmlString
{
    NSError *error = nil;
    NSString *htmlStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:kMathShowLink]
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
    if (error) {
        kPrintErrorInfo
        NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"math" ofType:@"html"];
        NSString *htmlStr = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            kPrintErrorInfo
            return nil;
        }else {
            return htmlStr;
        }
    }else {
        return htmlStr;
    }
}
- (void)gumboParser:(NSString *)html
{
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if (error) {
        kPrintErrorInfo
        return;
    }
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode findChildTags:@"tr"];
    NSInteger i = 0;
    for (HTMLNode *inputNode in inputNodes) {
        printf("%zd ====================================================================================================== \n\n", i++);
        NSArray *childNodes = [inputNode findChildTags:@"td"];
        EHMathSample *mathSample = [EHMathSample sampleWithDict:@{@"num": [childNodes[0] allContents],
                                                                  @"content": [_mathManager parseLatex:[childNodes[1] allContents]],
                                                                  @"size": [NSValue valueWithCGSize:_mathManager.rect]}];
        printf("%s\n%s", mathSample.dataNum.UTF8String, mathSample.content.UTF8String);
            [_dataSource addObject:mathSample];
        printf("\n");
    }
    NSLog(@"");
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EHMathCell *cell = [tableView dequeueReusableCellWithIdentifier:kMathCellIdentifier];
    cell.mathSmaple = _dataSource[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EHMathSample *mathSample = _dataSource[indexPath.row];
    return mathSample.rect.height + 10;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
        [_tableView registerNib:[UINib nibWithNibName:@"EHMathCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kMathCellIdentifier];
    }
    return _tableView;
}
@end
