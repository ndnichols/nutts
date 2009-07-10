	//
//  Logger.m
//  nutts
//
//  Created by Nathan Nichols on 6/30/09.
//  Copyright 2009 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import "Log.h"

void NULog (NSString *format, ...) {
    if (format == nil) {
        printf("nil");
        return;
    }
    // Get a reference to the arguments that follow the format parameter
    va_list argList;
    va_start(argList, format);
    // Perform format string argument substitution, reinstate %% escapes, then print
    NSMutableString *s = [[NSMutableString alloc] initWithFormat:format
                                                       arguments:argList];
    [s replaceOccurrencesOfString:@"%%"
                       withString:@"%%%%"
                          options:0
                            range:NSMakeRange(0, [s length])];
    printf("%s", [s UTF8String]);
    [s release];
    va_end(argList);
}

@implementation Logger

@end
