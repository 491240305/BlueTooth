
//
//  SMBleCenter.m
//  Bluetooth
//
//  Created by 苏敏 on 2019/8/27.
//  Copyright © 2019 苏敏. All rights reserved.
//

#import "SMBleCenter.h"

#import "MBProgressHUD+MJ.h"

// 服务UUID
//#define Service_UUID @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"  // 广播UUID

#define SERVICE_UUID @"0000FEE2-0000-1000-8000-00602F9B2589"  // 服务UUID

// 发送命令UUID
#define Command_Characterristic @"D44BC439-ABFD-45A2-4254-2D4D31129500"

// 空中升级指令
#define OTA_Characteristic @"00001805-494C-4F47-4943-544543480000"

//数据接收UUID
#define RECEIVE_UUID @"d44bc439-abfd-45a2-4254-2d4d31129501"

/*服 务UUID:0000fee2-0000-1000-8000-00602f9b2589
 数据接收UUID:d44bc439-abfd-45a2-4254-2d4d31129501
 命令发送UUID:D44BC439-ABFD-45A2-4254-2D4D31129500
 */


@interface SMBleCenter()


@property (nonatomic,strong) NSMutableArray *demoArr;
@property (nonatomic,strong) NSMutableData *waitingTailData;

@end

@implementation SMBleCenter


- (NSMutableArray *)discoveredPeripherals
{
    if (!_discoveredPeripherals) {
        _discoveredPeripherals = [NSMutableArray array];
    }
    return _discoveredPeripherals;
}

/**
 *  创建单例
 *
 *  @return 返回蓝牙单例
 */
+ (SMBleCenter *)sharedBleCenter
{
    static SMBleCenter * sharedBleCenter = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedBleCenter = [[SMBleCenter alloc] init];
        [sharedBleCenter initWithData];
    });
    return sharedBleCenter;
}

- (void)initWithData
{
    _handleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_handleQueue];
    _discoveredPeripherals = [NSMutableArray array];
    _bScaning = NO;
    _bListenRSSI = NO;
    _nListenInterval = 3;
    _discoverCallback = nil;
    _rssiCallback = nil;
}

#pragma mark ---- 蓝牙操作
/**
 *  蓝牙扫描\包含过滤
 */
- (void)scanThePeripheral
{
    NSLog(NSLocalizedString(@"扫描外设的状态=======%ld", nil),(long)_peripheral.state);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    if (_centralManager.state == CBManagerStatePoweredOn) {
        _bScaning = YES;
        // 当central 已经连接到设备后，就无法再搜索到该设备
        [_centralManager scanForPeripheralsWithServices:nil options:options];
    } else {
        NSLog(NSLocalizedString(@"未打开蓝牙", nil));
    }
}

- (void)stopScan {
    [_centralManager stopScan];
}


/**
 *  扫描完成则怎么样
 */
- (void)scanThePeripheral:(NSTimeInterval)time completedHandler:(void (^)())completedHandler
{
    [self scanThePeripheral];
    
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(stopScanThePers:) userInfo:nil repeats:NO];
    self.discoverCallback = completedHandler;
    
}

/**
 *  根据UUID来扫描
 */
- (void)scanThePeripheralWithUUID:(NSString *)UUID
{
    _bScaning = YES;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:UUID]] options:options];
}


/**
 *  扫描时常\操作
 */
- (void)scanThePeripheralWithUUID:(NSString *)UUID time:(NSTimeInterval)time
{
    [self scanThePeripheralWithUUID:UUID];
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(stopScanThePers:) userInfo:nil repeats:NO];
}

/**
 *  扫描\时长\完成后的操作
 *
 *  @param UUID             UUID
 *  @param time             时长
 *  @param completedHandler 完成操作
 */
- (void)scanThePeripheralWithUUID:(NSString *)UUID time:(NSTimeInterval)time completedHandler:(void (^)())completedHandler
{
    [self scanThePeripheralWithUUID:UUID];
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(stopScanThePers:) userInfo:nil repeats:NO];
    self.discoverCallback = completedHandler;
}

#pragma mark -- Selector Actions
- (void)stopScanThePers:(id)sender
{
    //    [_centralManager stopScan];
    if (self.discoverCallback) {
        self.discoverCallback();
    }
}

#pragma mark -----------CBCentralManagerDelegate,CBPeripheralDelegate Method -----------

/**
 *  检测设备蓝牙的状态
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBManagerStatePoweredOn) {
        
#pragma mark ----- 蓝牙操作是后台线程那么当你打开或者关闭的时候自动扫描的补操作
    } else { // 当蓝牙关闭移除所有的设备&操作
        [_discoveredPeripherals removeAllObjects];
    }
}

/**
 *  发现外设
 *
 *  @param central           中央设备
 *  @param peripheral        周边设备
 *  @param advertisementData 相应数据
 *  @param RSSI              信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(NSLocalizedString(@"发现设备---%@", nil),peripheral.name);
    
    if (![_discoveredPeripherals containsObject:peripheral]) { // 发现设备组不包含该设备
        
        if ([_demoArr containsObject:peripheral.identifier.UUIDString]){ // 插入外设到数组
            [_discoveredPeripherals insertObject:peripheral atIndex:0];
            
        } else if (peripheral.name.length > 0 ){
            //过滤设备列表。 && [peripheral.name containsString:@"BT-M"]
            //NSLog(NSLocalizedString(@"连接时的外设:%@", nil),peripheral);
            [_discoveredPeripherals addObject:peripheral]; // 添加外设
        }
    }
    
    //同步出扫描到的蓝牙设备
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(didDisCoverPeripherals:)]) {
            [self.delegate didDisCoverPeripherals:self.discoveredPeripherals];
        }
    });
}

#pragma mark ------------------------- 蓝牙连接操作 ---------------------------------
/**
 *  断线连接设备
 */
- (void)connectPeripheral:(NSString *)UUID
{
    
    CBPeripheral *per;
    if (per.state == CBPeripheralStateDisconnected) {
        
        return;
    }
    [self cleanUpWithWithPer:per];
    [_centralManager cancelPeripheralConnection:per];
    //[_discoveredPeripherals removeAllObjects];
}

/**
 *  清除所有的设备
 */
- (void)cleanUpWithWithPer:(CBPeripheral *)per
{
    if (per.state == CBPeripheralStateDisconnected ) {
        return;
    }
    if (per.services != nil) {
        for (CBService *service in per.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *charc in service.characteristics) {
                    if (charc.isNotifying) {
                        [per setNotifyValue:NO forCharacteristic:charc];
                        return;
                    }
                }
            }
        }
    }
}

/**
 *  连接设备
 */
- (void)connectThePer:(CBPeripheral *)per
{
    [_centralManager connectPeripheral:per options:nil];
}

#pragma mark --- 连接设备后的操作
/**
 *  连接外设成功调用
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(NSLocalizedString(@"连接成功", nil));
    
    // 停止扫描
    [self.centralManager stopScan];
    
    // 设置代理
    peripheral.delegate = self;
    
    // 扫描服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    
}

/**
 *  连接失败的时候调用
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",error);
    
    [MBProgressHUD showError:[NSString stringWithFormat:NSLocalizedString(@"%@", nil), error]];
}

/**
 *  当已经与peripheral建立的连接断开时调用 \ 自动重连
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //断开重连
    NSLog(NSLocalizedString(@"断开连接==", nil));
    //断开连接后移除数组的所有数据
    [_discoveredPeripherals removeAllObjects];
    
}

/**
 *  发现服务
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //连接后走这里
    NSLog(NSLocalizedString(@"已经发现发现服务===%@", nil),peripheral);
    for (CBService *service in peripheral.services) { // 扫描特征
        [service.peripheral discoverCharacteristics:nil forService:service];
        
    }
    NSArray *services = peripheral.services;
    NSLog(@"service:====%@",services);
    if (services.count > 0) {
        CBService *service = services[0];
        CBUUID *writeUUID = [CBUUID UUIDWithString: Command_Characterristic];
        CBUUID *notifyUUID = [CBUUID UUIDWithString: RECEIVE_UUID];
        [peripheral discoverCharacteristics:@[writeUUID, notifyUUID] forService:service]; // 发现服务
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error
{
    NSLog(@"%d",[RSSI intValue]);
    
}


/**
 *  发型特征
 *
 *  @param peripheral 周边设备
 *  @param service    发现的服务    有几个服务这个方法就会调用几次
 *  @param error      错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    //注册通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"state" object:nil userInfo:@{@"state":[NSString stringWithFormat:@"%ld",_peripheral.state]}];
    _peripheral = peripheral;
    //连接后走这里
    NSLog(NSLocalizedString(@"发现特征", nil));
    NSLog(NSLocalizedString(@"当前外设====：%@", nil),peripheral);
    if (error) { // 如果失败
        [self cleanUpWithWithPer:peripheral];
        NSLog(@"didUpdateValueForCharacteristic error : %@", error.localizedDescription);
        
        return;
    }
    NSLog(NSLocalizedString(@"服务特征：=====%@", nil),service.characteristics);
    NSLog(NSLocalizedString(@"服务UUID======%@", nil),service.UUID.UUIDString);
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([service.UUID.UUIDString isEqualToString:SERVICE_UUID]) {
            self.characteristic = service.characteristics[1];
            //设置通知，接收蓝牙实时数据
            [self notifyCharacteristic:peripheral characteristic:characteristic];
            //读取蓝牙设备信息
            //[peripheral readValueForCharacteristic:characteristic];
            //获取数据后,进入代理方法:
            //- peripheral: didUpdateValueForCharacteristic: error:
            //根据蓝牙协议发送指令,写在这里是自动发送,也可以写按钮方法,手动操作
            //我将指令封装了一个类,以下三个方法是其中的三个操作,具体是啥不用管,就知道是三个基本操作,返回数据后,会进入代理方法
            //校准时间
            //            [CBCommunication cbCorrectTime:peripheral characteristic:characteristic];
            //            //获取mac地址
            //            [CBCommunication cbGetMacID:peripheral characteristic:characteristic];
            //            //获取脱机数据
            //            [CBCommunication cbReadOfflineData:peripheral characteristic:characteristic];
        }
    }
}

#pragma mark - 设置通知
//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    
    if (characteristic.properties & CBCharacteristicPropertyNotify) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        //设置通知后,进入代理方法:
        //- peripheral: didUpdateNotificationStateForCharacteristic: characteristic error:
    }
    NSLog(@"charaValue====%@",characteristic.value);
}
//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

//设置通知后调用,监控蓝牙传回的实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"peripheral===%@---characteristic===%@",peripheral,characteristic);
    
    if (error) {
        NSLog(NSLocalizedString(@"错误: %@", nil), error.localizedDescription);
    }
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
        //获取数据后,进入代理方法:
        //- peripheral: didUpdateValueForCharacteristic: error:
    } else {
        NSLog(NSLocalizedString(@"%@停止通知", nil), characteristic);
    }
}




#pragma mark --------------------------- 蓝牙读写操作 ---------------------------------
/**
 *  蓝牙读操作
 *
 *  @param serviceUUID
 *  @param characteristicUUID
 *  @param per
 */
- (void)readValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per
{
    NSLog(NSLocalizedString(@"读取操作:%@", nil),characteristicUUID);
    CBService * ser= [SMBleCenter findServiceWithUUID:serviceUUID per:per];
    if (!ser) {
        return;
    }
    CBCharacteristic *chara = [SMBleCenter findCharacteristicFromUUID:characteristicUUID service:ser];
    if (!chara) {
        return;
    }
    [per readValueForCharacteristic:chara];
}

/**
 *  蓝牙写操作
 *
 *  @param serviceUUID
 *  @param characteristicUUID
 *  @param per
 *  @param data
 */
- (void)writeValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per data:(NSData *)data
{
    CBService *service = [SMBleCenter findServiceWithUUID:serviceUUID per:per];
    if (!service) {
        return;
    }
    CBCharacteristic *chara = [SMBleCenter findCharacteristicFromUUID:characteristicUUID service:service];
    if (!chara) {
        return;
    }
    [per writeValue:data forCharacteristic:chara type:CBCharacteristicWriteWithResponse];
}

/**
 *  无返回写操作
 */
- (void)writeValueWithoutResponse:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per data:(NSData *)data
{
    CBService *service = [SMBleCenter findServiceWithUUID:serviceUUID per:per];
    if (!service) {
        return;
    }
    CBCharacteristic *chara = [SMBleCenter findCharacteristicFromUUID:characteristicUUID service:service];
    if (!chara) {
        return;
    }
    [per writeValue:data forCharacteristic:chara type:CBCharacteristicWriteWithResponse];
}

/**
 *  特征操作
 */
- (void)notify:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per on:(bool)on
{
    CBService * ser = [SMBleCenter findServiceWithUUID:serviceUUID per:per];
    if (!ser) {
        return;
    }
    CBCharacteristic * chara = [SMBleCenter findCharacteristicFromUUID:characteristicUUID service:ser];
    if (!chara) {
        return;
    }
    [per setNotifyValue:on forCharacteristic:chara];
}

#pragma mark -- Find Serviece & Characteristic Method
/**
 *  找到的设备服务
 */
+ (CBService *)findServiceWithUUID:(NSString *)serUUID per:(CBPeripheral *)per
{
    for (CBService *ser in per.services) {
        if ([serUUID isEqualToString:ser.UUID.UUIDString]) {
            return ser;
        }
    }
    return nil;
}

/**
 *  找到的特征服务
 */
+ (CBCharacteristic *)findCharacteristicFromUUID:(NSString *)charaUUID service:(CBService*)service
{
    for (CBCharacteristic *chara in service.characteristics) {
        
        if ([charaUUID isEqualToString:chara.UUID.UUIDString]) {
            return chara;
        }
    }
    return nil;
}

/**
 * 最终，蓝牙发过来的数据，我们会在这个回调方法中拿到
 */
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//{
//    NSLog(@"peripheral===%@---characteristic===%@",peripheral,characteristic);
//
//}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        NSLog(NSLocalizedString(@"写入成功", nil));
    } else {
        NSLog(NSLocalizedString(@"写入失败:%@", nil),error.description);
    }
}

/**
 *  接收数据
 *
 *  @param peripheral     外部设备
 *  @param characteristic 外设特征
 *  @param error          错误信息
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(NSLocalizedString(@"写入数据的返回特征值======%@", nil),characteristic.value);
}

/**
 *  信号强度
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%d",[peripheral.RSSI intValue]);
    
    if (self.rssiCallback) {
        self.rssiCallback(peripheral.identifier.UUIDString,[peripheral.RSSI intValue]);
    }
}



/**
 *  自动释放
 */
-(void)dealloc
{
    _centralManager = nil;
    _discoveredPeripherals = nil;
    
}

@end
