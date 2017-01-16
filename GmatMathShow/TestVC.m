//
//  TestVC.m
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/13.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import "TestVC.h"
#import "EHMathSample.h"
#import "EHMathCell.h"

#define kMathCellIdentifier @"kMathCellIdentifier"
#define kMathFontSize 18

@interface TestVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<EHMathSample *> *dataSource;
@property (nonatomic, strong) EHMathManager *mathManager;
@property (nonatomic, strong) NSArray<NSString *> *srcOriTxt;
@property (nonatomic, strong) NSMutableArray<NSString *> *srcFinalTxt;
@property (nonatomic, strong) UILabel *oriStrLbl;
@end

@implementation TestVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
    self.navigationItem.title = @"GMAT数学公式示例";
    _mathManager = [EHMathManager manager];
    _mathManager.defaultFontSize = kMathFontSize;
    _mathManager.defaultWidth = [UIScreen mainScreen].bounds.size.width - 70;
    _mathManager.defaultLblMode = kMTMathUILabelModeDisplay;
    _mathManager.defaultFontName = MathFontTypeLatinmodern;
    _dataSource = @[].mutableCopy;
    [self.view addSubview:self.tableView];
    NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"gmat选项内容数学公式的副本" ofType:@"txt"];
    
    NSString *txt = [NSString stringWithContentsOfFile:srcPath encoding:NSUTF8StringEncoding error:nil];
    _srcOriTxt = [txt componentsSeparatedByString:@"\n"];
    _srcFinalTxt = [NSMutableArray arrayWithCapacity:1];
    NSString *space = @"\t";
    for (NSString *t in _srcOriTxt) {
        if (t.length == 0 && t.length == 1) {
            continue;
        }
        [_srcFinalTxt addObject:t];
        NSString *numStr = nil;
        NSString *contentStr = nil;
        NSRange firstSpaceRange = [t rangeOfString:space];
        if (firstSpaceRange.location == NSNotFound) {
            numStr = t;
            contentStr = @"                    ";
        }else {
            numStr = [t substringToIndex:firstSpaceRange.location];
            contentStr = [t substringWithRange:NSMakeRange(firstSpaceRange.location + firstSpaceRange.length, t.length - firstSpaceRange.location - firstSpaceRange.length)];
        }
        EHMathSample *mathSample = [EHMathSample sampleWithDict:@{@"num": numStr,
                                                                  @"content": [_mathManager parseLatex:contentStr],
                                                                  @"size": [NSValue valueWithCGSize:_mathManager.rect]}];
        [_dataSource addObject:mathSample];
    }
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    self.oriStrLbl.text = _srcFinalTxt[indexPath.row];
    [self.view bringSubviewToFront:_oriStrLbl];
    [UIView animateWithDuration:0.2 animations:^{
        _oriStrLbl.alpha = 1.0;
    }];
}
- (void)tapAction
{
    [UIView animateWithDuration:0.2 animations:^{
        _oriStrLbl.alpha = 0;
    }];
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 49);
        [_tableView registerNib:[UINib nibWithNibName:@"EHMathCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kMathCellIdentifier];
    }
    return _tableView;
}
- (UILabel *)oriStrLbl
{
    if (!_oriStrLbl) {
        _oriStrLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 49 - 64)];
        _oriStrLbl.textColor = [UIColor blackColor];
        _oriStrLbl.font = [UIFont systemFontOfSize:20];
        _oriStrLbl.textAlignment = NSTextAlignmentCenter;
        _oriStrLbl.numberOfLines = 0;
        _oriStrLbl.alpha = 0;
        _oriStrLbl.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_oriStrLbl addGestureRecognizer:tap];
        _oriStrLbl.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_oriStrLbl];
    }
    return _oriStrLbl;
}

@end
