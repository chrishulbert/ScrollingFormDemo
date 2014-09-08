//
//  MyFormViewController.m
//  KeyboardDemo
//
//  Created by Chris Hulbert on 7/09/2014.
//  Copyright (c) 2014 ChrisHulbert. All rights reserved.
//
//  This demonstrates a form with many fields that needs to scroll them to visibility when the keyboard appears.

#import "MyFormViewController.h"

#import "MyFormView.h"

@implementation MyFormViewController {
    MyFormView *_view;
}

- (id)init {
    if (self = [super init]) {
        self.title = @"My Form";
    }
    return self;
}

- (void)loadView {
    _view = [[MyFormView alloc] init];
    self.view = _view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _view.topField.delegate = self;
    _view.bottomField.delegate = self;
    
    // Listen for the keyboard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    // Figure out the size of the keyboard.
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // Add the keyboard size to the bottom content inset of the scroll view.
    UIEdgeInsets inset = _view.contentInset;
    inset.bottom = frame.size.height;
    _view.contentInset = inset;

    // Same for the scroll inset, so it looks right.
    UIEdgeInsets scrollInset = _view.scrollIndicatorInsets;
    scrollInset.bottom = frame.size.height;
    _view.scrollIndicatorInsets = scrollInset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    float duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    // Animate the scroll insets away, with an animation that matches the keyboard sliding down.
    [UIView animateWithDuration:duration animations:^{
        // Remove the insets.
        UIEdgeInsets inset = _view.contentInset;
        inset.bottom = 0;
        _view.contentInset = inset;
        
        // Same for the scroll inset, so it looks right.
        UIEdgeInsets scrollInset = _view.scrollIndicatorInsets;
        scrollInset.bottom = 0;
        _view.scrollIndicatorInsets = scrollInset;
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _view.topField) {
        [_view.bottomField becomeFirstResponder];
    }
    if (textField == _view.bottomField) {
        [textField resignFirstResponder];
    }
    return NO;
}

@end
