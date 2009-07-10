#import <Foundation/Foundation.h>
#import "TTS.h"
#import "Log.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSString *text = @"Hello, world!";
    NSString *voice = @"Alex";
    NSString *outputFile = nil;
    BOOL outputIsNext = NO;
    BOOL voiceIsNext = NO;
    BOOL printVoices = NO;
    BOOL printHelp = NO;
    
    for (int i = 1; i < argc; i++) {
        NSString *arg = [NSString stringWithCString: argv[i] encoding:NSUTF8StringEncoding];
        if (voiceIsNext) {
            voice = arg;
            voiceIsNext = NO;
        }
        else if (outputIsNext) {
            outputFile = arg;
            outputFile = NO;
        }
        else if ([arg isEqualToString:@"-v"]) {
            voiceIsNext = YES;
        }
        else if ([arg isEqualToString:@"-o"]) {
            outputIsNext = YES;
        }
        else if ([arg isEqualToString:@"--voices"]) {
            printVoices = YES;
        }
        else if ([arg isEqualToString:@"--help"]) {
            printHelp = YES;
        }
        else if (i == argc-1) {
            text = arg;
        }
        else {
            NSCAssert1(NO, @"You passed in a bad argument!  Arg was %@  Remember, this is a stupid commandline parser!", arg);
        }
    }
    
    TTS *tts = [[TTS alloc] initWithVoiceNamed:voice outputFile:outputFile];
    NSCAssert1(tts, @"I don't know the voice %@!  Run nutts --voices to get a list of the voices I know, or don't specify a voice to get Alex.", voice);

    if (printVoices) {
        NSLog(@"Available voices:");
        for (NSString *voice in tts.voices) {
            NSLog(voice);
        }
    }
    
    if (text) {
        [tts speakText:text];
    }
    [pool drain];
    return 0;
}
