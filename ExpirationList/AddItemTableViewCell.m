//
//  AddItemTableViewCell.m
//  ExpirationList
//
//  Created by Morgan Chen on 11/11/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "AddItemTableViewCell.h"
#import "AddItemTextField.h"

@implementation AddItemTableViewCell

- (void)awakeFromNib {
    self.textField.cell = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
