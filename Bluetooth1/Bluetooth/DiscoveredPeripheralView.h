//
//  DiscoveredPeripheralView.h
//  Bluetooth
//
//  Created by 苏敏 on 2019/8/27.
//  Copyright © 2019 苏敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol DiscoveredPeripheralViewDelegate <NSObject>

@optional
/**
 *  选中某一行
 *
 *  @param index 行index
 */
- (void)discoveredPeripheralViewDidSelectRowAtIndex:(int)index;
/**
 *  当前弹出框已收起
 */
- (void)discoveredPeripheralViewDidHide;

@end


@interface DiscoveredPeripheralView : UIView<UITableViewDelegate,UITableViewDataSource>
{
    UIView *_bgView;
    UIView *_contentView;
    UIButton *_titelLabelBtn;
    NSIndexPath *_indexPath;
    NSMutableArray *_peripherals;
    CBPeripheral *_peripheral;
    UIButton *_linkBtn;
    UIButton *_cancleBtn;
    NSIndexPath *_lastSelectIndexPath;
}

@property (nonatomic, assign) id <DiscoveredPeripheralViewDelegate> delegate;
@property (nonatomic, strong)  UITableView *tableView;

/**
 *  显示
 */
- (void)show;

/**
 *  收起
 */
- (void)hide;

/**
 *  设置数据源
 *
 *  @param peripherals 数据源peripherals
 */
- (void)setPeripherals:(NSArray *)peripherals;

- (void)insertPeripheral:(CBPeripheral *)perihperal;

@end
