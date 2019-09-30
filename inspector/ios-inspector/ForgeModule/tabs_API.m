//
//  tabs_API.m
//  Forge
//
//  Created by Connor Dunn on 14/03/2012.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import "tabs_API.h"
#import "tabs_modalWebViewController.h"

static NSMutableDictionary<NSString*, NSValue*> *tabs_modal_map;

@implementation tabs_API

+ (void)open:(ForgeTask*)task {
    if (![task.params objectForKey:@"url"]) {
        [task error:@"Missing url" type:@"BAD_INPUT" subtype:nil];
        return;
    }

    tabs_modalWebViewController *modalView = [[tabs_modalWebViewController alloc] initWithNibName:@"tabs_modalWebViewController"
                 bundle:[NSBundle bundleWithPath:[[NSBundle mainBundle]
        pathForResource:@"tabs"
                 ofType:@"bundle"]]];

    [modalView setUrl:[NSURL URLWithString:[task.params objectForKey:@"url"]]];
    [modalView setPattern:[task.params objectForKey:@"pattern"]];
    [modalView setRootView:[[ForgeApp sharedApp] viewController]];

    if ([task.params objectForKey:@"title"] != nil) {
        [modalView setTitle:[task.params objectForKey:@"title"]];
    } else {
        [modalView setTitle:@""];
    }

    if ([task.params objectForKey:@"buttonIcon"] != nil) {
        [modalView setBackImage:[task.params objectForKey:@"buttonIcon"]];
    } else if ([task.params objectForKey:@"buttonText"] != nil) {
        [modalView setBackLabel:[task.params objectForKey:@"buttonText"]];
    } else {
        [modalView setBackLabel:@"Close"];
    }

    if ([task.params objectForKey:@"tint"] != nil) {
        NSArray* color = [task.params objectForKey:@"tint"];
        [modalView setTintColor:[UIColor colorWithRed:[(NSNumber*)[color objectAtIndex:0] floatValue]/255
                                                green:[(NSNumber*)[color objectAtIndex:1] floatValue]/255
                                                 blue:[(NSNumber*)[color objectAtIndex:2] floatValue]/255
                                                alpha:[(NSNumber*)[color objectAtIndex:3] floatValue]/255]];
    }

    if ([task.params objectForKey:@"titleTint"] != nil) {
        NSArray* color = [task.params objectForKey:@"titleTint"];
        [modalView setTitleTintColor:[UIColor colorWithRed:[(NSNumber*)[color objectAtIndex:0] floatValue]/255
                                                     green:[(NSNumber*)[color objectAtIndex:1] floatValue]/255
                                                      blue:[(NSNumber*)[color objectAtIndex:2] floatValue]/255
                                                     alpha:[(NSNumber*)[color objectAtIndex:3] floatValue]/255]];
    }

    if ([task.params objectForKey:@"buttonTint"] != nil) {
        NSArray* color = [task.params objectForKey:@"buttonTint"];
        [modalView setButtonTintColor:[UIColor colorWithRed:[(NSNumber*)[color objectAtIndex:0] floatValue]/255
                                                      green:[(NSNumber*)[color objectAtIndex:1] floatValue]/255
                                                       blue:[(NSNumber*)[color objectAtIndex:2] floatValue]/255
                                                      alpha:[(NSNumber*)[color objectAtIndex:3] floatValue]/255]];
    }

    if ([task.params objectForKey:@"opaqueTopBar"] != nil) {
        [modalView setOpaqueTopBar:[[task.params objectForKey:@"opaqueTopBar"] boolValue]];
    } else {
        [modalView setOpaqueTopBar:false];
    }

    if (([task.params objectForKey:@"statusBarStyle"] != nil) &&
        ([[task.params objectForKey:@"statusBarStyle"] isEqualToString:@"light_content"])) {
        [modalView setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        [modalView setStatusBarStyle:UIStatusBarStyleDefault];
    }

    // status bar options
    if (([task.params objectForKey:@"statusBarStyle"] != nil) &&
        ([[task.params objectForKey:@"statusBarStyle"] isEqualToString:@"light_content"])) {
            [modalView setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        [modalView setStatusBarStyle:UIStatusBarStyleDefault];
    }

    // scaling options
    if ([task.params objectForKey:@"scalePagesToFit"] != nil) {
        modalView.scalePagesToFit = [NSNumber numberWithBool:[[task.params objectForKey:@"scalePagesToFit"] boolValue]];
    } else {
        modalView.scalePagesToFit = [NSNumber numberWithBool:NO];
    }

    // navigation toolbar options
    if ([task.params objectForKey:@"navigationToolbar"] != nil) {
        modalView.enableNavigationToolbar = [NSNumber numberWithBool:[[task.params objectForKey:@"navigationToolbar"] boolValue]];
    } else {
        modalView.enableNavigationToolbar = [NSNumber numberWithBool:NO];
    }

    // basic auth options
    if ([task.params objectForKey:@"basicAuth"] != nil) {
        modalView.enableBasicAuth = [NSNumber numberWithBool:[[task.params objectForKey:@"basicAuth"] boolValue]];
    } else {
        modalView.enableBasicAuth = [NSNumber numberWithBool:NO];
    }

    NSDictionary *basicAuthConfig = [task.params objectForKey:@"basicAuthConfig"];
    if (basicAuthConfig != nil && [basicAuthConfig objectForKey:@"insecure"] != nil) {
        modalView.enableInsecureBasicAuth = [NSNumber numberWithBool:[[basicAuthConfig objectForKey:@"insecure"] boolValue]];
    } else {
        modalView.enableInsecureBasicAuth = [NSNumber numberWithBool:NO];;
    }

    [modalView setTask:task];

    [[[ForgeApp sharedApp] viewController] presentViewController:modalView animated:YES completion:nil];

    [task success:task.callid];

    if (tabs_modal_map == nil) {
        tabs_modal_map = [[NSMutableDictionary alloc] init];
    }
    [tabs_modal_map setObject:[NSValue valueWithNonretainedObject:modalView] forKey:task.callid];
    modalView.releaseHandler = ^{
        [ForgeLog d:[NSString stringWithFormat:@"Deleting tab with callid:%@ url:%@", task.callid, task.params[@"url"]]];
        tabs_modal_map[task.callid] = nil;
    };
}


+ (void)executeJS:(ForgeTask*)task modal:(NSString*)modal script:(NSString*)script {
    NSValue *value = [tabs_modal_map objectForKey:modal];
    
    if (value == nil) {
        [task error:[NSString stringWithFormat:@"No tab found with callid: %@", modal]];
        return;
    }
    
    tabs_modalWebViewController *viewController = [value nonretainedObjectValue];

    [viewController stringByEvaluatingJavaScriptFromString:task string:script];
}


+ (void)close:(ForgeTask*)task modal:(NSString*)modal {
    NSValue *value = [tabs_modal_map objectForKey:modal];
    
    if (value == nil) {
        [task error:[NSString stringWithFormat:@"No tab found with callid: %@", modal]];
        return;
    }
    
    tabs_modalWebViewController *viewController = [value nonretainedObjectValue];

    [viewController close];
    [task success:nil];
}


+ (void)addButton:(ForgeTask*)task modal:(NSString*)modal params:(NSDictionary*)params {
    NSValue *value = [tabs_modal_map objectForKey:modal];
    
    if (value == nil) {
        [task error:[NSString stringWithFormat:@"No tab found with callid: %@", modal]];
        return;
    }
    
    tabs_modalWebViewController *viewController = [value nonretainedObjectValue];

    
    NSString* text = nil;
    NSString* icon = nil;
    NSString* position = nil;
    NSString* style = nil;
    UIColor*  tint = nil;
    
    if ([params objectForKey:@"text"] != nil) {
        text = [params objectForKey:@"text"];
    }
    if ([params objectForKey:@"icon"] != nil) {
        icon = [params objectForKey:@"icon"];
    }
    if ([params objectForKey:@"position"] != nil) {
        position = [params objectForKey:@"position"];
    }
    if ([params objectForKey:@"style"] != nil) {
        style = [params objectForKey:@"style"];
    }
    if ([params objectForKey:@"tint"] != nil) {
        NSArray* array = [params objectForKey:@"tint"];
        tint = [UIColor colorWithRed:[(NSNumber*)[array objectAtIndex:0] floatValue]/255
                               green:[(NSNumber*)[array objectAtIndex:1] floatValue]/255
                                blue:[(NSNumber*)[array objectAtIndex:2] floatValue]/255
                               alpha:[(NSNumber*)[array objectAtIndex:3] floatValue]/255];
    }

    [viewController addButtonWithTask:task text:text icon:icon position:position style:style tint:tint];
}


+ (void)removeButtons:(ForgeTask*)task modal:(NSString*)modal {
    NSValue *value = [tabs_modal_map objectForKey:modal];
    
    if (value == nil) {
        [task error:[NSString stringWithFormat:@"No tab found with callid: %@", modal]];
        return;
    }
    
    tabs_modalWebViewController *viewController = [value nonretainedObjectValue];

    [viewController removeButtonsWithTask:task];
}


+ (void)setTitle:(ForgeTask*)task modal:(NSString*)modal title:(NSString*)title {
    NSValue *value = [tabs_modal_map objectForKey:modal];
    
    if (value == nil) {
        [task error:[NSString stringWithFormat:@"No tab found with callid: %@", modal]];
        return;
    }
    
    tabs_modalWebViewController *viewController = [value nonretainedObjectValue];

    [viewController setTitleWithTask:task title:title];
}

@end
