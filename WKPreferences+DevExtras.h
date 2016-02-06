//
//  NSObject_WKPreferences_DevExtras.h
//  Messenger
//
//  Created by TeamiHackify on February 6 2016.
//

#import <Foundation/Foundation.h>

@import WebKit;

@interface WKPreferences (DevExtras)

@property (nonatomic, setter=_setDeveloperExtrasEnabled:) BOOL _developerExtrasEnabled;

- (void)enableDevExtras;

@end