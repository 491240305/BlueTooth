//
//  SMBleCenter.h
//  Bluetooth
//
//  Created by 苏敏 on 2019/8/27.
//  Copyright © 2019 苏敏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol SMBleCenterDelegate <NSObject>
/**
 * 选择实现，不管实不实现都不会警告⚠️
 */

@optional

-(void)didDisCoverPeripherals:(NSMutableArray*)pers;

-(void)didConnectDeviceIdentifier:(NSString*)identi AndAllPeripherals:(NSMutableDictionary*)persDic;

-(void)didCancelConnectDeviceIdentifier:(NSString*)identi AndRemainPeripheral:(NSMutableDictionary*)persDic;

@end


typedef void (^discoverCallBlock)(void);

typedef void(^rssiCallBlock)(NSString * UUID,int nRSSI);


@interface SMBleCenter : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>


@property (nonatomic,assign)id<SMBleCenterDelegate>delegate;
/**
 * @brief 设备中心(手机)
 **/

@property (nonatomic, strong) dispatch_queue_t handleQueue;

@property (nonatomic, assign) BOOL bScaning;

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) NSData *valueData;

/**
 * @brief 存放搜索到的蓝牙设备(bConnectOnlyOne == YES 时 可用)
 **/
@property (nonatomic,strong) NSMutableArray *discoveredPeripherals;

/**
 *  单个设备
 */
@property (nonatomic, strong) CBPeripheral *connectPeripheral;



/**
 * @brief 扫描超时时间
 * @see   notification
 */
@property (nonatomic, assign) int nScanTimeOut;

/**
 * @brief 是否监听信号强度
 * @see   notification WXJBlueCenterListenRSSICallbackNot
 */
@property (nonatomic, assign) BOOL bListenRSSI;

/**
 * @brief 监听信号强度间隔周期
 *
 * @see  property bListenRSSI
 */
@property (nonatomic, assign) NSTimeInterval nListenInterval;

/**
 * @brief 检测周围设备block块
 */
@property (atomic,copy) discoverCallBlock discoverCallback;

@property (atomic,copy) rssiCallBlock rssiCallback;

/**
 * peripheral 服务
 */
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) CBCharacteristic *characteristic;

/**
 * @brief 初始化单例
 */

+ (SMBleCenter *)sharedBleCenter;

/**
 * @brief 搜索并尝试连接周围设备
 */
- (void)scanThePeripheral;

/**
 * @brief 在限定时间内搜索并尝试连接周围设备
 * @param time 时间
 * @param completedHander 扫描结束后的回调
 */
- (void)scanThePeripheral:(NSTimeInterval)time completedHandler:(void(^)())completedHandler;

/**
 * @brief 搜索并尝试连接指定设备
 */
- (void)scanThePeripheralWithUUID:(NSString *)UUID;


- (void)scanThePeripheralWithUUID:(NSString *)UUID time:(NSTimeInterval)time;

/**
 * @brief 在限定时间内搜索并尝试连接指定设备
 * @param time 时间
 * @param completedHander 扫描结束后的回调
 */
- (void)scanThePeripheralWithUUID:(NSString *)UUID time :(NSTimeInterval)time completedHandler:(void(^)())completedHandler;

/**
 * @brief 停止扫描蓝牙设备
 */
- (void)stopScan;

- (void)connectPeripheral:(NSString *)UUID;

- (void)connectThePer:(CBPeripheral *)per;
/**
 * @brief 断开指定外设连接
 * @param uuid 外设uuid
 */
- (void)cancelPeripheralConnection:(NSString *)UUID;

/**
 * @brief 读取数据
 * @param serviceUUID        服务UUID
 * @param characteristicUUID 特征UUID
 * @param per                外设对象
 *
 * @see   notification NoaBlueCenterRecivedCommCallbackNoti
 */
- (void)readValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per;

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/**
 * @brief 发送指令
 * @param serviceUUID        服务UUID
 * @param characteristicUUID 特征UUID
 * @param per                外设对象
 * @param data               指令
 */
- (void)writeValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per data:(NSData *)data;


- (void)writeValueWithoutResponse:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per data:(NSData *)data;

/**
 * @brief receiver static change noti
 * @param serviceUUID           服务UUID
 * @param characteristicUUID    特征UUID
 * @param per                   外设对象
 * @param on  true              启用监听
 * @param on  false             关闭监听
 *
 * @see   notification NoaBlueCenterRecivedCommCallbackNoti
 */
- (void)notify:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID per:(CBPeripheral *)per on:(bool)on;

/**
 * @brief 取出service
 * @param serUUID 待取出service的 uuid
 * @param per     外设对象
 * @retval 取出的CBService 对象
 */
+ (CBService *)findServiceWithUUID:(NSString *)serUUID per:(CBPeripheral *)per;

/**
 * @brief 取出chara 待取出chara的 uuid
 * @param charaUUID
 * @param service CBService对象
 * @retval 取出的CBCharacteristic 对象
 */
+ (CBCharacteristic *)findCharacteristicFromUUID:(NSString *)charaUUID service:(CBService*)service;

@end
