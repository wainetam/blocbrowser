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

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryLongPressWithRotateIndex:(int)count;

@end

@interface AwesomeFloatingToolbar : UIView

- (instancetype)initWithFourTitles:(NSArray *)titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

@end
