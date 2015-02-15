//
//  WebBrowserViewController.m
//  BlocBrowser
//
//  Created by Waine Tam on 1/27/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "WebBrowserViewController.h"
#import "AwesomeFloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface WebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
//@property (nonatomic, strong) UIButton *backButton;
//@property (nonatomic, strong) UIButton *forwardButton;
//@property (nonatomic, strong) UIButton *stopButton;
//@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation WebBrowserViewController

#pragma mark - UIViewController

- (void)loadView {
    UIView *mainView = [UIView new];

    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    
    // build text field and add as subview to main view
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeAlphabet;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocapitalizationTypeNone;
    self.textField.placeholder = NSLocalizedString(@"Search or enter website name", @"Placeholder text for web browser URL field or search terms");
    
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    
    self.awesomeToolbar.delegate = self;
    
//    for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
    for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView; // the view the controller manages
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title")
                                                                   message:NSLocalizedString(@"Get excited to use the best web browser ever!", @"Welcome comment")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK, I'm excited!", @"Welcome button title") style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction: defaultAction];
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // make webview fill main view
    self.webview.frame = self.view.frame;
    
    // calculate dimensions
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
//    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
//    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    // assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    if (self.awesomeToolbar.frame.size.width == 0) { // upon first init of awesomeToolbar
        self.awesomeToolbar.frame = CGRectMake(width * 0.1, width * 0.1 + itemHeight, width * 0.8, 100);
    }
}

- (void)resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    
}

#pragma mark - AwesomeFloatingToolbarDelegate

- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:kWebBrowserBackString]) {
        [self.webview goBack];
    } else if ([title isEqual:kWebBrowserForwardString]) {
        [self.webview goForward];
    } else if ([title isEqual:kWebBrowserStopString]) {
        [self.webview stopLoading];
    } else if ([title isEqual:kWebBrowserRefreshString]) {
        [self.webview reload];
    }
}

- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPinchWithScale:(CGFloat)scale {
    // scale bounds

    CGFloat newToolbarWidth = CGRectGetWidth(toolbar.bounds) * scale;
    CGFloat newToolbarHeight = CGRectGetHeight(toolbar.bounds) * scale;
    
    CGRect potentialNewFrame = CGRectMake(self.awesomeToolbar.frame.origin.x
                                           , self.awesomeToolbar.frame.origin.y, newToolbarWidth, newToolbarHeight);
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        self.awesomeToolbar.frame = potentialNewFrame;
    }

//    self.awesomeToolbar.transform = CGAffineTransformScale(self.awesomeToolbar.transform, scale, scale);
}

- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryLongPressWithRotateIndex:(int)count {
    NSMutableArray *shiftedColors = [[NSMutableArray alloc] init];
    shiftedColors = [self shiftArray:self.awesomeToolbar.colors shiftBy:count];
//    [self shiftArray:self.awesomeToolbar.colors shiftBy:count];
    NSMutableArray *copy = [shiftedColors copy];
    self.awesomeToolbar.colors = copy;
}

// QUESTION: where to put helper methods that aren't necessarily specfic to the class (global helper functions?)
- (NSMutableArray *)shiftArray:(NSMutableArray *)inputArray shiftBy:(int)count {
    for (int i = count; i > 0; i--) {
        NSObject *obj = [inputArray lastObject];
        [inputArray insertObject:obj atIndex:0];
//        [inputArray removeObject:obj];
        [inputArray removeLastObject];
    }
    
    return inputArray;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *inputtedString = textField.text;
    
    if ([inputtedString rangeOfString:@" "].location == NSNotFound ) { // entered URL
        NSURL *URL = [NSURL URLWithString:inputtedString];
        
        if(!URL.scheme) {
            // user didn't type http or https
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", inputtedString]];
        }
        
        if(URL) {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [self.webview loadRequest:request];
        }
    } else { // entered search terms
        
        NSMutableString *inputtedWithPlussesAdded = [inputtedString mutableCopy];
        [inputtedWithPlussesAdded replaceOccurrencesOfString:@" "
                                                  withString:@"+"
                                                     options:NSCaseInsensitiveSearch
                                                       range:NSMakeRange(0, [inputtedWithPlussesAdded length])];
        
        NSURL *URL = [NSURL URLWithString:[[NSString alloc] initWithFormat: @"http://www.google.com/search?q=%@", inputtedWithPlussesAdded]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    return NO;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(error.code != -999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self updateButtonsAndTitle];
    self.frameCount--;
}

#pragma mark - Miscellaneous

- (void)updateButtonsAndTitle {
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    if (self.frameCount > 0) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kWebBrowserRefreshString];
}

@end
