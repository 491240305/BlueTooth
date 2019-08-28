//
//  DiscoveredPeripheralCell.m
//  BTclinic
//
//  Created by 苏敏 on 2019/7/12.
//  Copyright © 2019 苏敏. All rights reserved.
//

#import "DiscoveredPeripheralCell.h"

@implementation DiscoveredPeripheralCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//然并卵
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the view for the selected state
}

+ (NSString *)forCellWithReuseIdentifier {
    return NSStringFromClass(DiscoveredPeripheralCell.class);
}

@end
