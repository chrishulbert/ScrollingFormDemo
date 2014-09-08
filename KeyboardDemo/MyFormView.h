//
//  MyFormView.h
//  KeyboardDemo
//
//  Created by Chris Hulbert on 7/09/2014.
//  Copyright (c) 2014 ChrisHulbert. All rights reserved.
//
//  This is the root view for MyFormViewController.

#import <UIKit/UIKit.h>

@interface MyFormView : UIScrollView

@property(nonatomic, readonly) UITextField *topField;
@property(nonatomic, readonly) UITextField *bottomField;

@end
