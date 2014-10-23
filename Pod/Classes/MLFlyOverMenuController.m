//
//  MLFlyOverMenuController.m
//  MLFlyOverMenu
//
//  Created by iOS Developer on 29.08.14.
//  Copyright (c) 2014 MUSTLab. All rights reserved.
//

#import <objc/runtime.h>

#import "MLFlyOverMenuController.h"

#pragma mark - Constants

static const CGFloat MLFlyOverMenuControllerAnimationDuration = 0.25;

static const char kFlyOverMenuControllerKey;

static const char kFlyOverMenuControllerContentWidthKey;

static const char kFlyOverMenuControllerContentHeightKey;

#pragma mark - Class extension

@interface MLFlyOverMenuController ()

@property (nonatomic, strong) UIViewController *presentingViewController;//redefine as read-write

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) MLFlyOverMenuDirection direction;

@end

#pragma mark - Class implementation

@implementation MLFlyOverMenuController

+ (instancetype)flyOverMenuController
{
    MLFlyOverMenuController *flyOverMenu = [self new];
    
    return flyOverMenu;
}

+ (instancetype)flyOverMenuControllerWithContentViewController:(UIViewController *)viewController
{
    MLFlyOverMenuController *flyOverMenu = [self new];
    
    flyOverMenu.contentViewController = viewController;
    
    return flyOverMenu;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)dealloc
{
    [self dismiss];
}

- (void)setup
{
    
}

- (void)presentFlyOverMenuInViewController:(UIViewController *)viewController;
{
    [self presentFlyOverMenuInViewController:viewController animated:NO];
}

- (void)presentFlyOverMenuInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self presentFlyOverMenuInViewController:viewController withDirection:MLFlyOverMenuDirectionFromLeft animated:animated];
}

- (void)presentFlyOverMenuInViewController:(UIViewController *)viewController
                             withDirection:(MLFlyOverMenuDirection)direction
                                  animated:(BOOL)animated
{
    UIViewController *presentingViewController = viewController;
    
    if (self.aboveBars && ![presentingViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = presentingViewController.navigationController;
        
        if (navigationController) {
            presentingViewController = navigationController;
        }
    }
    
    self.presentingViewController = presentingViewController;
    
    NSAssert(self.contentViewController != nil, @"content view controller is nil");
    
    NSAssert(self.presentingViewController != nil, @"presenting view controller is nil");
    
    self.direction = direction;
    
    __weak MLFlyOverMenuController *weakSelf = self;
    
    self.contentViewController.flyOverMenuController = weakSelf;
    
    [self setupContentView];
    
    [self placeContentViewToInitialPosition];
    
    [self deployViewController:self.contentViewController
          toHostViewController:self.presentingViewController];
    
    void (^animations)() = ^()
    {
        [self placeContentViewToTargetPosition];
    };
    
    if (animated) {
        [UIView animateWithDuration:MLFlyOverMenuControllerAnimationDuration animations:animations];
    } else {
        animations();
    }
}

- (void)dismiss
{
    [self dismissAnimated:NO];
}

- (void)dismissAnimated:(BOOL)animated
{
    if (!self.contentViewController || !self.presentingViewController) {
        return;
    }
    
    void (^undeployCompletionBlock)(void) = [self undeployViewController:self.contentViewController
                                                  fromHostViewController:self.presentingViewController];
    void (^completionBlock)() = ^()
    {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
        
        self.contentViewController.flyOverMenuController = nil;
        self.contentViewController = nil;
    };
    
    void (^animations)() = ^()
    {
        [self placeContentViewToInitialPosition];
    };
    
    if (animated) {
        [UIView animateWithDuration:MLFlyOverMenuControllerAnimationDuration animations:animations completion:^(BOOL finished) {
            undeployCompletionBlock();
            
            completionBlock();
        }];
    } else {
        animations();
        
        undeployCompletionBlock();
        
        completionBlock();
    }
}

#pragma mark - Private methods

- (void)setupContentView
{
    CGRect presentingFrame = self.presentingViewController.view.bounds;
    
    CGFloat contentWidth = self.contentViewController.contentWidthInFlyOverMenu.floatValue;
    
    if (contentWidth <= 0) {
        contentWidth = presentingFrame.size.width;
    }
    
    contentWidth -= self.contentInsets.left + self.contentInsets.right;
    
    CGFloat contentHeight = self.contentViewController.contentHeightInFlyOverMenu.floatValue;
    BOOL staticHeight = (contentHeight > 0);
    
    if (contentHeight <= 0) {
        contentHeight = presentingFrame.size.height;
    }
    
    contentHeight -= self.contentInsets.top + self.contentInsets.bottom;
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,contentWidth,contentHeight)];
    self.contentView.autoresizingMask = 0;
    self.contentView.autoresizingMask = [self viewAutoresizingBasedOnDirection:self.direction staticHeight:staticHeight];
}

- (UIViewAutoresizing)viewAutoresizingBasedOnDirection:(MLFlyOverMenuDirection)direction staticHeight:(BOOL)staticHeight
{
    UIViewAutoresizing baseAutoresizingMask = (staticHeight) ? UIViewAutoresizingNone : UIViewAutoresizingFlexibleHeight;
    
    switch (self.direction) {
        case MLFlyOverMenuDirectionFromLeft:
            return baseAutoresizingMask | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            
        case MLFlyOverMenuDirectionFromRight:
            return baseAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            
        case MLFlyOverMenuDirectionFromTop:
            return baseAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            
        case MLFlyOverMenuDirectionFromBottom:
            return baseAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            
        default:
            return baseAutoresizingMask;
    }
}

- (void)placeContentViewToInitialPosition
{
    CGRect contentViewFrame = self.contentView.frame;
    CGSize screenSize = self.presentingViewController.view.bounds.size;
    
    screenSize.width -= self.contentInsets.left + self.contentInsets.right;
    screenSize.height -= self.contentInsets.top + self.contentInsets.bottom;
    
    CGFloat viewX = 0, viewY = 0;
    
    switch (self.direction) {
        case MLFlyOverMenuDirectionFromLeft:
            viewX = -contentViewFrame.size.width;
            viewY = screenSize.height / 2 - contentViewFrame.size.height / 2;
            break;
            
        case MLFlyOverMenuDirectionFromRight:
            viewX = screenSize.width;
            viewY = screenSize.height / 2 - contentViewFrame.size.height / 2;
            break;
            
        case MLFlyOverMenuDirectionFromTop:
            viewX = screenSize.width / 2 - contentViewFrame.size.width / 2;
            viewY = -contentViewFrame.size.height;
            break;
            
        case MLFlyOverMenuDirectionFromBottom:
            viewX = screenSize.width / 2 - contentViewFrame.size.width / 2;
            viewY = screenSize.height;
            break;
            
        default:
            break;
    }
    
    viewX += self.contentInsets.left + self.contentInsets.right;
    viewY += self.contentInsets.top + self.contentInsets.bottom;
    
    contentViewFrame.origin = CGPointMake(viewX, viewY);
    self.contentView.frame = contentViewFrame;
}

- (void)placeContentViewToTargetPosition
{
    CGRect contentViewFrame = self.contentView.frame;
    CGSize screenSize = self.presentingViewController.view.bounds.size;
    
    screenSize.width -= self.contentInsets.left + self.contentInsets.right;
    screenSize.height -= self.contentInsets.top + self.contentInsets.bottom;
    
    CGFloat viewX = 0, viewY = 0;
    
    switch (self.direction) {
        case MLFlyOverMenuDirectionFromLeft:
            viewX = 0;
            viewY = screenSize.height / 2 - contentViewFrame.size.height / 2;
            break;
            
        case MLFlyOverMenuDirectionFromRight:
            viewX = screenSize.width - contentViewFrame.size.width;
            viewY = screenSize.height / 2 - contentViewFrame.size.height / 2;
            break;
            
        case MLFlyOverMenuDirectionFromTop:
            viewX = screenSize.width / 2 - contentViewFrame.size.width / 2;
            viewY = 0;
            break;
            
        case MLFlyOverMenuDirectionFromBottom:
            viewX = screenSize.width / 2 - contentViewFrame.size.width / 2;
            viewY = screenSize.height - contentViewFrame.size.height;
            break;
            
        default:
            break;
    }
    
    viewX += self.contentInsets.left + self.contentInsets.right;
    viewY += self.contentInsets.top + self.contentInsets.bottom;
    
    contentViewFrame.origin = CGPointMake(viewX, viewY);
    self.contentView.frame = contentViewFrame;
}

- (void)deployViewController:(UIViewController *)viewController toHostViewController:(UIViewController *)hostViewController
{
    [hostViewController.view addSubview:self.contentView];
    
    [hostViewController addChildViewController:viewController];
    
    CGRect frame = self.contentView.bounds;
    
    UIView *controllerView = viewController.view;
    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    controllerView.frame = frame;
    
    if ([viewController respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        UIViewController *adjustViewController = viewController;
        
        if ([adjustViewController isKindOfClass:UINavigationController.class]) {
            adjustViewController = [(UINavigationController *)adjustViewController topViewController];
        }
        
        BOOL adjust = (BOOL)[adjustViewController performSelector:@selector(automaticallyAdjustsScrollViewInsets) withObject:nil];
        
        if (adjust) {
            CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
            CGFloat statusBarHeight = fminf(statusBarFrame.size.width, statusBarFrame.size.height);
            CGFloat adjustment = hostViewController.navigationController.navigationBar.frame.size.height + statusBarHeight;
            
            if ([adjustViewController.view isKindOfClass:UIScrollView.class]) {
                [(id)adjustViewController.view setContentInset:UIEdgeInsetsMake(adjustment, 0, 0, 0)];
            }
        }
    }
    
    [self.contentView addSubview:controllerView];
    
    [viewController didMoveToParentViewController:hostViewController];
}

- (void (^)(void))undeployViewController:(UIViewController *)viewController fromHostViewController:(UIViewController *)hostViewController
{
    [viewController willMoveToParentViewController:nil];
    
    void (^completionBlock)(void) = ^(void)
    {
        [self.contentViewController.view removeFromSuperview];
        
        [self.contentViewController removeFromParentViewController];
        
        self.presentingViewController = nil;
    };
    
    return completionBlock;
}

@end

#pragma mark - MLFlyOverMenuControllerPresentSegue Class

NSString * const MLFlyOverMenuPresentSegueLeftIdentifier = @"ml_from_left";
NSString * const MLFlyOverMenuPresentSegueRightIdentifier = @"ml_from_right";
NSString * const MLFlyOverMenuPresentSegueTopIdentifier = @"ml_from_top";
NSString * const MLFlyOverMenuPresentSegueBottomIdentifier = @"ml_from_bottom";

@implementation MLFlyOverMenuControllerPresentSegue : UIStoryboardSegue

- (void)perform
{
    UIViewController *presentingViewController = self.sourceViewController;
    UIViewController *contentViewController = self.destinationViewController;
    
    MLFlyOverMenuController *flyOver = [presentingViewController flyOverMenuController];
    
    if (flyOver.presentingViewController) {
        [flyOver dismissAnimated:YES];
    } else {
        MLFlyOverMenuDirection direction = MLFlyOverMenuDirectionFromLeft;
        
        if ([self.identifier isEqualToString:MLFlyOverMenuPresentSegueLeftIdentifier]) {
            direction = MLFlyOverMenuDirectionFromLeft;
        } else if ([self.identifier isEqualToString:MLFlyOverMenuPresentSegueRightIdentifier]) {
            direction = MLFlyOverMenuDirectionFromRight;
        } else if ([self.identifier isEqualToString:MLFlyOverMenuPresentSegueTopIdentifier]) {
            direction = MLFlyOverMenuDirectionFromTop;
        } else if ([self.identifier isEqualToString:MLFlyOverMenuPresentSegueBottomIdentifier]) {
            direction = MLFlyOverMenuDirectionFromBottom;
        }
        
        flyOver.contentViewController = contentViewController;
        
        [flyOver presentFlyOverMenuInViewController:presentingViewController
                                      withDirection:direction
                                           animated:YES];
    }
}

@end

#pragma mark - Categories

@implementation UIViewController (MLFlyOverMenuController)

- (MLFlyOverMenuController *)flyOverMenuController
{
    UIViewController *parent = self;
    
    MLFlyOverMenuController *flyOver = nil;
    
    Class flyOverMenuClass = [MLFlyOverMenuController class];
    
    do {
        flyOver = objc_getAssociatedObject(parent, &kFlyOverMenuControllerKey);
        
        if (flyOver && [flyOver isKindOfClass:flyOverMenuClass]) {
            break;
        }
    } while (nil != (parent = [parent parentViewController]));
    
    return flyOver;
}

- (void)setFlyOverMenuController:(MLFlyOverMenuController *)flyOverMenuController
{
    objc_setAssociatedObject(self, &kFlyOverMenuControllerKey, flyOverMenuController, OBJC_ASSOCIATION_ASSIGN);
}

- (NSNumber *)contentWidthInFlyOverMenu
{
    return objc_getAssociatedObject(self, &kFlyOverMenuControllerContentWidthKey);
}

- (void)setContentWidthInFlyOverMenu:(NSNumber *)contentWidthInFlyOverMenu
{
    objc_setAssociatedObject(self, &kFlyOverMenuControllerContentWidthKey, contentWidthInFlyOverMenu, OBJC_ASSOCIATION_COPY);
}

- (NSNumber *)contentHeightInFlyOverMenu
{
    return objc_getAssociatedObject(self, &kFlyOverMenuControllerContentHeightKey);
}

- (void)setContentHeightInFlyOverMenu:(NSNumber *)contentHeightInFlyOverMenu
{
    objc_setAssociatedObject(self, &kFlyOverMenuControllerContentHeightKey, contentHeightInFlyOverMenu, OBJC_ASSOCIATION_COPY);
}

@end

