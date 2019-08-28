//
//  modalWebViewController.h
//  Forge
//
//  Created by Connor Dunn on 27/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "tabs_ToolBar.h"

@interface tabs_UIWebViewController : UIViewController <UIWebViewDelegate, UIBarPositioningDelegate> {
    //UIViewController *rootView;

    UIStatusBarStyle statusBarStyle;
    UIStatusBarStyle savedStatusBarStyle;

    IBOutlet UINavigationBar *navigationBar;
    UINavigationItem *navigationItem;
    bool opaqueTopBar;
    UIColor *tint;
    UIColor *titleTint;
    NSString *title;

    UIView *blurView;
    UIVisualEffectView *blurViewVisualEffect;
    NSLayoutConstraint *blurViewBottomConstraint;
    NSLayoutConstraint *navBarTopConstraint;

    IBOutlet UIBarButtonItem *backButton;
    NSString *backLabel;
    NSString *backImage;
    UIColor *buttonTint;

    tabs_ToolBar *navigationToolbar;

	NSURL *url;
    NSString *retryUrl;
	ForgeTask *task;
	NSString *pattern;
	NSDictionary *returnObj;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (strong, nonatomic) NSNumber *scalePagesToFit;
@property (strong, nonatomic) NSNumber *enableNavigationToolbar;
@property (strong, nonatomic) NSNumber *enableBasicAuth;
@property (strong, nonatomic) NSNumber *enableInsecureBasicAuth;

- (void)setUrl:(NSURL*)newUrl;
//- (void)setRootView:(UIViewController*)newRootView;

- (void)setBackLabel:(NSString *)newLabel;
- (void)setBackImage:(NSString *)newImage;
- (void)setButtonTintColor:(UIColor *)newTint;

- (void)setTitle:(NSString *)newTitle;
- (void)setTitleTintColor:(UIColor *)newTint;
- (void)setTintColor:(UIColor *)newTint;

- (void)setOpaqueTopBar:(bool)newTranslucent;
- (void)setStatusBarStyle:(UIStatusBarStyle)newStatusBarStyle;
- (void)setNavigationToolbarHidden:(BOOL)hidden;

- (void)setTask:(ForgeTask *)newTask;
- (ForgeTask*)getTask;
- (void)setReturnObj:(NSDictionary *)newReturnObj;
- (void)setPattern:(NSString *)newPattern;
- (BOOL)matchesPattern:(NSURL *)urlToCheck;
- (void)cancel:(id)nothing;
- (void)stringByEvaluatingJavaScriptFromString:(ForgeTask*)evalTask string:(NSString*)string;
- (void)close;

- (void)addButtonWithTask:(ForgeTask*)newTask text:(NSString*)newText icon:(NSString*)newIcon position:(NSString*)newPosition style:(NSString*)newStyle tint:(UIColor*)newTint;
- (void)removeButtonsWithTask:(ForgeTask*)newTask;
- (void)setTitleWithTask:(ForgeTask*)newTask title:(NSString*)title;

- (void) forceUpdateWebView;
@end
