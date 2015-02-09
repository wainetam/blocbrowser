//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Waine Tam on 2/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // call the superclass (UIView)'s initializer to make sure we do all that setup first
    self = [super init];
    
    if(self) {
        
        // save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO; // QUESTION: why set this to no? why ignore user events initially?
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 thru 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;

        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
    }

    return self;
}

- (void) layoutSubviews {
    // set the frame for the 4 labels
    
    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;

        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) {
            // 0 or 2, so on left
            labelX = 0;
        } else {
            // 1 or 3, so on right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark - Touch Handling

// determines which label was touched
- (UILabel *)labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject]; // QUESTION: what if touches.length > 1; what if two finger tap?
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *) subview;  // QUESTION what subview is being returned here?
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    self.currentLabel = label;
    self.currentLabel.alpha = 0.5;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel != label) {
        // the label being touched is no longer the initial label
        self.currentLabel.alpha = 1;
    } else {
        // the label being touched is the initial label
        self.currentLabel.alpha = 0.5;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event]; // QUESTION: FloatingToolBar is a UILabel?
//    NSLog(@"Label tapped: %@", label.text);
    // when label is unenabled, the return value from labelFromTouches is UIView parent AwesomeFloatingToolbar, not UILabel
    if (self.currentLabel == label && [self.currentLabel respondsToSelector:@selector(text)] ) { // added second condition and it works
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text]; // bug is something with accessing text property of self.currentLabel
        } else {
            NSLog(@"self.delegate doesn't respond to @selector");
        }
    }
    
    self.currentLabel.alpha = 1; // shows slight flicker to indicate click
    self.currentLabel = nil; // QUESTION: why need to set to nil?
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) { // if index found
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled; // QUESTION: doesn't disable?
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
