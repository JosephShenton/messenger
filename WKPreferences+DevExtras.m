//  Copyright (c) 2016 TeamiHackify. All rights reserved.

#import "WKPreferences+DevExtras.h"

@implementation WKPreferences (DevExtras)

@dynamic _developerExtrasEnabled;

- (void)enableDevExtras {
    [self _setDeveloperExtrasEnabled:YES];
}

@end