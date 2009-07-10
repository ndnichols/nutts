//
//  TTS.h
//  nutts
//
//  Created by Nathan Nichols on 6/30/09.
//  Copyright 2009 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <unistd.h>
#import <sys/stat.h>
#import <fcntl.h>

@interface TTS : NSObject {
    NSString *voice;
    NSString *outputFile;
    NSString *text;
    NSArray *phonemeOpcodes;
    NSUInteger voiceIndex;
    SpeechChannel speechChannel;
    BOOL speaking;
    NSMutableArray *logs;
}

-(id)initWithVoiceNamed:(NSString *)voice outputFile:(NSString *)outputFile;
-(void)speakText:(NSString *)text;
-(NSMutableArray *)voices;

-(void) onSpeechDone;

@end
