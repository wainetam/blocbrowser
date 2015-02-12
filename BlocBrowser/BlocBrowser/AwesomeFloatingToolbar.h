//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Waine Tam on 2/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPinchWithScale:(CGFloat)scale;

@end

@interface AwesomeFloatingToolbar : UIView

- (instancetype)initWithFourTitles:(NSArray *)titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event; // NSSet will contain one UITouch object
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

@end
