Say you've got a form, such as a 'sign up' form on your iPhone app, and this view controller is basically a screenful of UITextFields. How do you best make the fields scroll out of the way of the keyboard so that they are visible, as you tab between them? Here's my favourite way to do so. It's effective and simple, animates perfectly, and the code is very clean as it takes care .

If you're just after the code and don't want to read this whole article, here it is: XXXX

Basically the gist of it is to create a UIViewController whose root view is a subclass of UIScrollView. This scroll view contains many UITextFields. The UIViewController listens to the keyboard appearance notifications, and adjusts the UIScrollView's contentInset to suit. And  UIKit automagically scrolls the scroll view so that the focused UITextField is in the visible area - you get that part for free!

## The views

And here it is in some more detail. Here's how I create my UIScrollView subclass, which is to become the root view of my UIViewController:

	//  MyFormView.h
	//  This is the root view for MyFormViewController.

	#import <UIKit/UIKit.h>

	@interface MyFormView : UIScrollView

	@property(nonatomic, readonly) UITextField *topField;
	@property(nonatomic, readonly) UITextField *bottomField;

	@end

Nothing much to report on in the above code, just a UIScrollView subclass, with the two fields exposed as readonly properties. Now, these fields actually get created in the .m file, below:

	//  MyFormView.m

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

Again, no magic above: just the init method of the UIScrollView subclass creates the fields and adds them to itself. So the hierarchy will be: UIViewController -> UIScrollView as root view -> UITextField, except that I've created a UIScrollView subclass.

And MyFormView is also responsible for positioning the fields at the top and bottom of the screen, shown below. In real life, you'd likely stack the UITextFields on top of each other, rather than tracking the bottom of the screen. However, if i made a dozen different text fields then this sample code would be too long for illustrative purposes. See below:

	//  MyFormView.m continued...

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

So that's it for the views. Next up, the view controllers.

## The view controller

The view controller is simple enough. Here is the header file:

	//  MyFormViewController.h
	//  This demonstrates a form with many fields that needs to scroll them to visibility when the keyboard appears.

	#import <UIKit/UIKit.h>

	@interface MyFormViewController : UIViewController <UITextFieldDelegate>

	@end

The only interesting thing is that the above implements UITextFieldDelegate. As you'll see later, this isn't used for the purposes of the scrolling effect that is the main point of this article, it is just so that there is the ability to tap 'next' to jump to the next UITextField, and 'done' to close the keyboard.

Below is the code for creating the view controller in such a way that my UIScrollView subclass is its root view:

	//  MyFormViewController.m
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

You could achieve the same view hierarchy with a XIB / Storyboard quite simply I imagine, however I'll leave that as an exercise to the reader if you prefer to use interface builder. Basically in the loadView method, we instantiate a MyFormView and set it as the root view with `self.view = _view`. You may note that nowhere is the frame being set, because it'll be set by the containing UINavigationController for us.

Once the view has loaded, we want to subscribe to keyboard notifications. You can see that below:

	//  MyFormViewController.m continued...

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

And exactly what we do with those keyboard notifications is probably the most interesting part of this article, and is shown below:

	//  MyFormViewController.m continued...

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

Here's what the above code does: When the keyboard is about to appear, we increase the bottom content insets so that even though the scroll view still goes under the keyboard, it scrolls far enough so that the lowest content is above the keyboard. This doesn't need to be animated, as the UITextField animates itself into a visible position automagically.

When the keyboard hides, we re-set the bottom insets to zero. Now this needs to be animated, because if it wasn't it would force the content to jump quickly. The animation duration is matched to the keyboard animation so that it all looks perfect.

And there's a little more code to handle the text delegate, as you can see none of the scrolling logic is involved here:

	//  MyFormViewController.m continued...

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

## Launching

To launch this demo, i've included a little boilerplate in the app delegate:

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	    
	    // Make the view controller stack.
	    MyFormViewController *form = [[MyFormViewController alloc] init];
	    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:form];
	    
	    // Make the window.
	    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	    self.window.rootViewController = nav;
	    [self.window makeKeyAndVisible];
	    
	    return YES;
	}

And that's it! If you'd like to see it all, here it is on github:
