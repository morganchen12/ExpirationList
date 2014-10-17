//
//  AddItemView.m
//  ExpirationList
//
//  Created by Morgan Chen on 10/16/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "AddItemView.h"

@interface AddItemView ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation AddItemView

-(NSString *)name {
    return self.nameTextField.text;
}

-(NSDate *)date {
    return self.datePicker.date;
}

@end
