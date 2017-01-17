//
//  CheckOutVC.m
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/17.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import "CheckOutVC.h"
#import "EHMathSample.h"
#import "EHMathCell.h"
#import "CheckOutView.h"

#define kMathCellIdentifier @"kMathCellIdentifier"
#define kMathFontSize 18

@interface CheckOutVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<EHMathSample *> *dataSource;
@property (nonatomic, strong) EHMathManager *mathManager;
@property (nonatomic, strong) NSArray<NSString *> *srcOriTxt;
@property (nonatomic, strong) NSMutableArray<NSString *> *srcFinalTxt;
@property (nonatomic, strong) UILabel *oriStrLbl;
@property (nonatomic, strong) CheckOutView *checkOutView;
@end

@implementation CheckOutVC

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"input" style:UIBarButtonItemStylePlain target:self action:sel_registerName("goInputNum")];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"clearMaths" style:UIBarButtonItemStylePlain target:self action:sel_registerName("clearMaths")];
}
- (void)clearMaths
{
    [_dataSource removeAllObjects];
    [_tableView reloadData];
}
- (void)goInputNum
{
    self.checkOutView.hidden = FALSE;
    [self.view bringSubviewToFront:_checkOutView];
    [_checkOutView popKeyboard];
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
- (NSInteger)binSearch:(NSInteger)input_num_int
{
    for (NSInteger i = 0; i < _dataSource.count; i++) {
        if (input_num_int == [_dataSource[i].dataNum integerValue]) {
            return i;
        }
    }
    return -1;
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
- (CheckOutView *)checkOutView
{
    if (!_checkOutView) {
        
        __weak typeof(self)bself = self;
        _checkOutView = [CheckOutView checkOutView:^(NSString *checkout) {
            EHMathSample *mathSample = [EHMathSample sampleWithDict:@{@"num": @"9527",
                                                                      @"content": [bself.mathManager parseLatex:checkout],
                                                                      @"size": [NSValue valueWithCGSize:bself.mathManager.rect]}];
            [bself.dataSource addObject:mathSample];
            [bself.tableView reloadData];
            bself.checkOutView.hidden = TRUE;
        } cancel:^{
            bself.checkOutView.hidden = TRUE;
        }];
        [self.view addSubview:_checkOutView];
        _checkOutView.hidden = TRUE;
        _checkOutView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 49 - 64);
    }
    return _checkOutView;
}
@end
