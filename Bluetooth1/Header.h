//
//  Header.h
//  Bluetooth
//
//  Created by 苏敏 on 2019/8/27.
//  Copyright © 2019 苏敏. All rights reserved.
//

#ifndef Header_h
#define Header_h
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define STATUS_HEIGHT           [[UIApplication sharedApplication] statusBarFrame].size.height
#define NAV_HEIGHT              self.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT           self.tabBarController.tabBar.frame.size.height

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "MBProgressHUD+MJ.h"

#import <CoreBluetooth/CoreBluetooth.h>

#endif /* Header_h */
