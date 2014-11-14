//
//  AddItemTableViewCell.h
//  ExpirationList
//
//  Created by Morgan Chen on 11/11/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddItemTextField;

@interface AddItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AddItemTextField *textField;

@end
