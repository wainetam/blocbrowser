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
//@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UIButton *currentLabel;
//@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // call the superclass (UIView)'s initializer to make sure we do all that setup first
    self = [super init];
    
    if(self) {
        
        // save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = [[NSMutableArray alloc] initWithArray:@[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                                                              [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                                                              [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                                                              [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]]];
        
//        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
//                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
//                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
//                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *label = [[UIButton alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 thru 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
//            label.textAlignment = NSTextAlignmentCenter;
//            label.font = [UIFont systemFontOfSize:10];
//            label.text = titleForThisLabel;
            [label setTitle:titleForThisLabel forState:UIControlStateNormal];
            [label.titleLabel setFont:[UIFont systemFontOfSize:10]];
            label.backgroundColor = colorForThisLabel;
            [label setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            label.textColor = [UIColor whiteColor];
            
            // QUESTION: does this 'self' refer to the button or the instance of the toolbar; ok with self, crashed with 'label'; if self generally the parent object if there are subviews?
            [label addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;

//        for (UILabel *thisLabel in self.labels) {
        for (UIButton *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
        
//        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
//        [self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }

    return self;
}

- (void) layoutSubviews {
    // set the frame for the 4 labels
    
    for (UIButton *thisLabel in self.labels) {
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
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *) subview;
}

- (void) buttonPressed:(UIButton *)sender {
    NSLog(@"Button clicked");
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:sender.titleLabel.text];
    }
}

//- (void) tapFired:(UITapGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//        CGPoint location = [recognizer locationInView:self];
//        UIView *tappedView = [self hitTest:location withEvent:nil];
//        
//        if ([self.labels containsObject:tappedView]) {
//            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
//            }
//        }
//    }
//}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = recognizer.scale;
        NSLog(@"New Scale: %f", scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:scale];
        }
        
        recognizer.scale = 1.0;
//        [recognizer setScale:scale];
    }
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        int count = 1; // shift colors by this count
        NSLog(@"Long Press Ended");
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryLongPressWithRotateIndex:)]) {
            [self.delegate floatingToolbar:self didTryLongPressWithRotateIndex:count];
        }
    }
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) { // if index found
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
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
