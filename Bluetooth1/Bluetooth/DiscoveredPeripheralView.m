//
//  DiscoveredPeripheralView.m
//  Bluetooth
//
//  Created by 苏敏 on 2019/8/27.
//  Copyright © 2019 苏敏. All rights reserved.
//

#import "DiscoveredPeripheralView.h"
#import "DiscoveredPeripheralCell.h"

@implementation DiscoveredPeripheralView

#pragma mark - gesture
/**
 *  点击弹出框以外的部分, 则收起当前弹出框
 *
 *  @param gestureRecognizer UITapGestureRecognizer
 */
- (void)triggerTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    [self setPeripherals:nil];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self hide];
    }
}

#pragma mark - public
/**
 *  显示可连接设备View
 */
- (void)show {
    _peripherals = nil;
    [_tableView reloadData];//出现之前情空数据
    UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
    [appWindow addSubview:self];
}


/**
 *  隐藏可连接设备View
 */
- (void)hide {
    if ([self.delegate respondsToSelector:@selector(discoveredPeripheralViewDidHide)]) {
        [self.delegate discoveredPeripheralViewDidHide];
    }
    [self removeFromSuperview];
    [_peripherals removeAllObjects];
}

/**
 *  设置数据源
 *
 *  @param peripherals 传进来的数组
 */
- (void)setPeripherals:(NSMutableArray *)peripherals {
    _peripherals = peripherals;
    
    [_tableView reloadData];
}

- (void)insertPeripheral:(CBPeripheral *)perihperal {
    _peripheral = perihperal;
    NSArray *peripherals = [_peripherals valueForKey:@"peripheral"];
    //NSLog(NSLocalizedString(@"数组:%@", nil),peripheralDataArray);
    if(![peripherals containsObject:perihperal]) {
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:perihperal forKey:@"peripheral"];
        
        [_peripherals addObject:item];
        
        //[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    NSLog(@"--------------------------------%@=---------------%@-------@",_peripherals,_peripheral);
}

#pragma mark - super
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        CGRect foo = CGRectZero;
        
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.65;
        [self addSubview:_bgView];
        foo.origin.x = self.frame.size.width/5;
        foo.origin.y = self.frame.size.height/2-(self.frame.size.width - foo.origin.x * 2)/2;
        foo.size.width = self.frame.size.width - foo.origin.x * 2;
        foo.size.height = foo.size.width;
        _contentView = [[UIView alloc] initWithFrame:foo];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 10;
        [self addSubview:_contentView];
        
        foo.origin.x = 0;
        foo.origin.y = 15;
        foo.size.width = foo.size.width;
        foo.size.height = 25;
        _titelLabelBtn = [[UIButton alloc] initWithFrame:foo];
        _titelLabelBtn.backgroundColor = [UIColor clearColor];
        _titelLabelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_titelLabelBtn setTitle:NSLocalizedString(NSLocalizedString(@"找到以下设备", nil), nil) forState:UIControlStateNormal];
        [_titelLabelBtn setTitleColor:kUIColorFromRGB(0x000000) forState:UIControlStateNormal];
        [_titelLabelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_titelLabelBtn];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 15+_titelLabelBtn.frame.size.height, _contentView.frame.size.width, _contentView.frame.size.height-15-_titelLabelBtn.frame.size.height-_contentView.frame.size.height/5)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.layer.cornerRadius = 10;
        [_tableView registerClass:[DiscoveredPeripheralCell class] forCellReuseIdentifier:[DiscoveredPeripheralCell forCellWithReuseIdentifier]];
        [_contentView addSubview:_tableView];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        // 如果要让默认 cell 选中同时触发选中事件,需要手动调用 didSelectRowAtIndexPath
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:path];
        }
        // 设置默认选中的 cell 蹦沙卡拉卡蹦沙卡拉卡喔～
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        _linkBtn = [[UIButton alloc] init];
        [_linkBtn setTitleColor:kUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        _linkBtn.backgroundColor = RGBA(62, 154, 152, 1);
        [_linkBtn setTitle:NSLocalizedString(NSLocalizedString(@"连接", nil), nil) forState:UIControlStateNormal];
        [_linkBtn addTarget:self action:@selector(linkClicked:) forControlEvents:UIControlEventTouchUpInside];
        _linkBtn.frame = CGRectMake(_contentView.frame.size.width/2, _contentView.frame.size.height-_contentView.frame.size.height/5, _contentView.frame.size.width/2, _contentView.frame.size.height/5);
        [_contentView addSubview:_linkBtn];
        
        _cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, _contentView.frame.size.height-_contentView.frame.size.height/5, _contentView.frame.size.width/2-0.2, _contentView.frame.size.height/5)];
        [_cancleBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:kUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        _cancleBtn.backgroundColor = RGBA(62, 154, 152, 1);
        [_cancleBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_cancleBtn];
        
        //左下角切圆角
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_cancleBtn.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _cancleBtn.bounds;
        maskLayer.path = maskPath.CGPath;
        _cancleBtn.layer.mask = maskLayer;
        //右下角切圆角
        UIBezierPath *maskPaths = [UIBezierPath bezierPathWithRoundedRect:_linkBtn.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayers = [[CAShapeLayer alloc] init];
        maskLayers.frame = _linkBtn.bounds;
        maskLayers.path = maskPaths.CGPath;
        _linkBtn.layer.mask = maskLayers;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerTapGesture:)];
        [_bgView addGestureRecognizer:tapGesture];
    }
    return self;
}

/**
 *  连接按钮 点击连接
 */
- (void)linkClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(discoveredPeripheralViewDidSelectRowAtIndex:)]) {
        [self.delegate discoveredPeripheralViewDidSelectRowAtIndex:(int)_lastSelectIndexPath.row];
    }
}

/**
 *  返回TableView长度
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#pragma mark ---- 这里可以根据传进来的动态增加视图的高度
    return [_peripherals count];
}

/**
 *  创建TableView
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DiscoveredPeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:[DiscoveredPeripheralCell forCellWithReuseIdentifier] forIndexPath:indexPath];
    if([_lastSelectIndexPath isEqual:indexPath]){
        //设置选中图片
        cell.imageView.image = [UIImage imageNamed:@"选中"];
        
    }else {
        //设置未选中图片
        cell.imageView.image = [UIImage imageNamed:@"未选"];
        
    }
    
    
    CBPeripheral *peri = [_peripherals objectAtIndex:indexPath.row];
    //NSArray *peripherals = [_peripherals valueForKey:@"peripheral"];
    cell.textLabel.text = peri.name;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    //cell.detailTextLabel.text = peri.identifier.UUIDString;
    // NSLog(@"shuzu:%@",peripherals);
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

/**
 *  点击这一行做事情
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * lastSelectCell = [tableView cellForRowAtIndexPath: _lastSelectIndexPath];
    if (lastSelectCell != nil) {
        lastSelectCell.imageView.image = [UIImage imageNamed:@"未选"];
        
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"选中"];
    _lastSelectIndexPath = indexPath;
    
    
    
//        if ([self.delegate respondsToSelector:@selector(discoveredPeripheralViewDidSelectRowAtIndex:)]) {
//            [self.delegate discoveredPeripheralViewDidSelectRowAtIndex:(int)indexPath.row];
//        }
    
}

/**
 *  自动释放
 */
-(void)dealloc
{
    _peripherals = nil;
    _bgView = nil;
    _contentView = nil;
    _tableView = nil;
    _titelLabelBtn = nil;
    _peripheral = nil;
    _linkBtn = nil;
    _cancleBtn = nil;
}

@end
