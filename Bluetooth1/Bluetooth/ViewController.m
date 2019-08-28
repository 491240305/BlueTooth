//
//  ViewController.m
//  Bluetooth
//
//  Created by 苏敏 on 2019/8/15.
//  Copyright © 2019 苏敏. All rights reserved.
//

#import "ViewController.h"
#import "DiscoveredPeripheralView.h"
#import "SMBleCenter.h"

@interface ViewController ()<SMBleCenterDelegate,DiscoveredPeripheralViewDelegate>
@property (nonatomic, strong) CBPeripheral *connectPeripheral; // 点击连接的设备
@property (nonatomic, strong) CBPeripheral *peripheral;//单个设备
@property (nonatomic, strong) CBCentralManager *centerManager;
@property (nonatomic,strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) NSMutableArray *tableDatas;
@property (nonatomic,strong) DiscoveredPeripheralView *discoveredPeripheralView;
@property (nonatomic,strong) SMBleCenter *smBleCenter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self showBleView];
    [self setUpBleSington];
    // Do any additional setup after loading the view.
}

- (void)setUpUI {
    self.view.backgroundColor = kUIColorFromRGB(0xffffff);
    UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2-25, SCREEN_WIDTH, 50)];
    [searchBtn setTitle:@"搜索设备" forState:UIControlStateNormal];
    [searchBtn setTitleColor:kUIColorFromRGB(0x00bcf) forState:UIControlStateNormal];
    searchBtn.backgroundColor = kUIColorFromRGB(0x00b7ff);
    [searchBtn addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
}

- (void)searchClicked:(UIButton *)sender {
    //扫描设备
    [_smBleCenter scanThePeripheral];
    [_discoveredPeripheralView show];
}

- (void)showBleView {
    _tableDatas = [NSMutableArray array];
    _discoveredPeripheralView = [[DiscoveredPeripheralView alloc]initWithFrame:[UIScreen mainScreen].bounds];
}

/**
 *  蓝牙单例
 */
- (void)setUpBleSington
{
    _smBleCenter = [SMBleCenter sharedBleCenter];
    _smBleCenter.delegate = self;
    _discoveredPeripheralView.delegate = self;
    self.centerManager = _smBleCenter.centralManager;
    self.peripheral = _smBleCenter.peripheral;
    self.characteristic = _smBleCenter.characteristic;
}

/**
 *  搜索到的蓝牙设备
 */
- (void)didDisCoverPeripherals:(NSMutableArray *)pers
{
    self.tableDatas = pers;
    [_discoveredPeripheralView setPeripherals:pers];
    //NSLog(NSLocalizedString(@"搜索出来的数据===:%@", nil),self.tableDatas);
}

/**
 *  点击该行所做的操作
 */
- (void)discoveredPeripheralViewDidSelectRowAtIndex:(int)index
{
    _connectPeripheral = [self.tableDatas objectAtIndex:index];
    NSLog(@"点击连接的peripheral:====%@",_connectPeripheral);
    if ([SMBleCenter sharedBleCenter].centralManager.state == CBManagerStatePoweredOn) {
        [_smBleCenter connectThePer:_connectPeripheral];
        [MBProgressHUD showSuccess:@"连接成功"];
        [_discoveredPeripheralView hide];
        //连接成功停止扫描
        [_smBleCenter stopScan];
        [self.tableDatas removeAllObjects];
    } else if ([SMBleCenter sharedBleCenter].centralManager.state == CBManagerStatePoweredOff) {
        [MBProgressHUD showError:NSLocalizedString(NSLocalizedString(@"蓝牙未打开", nil), nil)];
    }
}



@end
