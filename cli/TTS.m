//
//  TTS.m
//  nutts
//
//  Created by Nathan Nichols on 6/30/09.
//  Copyright 2009 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import "TTS.h"
#import "Log.h"


static pascal void	OurSpeechDoneCallBackProc(SpeechChannel inSpeechChannel, long inRefCon);
static pascal void	OurWordCallBackProc(SpeechChannel inSpeechChannel, long inRefCon, long inWordPos, short inWordLen);
static pascal void  OurSpeechPhonemeProc(SpeechChannel inSpeechChannel, long inRefCon, short phonemeOpcode);

@implementation TTS

-(id)initWithVoiceNamed:(NSString *)aVoice outputFile:(NSString *)anOutputFile {
    if (self = [super init]) {
        speaking = NO;
        phonemeOpcodes = [[@"% @ ae ey ao ax iy eh ih ay ix aa uw uh ux ow aw oy b c d d f g h j k l m n n p r s s t t v w y z z" componentsSeparatedByString:@" "] retain];
        logs = [[NSMutableArray alloc] init];
        voice = [aVoice retain];
        outputFile = [anOutputFile retain];
        voiceIndex = [self.voices indexOfObject:voice];
        voiceIndex++; //Hooray for 1-indexing
        if (voiceIndex == NSNotFound) {
            return nil;
        }
    }
    return self;
}

-(NSMutableArray *)voices {
    NSMutableArray *voices = [NSMutableArray array];
    OSErr err;
    short voiceCount;
    err = CountVoices(&voiceCount);
    NSAssert1(err == noErr, @"Died, err is %h", err);
    VoiceDescription voiceDescription;
    VoiceSpec voiceSpec;
    for (int i = 1; i < voiceCount; i++) {
        GetIndVoice(i, &voiceSpec);
        GetVoiceDescription(&voiceSpec, &voiceDescription, sizeof(voiceDescription));
        // NSString *aVoice = [NSString stringWithCString: (char *) &(voiceDescription.name[1]) encoding:NSASCIIStringEncoding];
        NSString *aVoice = [[NSString alloc] initWithBytes:(char *) &(voiceDescription.name[1]) \
                                                    length:voiceDescription.name[0] \
                                                    encoding:NSUTF8StringEncoding];
        [voices addObject:aVoice];
        [aVoice release];
    }
    
    return voices;
}

-(void)setupSpeechChannel {
    OSErr err;
    VoiceSpec voiceSpec;
    err = GetIndVoice(voiceIndex, &voiceSpec);
    NSAssert1(err == noErr, @"Died, err is %h", err);
    err = NewSpeechChannel(&voiceSpec, &speechChannel);
    NSAssert1(err == noErr, @"Died, err is %h", err);
    err = SetSpeechInfo(speechChannel, soRefCon, (Ptr)self);
    NSAssert1(err == noErr, @"Died, err is %h", err);
    err = SetSpeechInfo(speechChannel, soOutputToFileWithCFURL, NULL);
    NSAssert1(err == noErr, @"Died, err is %h", err);
    err = SetSpeechInfo(speechChannel, soSpeechDoneCallBack, OurSpeechDoneCallBackProc);
    NSAssert1(err == noErr, @"Died, err is %h", err);
    err = SetSpeechInfo(speechChannel, soWordCallBack, OurWordCallBackProc);
    NSAssert1(err == noErr, @"Died, err is %h", err);
    err = SetSpeechInfo(speechChannel, soPhonemeCallBack, OurSpeechPhonemeProc);
    NSAssert1(err == noErr, @"Died, err is %h", err);
}


-(void)speakText:(NSString *)aText {
    text = [aText retain];
    [self setupSpeechChannel];
    const char *cString = [text cStringUsingEncoding:NSUTF8StringEncoding];
    NSAssert1(cString != NULL, @"Couldn't convert %@ to the C Form to make SpeechSynthesizer happy!", text);
    speaking = true; //the speechdonecallback turns this off
    SpeakText(speechChannel, cString, [text length]);
    while (speaking)
    {
        [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}

-(void)onSpeechDone {
    speaking = false;
    // NSLog(@"Logs:");
    // for (NSArray *arr in logs) {
    //     NSLog(@"At %@, %@", [arr objectAtIndex:0], [arr objectAtIndex:1]);
    //     // NSLog(log);
    // }
}

-(void)log:(NSString *)intro {
    Fixed _rate;
    GetSpeechInfo(speechChannel, soRate, &_rate);
    float fRate = FixedToFloat(_rate);
    
    Fixed _pitchBase;
    GetSpeechInfo(speechChannel, soPitchBase, &_pitchBase);
    float fPitchBase = FixedToFloat(_pitchBase);
    
    Fixed _pitchMod;
    GetSpeechInfo(speechChannel, soPitchMod, &_pitchMod);
    float fPitchMod = FixedToFloat(_pitchMod);
    
    Fixed _volume;
    GetSpeechInfo(speechChannel, soVolume, &_volume);
    float fVolume = FixedToFloat(_volume);
    
    NSString *info = [NSString stringWithFormat:@"Volume: %.2f Rate: %.2f PitchBase: %.2f PitchMod: %.2f", fVolume, fRate, fPitchBase, fPitchMod];
    
    NSString *toLog = [NSString stringWithFormat:@"%@ -- %@\n", intro, info];
    // printf([toLog cStringUsingEncoding:NSASCIIStringEncoding]);
    // NSLog(intro);
    //  NSLog(info);
    NULog(toLog);
    
}

-(void)onWordWithRange:(NSRange) range {
    NSString *toLog = [NSString stringWithFormat:@"WORD %@", [text substringWithRange:range]];
    
    // [logs addObject:[NSArray arrayWithObjects:[NSDate date], log, nil]];
    // NSLog(log);
    [self log:toLog];
}

-(void)onPhoneme:(short) opcode {
    NSString *phoneme = [phonemeOpcodes objectAtIndex:opcode];
    if ([phoneme isEqualToString:@"%"]) {
        phoneme = @"%%";
    }
    // NSLog(@"Early phoneme is %@, and its length is %i", phoneme, [phoneme length]);
    NSString *toLog = [NSString stringWithFormat:@"PHONEME %@", phoneme];//[phonemeOpcodes objectAtIndex:opcode]];
    // [logs addObject:[NSArray arrayWithObjects:[NSDate date], log, nil]];
    // NSLog(toLog);
    [self log:toLog];
}


@end

pascal void OurSpeechDoneCallBackProc(SpeechChannel inSpeechChannel, long inRefCon) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [(TTS *) inRefCon onSpeechDone];
	[pool drain];
}

pascal void OurWordCallBackProc(SpeechChannel inSpeechChannel, long inRefCon, long inWordPos, short inWordLen) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [(TTS *) inRefCon onWordWithRange:NSMakeRange(inWordPos, inWordLen)];
	[pool drain];
}

pascal void  OurSpeechPhonemeProc(SpeechChannel inSpeechChannel, long inRefCon, short phonemeOpcode) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [(TTS *) inRefCon onPhoneme:phonemeOpcode];
    [pool drain];
}
