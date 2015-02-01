//
//  WebBrowserViewController.m
//  BlocBrowser
//
//  Created by Waine Tam on 1/27/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "WebBrowserViewController.h"

@interface WebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
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

    //QUESTION: why not? can't modify array that you are looping over
//    for(UIButton *button in @[self.backButton]) {
//        button = [UIButton buttonWithType:UIButtonTypeSystem];
//    }
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    // QUESTION: but you can do this?
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [button setEnabled:NO];
    }
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
//    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
//    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];

    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
//    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Reload", @"Reload command") forState:UIControlStateNormal];
//    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];

    [self addButtonTargets];
    
//    NSString *urlString = @"http://espn.com/";
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webview loadRequest:request];
    
//    [mainView addSubview:self.webview];
//    [mainView addSubview:self.textField];
    
    for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
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
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // make webview fill main view
//    self.webview.bounds = self.view.bounds;
    self.webview.frame = self.view.frame;
    
    // QUESTION: bounds vs frame
    // calculate dimensions
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
//    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    // assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat currentButtonX = 0;
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
}

- (void)resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    
    [self.view addSubview:newWebView]; // QUESTION: have to add the view ass a subview and also to the property self.webview?
    
    self.webview = newWebView;
    
    [self addButtonTargets];
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    
}

- (void)addButtonTargets {
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *inputtedString = textField.text;
    
    if ([inputtedString rangeOfString:@" "].location == NSNotFound ) { // entered URL
        NSURL *URL = [NSURL URLWithString:inputtedString];
        
        // QUESTION: don't see scheme property on NSURL object; can you inspect properties directly like in android?
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
//    self.isLoading = YES;
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    self.isLoading = NO;
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(error.code != -999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:[error localizedDescription]
                                                       delegate:nil // QUESTION: is the UIAlert the 'receiver' for the delegate?
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
    
//    if (self.isLoading) {
    if (self.frameCount > 0) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    // QUESTION: explain canGoBack property -- where are these booleans originally set?
    self.backButton.enabled = [self.webview canGoBack];
    self.forwardButton.enabled = [self.webview canGoForward];
//    self.stopButton.enabled = self.isLoading;
//    self.reloadButton.enabled = !self.isLoading;
    self.stopButton.enabled = self.frameCount > 0;
    self.reloadButton.enabled = self.webview.request.URL && self.frameCount == 0;

}

@end
