//
//  AddItemTextField.h
//  ExpirationList
//
//  Created by Morgan Chen on 11/11/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddItemTableViewCell;

@interface AddItemTextField : UITextField

@property (weak, nonatomic, readwrite) AddItemTableViewCell *cell;

@end
