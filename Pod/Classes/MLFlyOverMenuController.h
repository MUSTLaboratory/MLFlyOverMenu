//
//  MLFlyOverMenuController.h
//  MLFlyOverMenu
//
//  Created by iOS Developer on 29.08.14.
//  Copyright (c) 2014 MUSTLab. All rights reserved.
//

#import <Foundation/Foundation.h>

static const CGFloat MLFlyOverMenuControllerAnimationDuration;

typedef enum : NSUInteger {
    MLFlyOverMenuDirectionFromLeft,
    MLFlyOverMenuDirectionFromRight,
    MLFlyOverMenuDirectionFromTop,
    MLFlyOverMenuDirectionFromBottom
} MLFlyOverMenuDirection;

@interface MLFlyOverMenuController : NSObject

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong, readonly) UIViewController *presentingViewController;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) BOOL aboveBars;

+ (instancetype)flyOverMenuController;

+ (instancetype)flyOverMenuControllerWithContentViewController:(UIViewController *)viewController;

- (void)presentFlyOverMenuInViewController:(UIViewController *)viewController;

- (void)presentFlyOverMenuInViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)presentFlyOverMenuInViewController:(UIViewController *)viewController
                             withDirection:(MLFlyOverMenuDirection)direction
                                  animated:(BOOL)animated;

- (void)dismiss;

- (void)dismissAnimated:(BOOL)animated;

@end

#pragma mark - Segues

extern NSString * const MLFlyOverMenuPresentSegueLeftIdentifier;//ml_from_left
extern NSString * const MLFlyOverMenuPresentSegueRightIdentifier;//ml_from_right
extern NSString * const MLFlyOverMenuPresentSegueTopIdentifier;//ml_from_top
extern NSString * const MLFlyOverMenuPresentSegueBottomIdentifier;//ml_from_bottom

@interface MLFlyOverMenuControllerPresentSegue : UIStoryboardSegue

@end

#pragma mark - Categories

@interface UIViewController (MLFlyOverMenuController)

@property (nonatomic, strong) IBOutlet MLFlyOverMenuController *flyOverMenuController;

@property (nonatomic, copy) NSNumber *contentWidthInFlyOverMenu;//Can be set via IB User-defined runtime attributes
@property (nonatomic, copy) NSNumber *contentHeightInFlyOverMenu;//Can be set via IB User-defined runtime attributes

@end