//
//  MyFormView.m
//  KeyboardDemo
//
//  Created by Chris Hulbert on 7/09/2014.
//  Copyright (c) 2014 ChrisHulbert. All rights reserved.
//
//  This is the root view for MyFormViewController.

#import "MyFormView.h"

static int kMargin = 10;
static int kFieldHeight = 40;

@implementation MyFormView

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        // Make the top field.
        _topField = [[UITextField alloc] init];
        _topField.borderStyle = UITextBorderStyleRoundedRect;
        _topField.placeholder = @"Top field";
        _topField.returnKeyType = UIReturnKeyNext;
        [self addSubview:_topField];
        
        // Make the bottom field.
        _bottomField = [[UITextField alloc] init];
        _bottomField.placeholder = @"Bottom field";
        _bottomField.borderStyle = UITextBorderStyleRoundedRect;
        _bottomField.returnKeyType = UIReturnKeyDone;
        [self addSubview:_bottomField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    int w = self.bounds.size.width;
    int h = self.bounds.size.height;
    int t = self.contentInset.top; // Size of the nav+status bars.
    
    // Pin this field to the top. No need to take account for the nav bar height, as the
    // scroll view's contentInset takes care of that.
    _topField.frame = CGRectMake(kMargin, kMargin, w - 2*kMargin, kFieldHeight);
    
    // Pin this to the bottom. We do need to take account for the content inset height
    // here so that it's not offscreen.
    _bottomField.frame = CGRectMake(kMargin, h - t - kFieldHeight - kMargin,
                                    w - 2*kMargin, kFieldHeight);
    
    // Set the content size to fit the bottom field plus some padding.
    self.contentSize = CGSizeMake(w, CGRectGetMaxY(_bottomField.frame) + kMargin);
}

@end
