#import "TMViewController.h"

#import "TMAERecorder.h"
#import "TMAssembly.h"
#import "TMAudioFilterReverb.h"
#import "TUFileManager.h"

#import <Typhoon/TyphoonBlockComponentFactory.h>
#import <AVFoundation/AVFoundation.h>

@interface TMViewController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) id<TMAERecorderProvider> AERecorderProvider;
@property (strong, nonatomic) TMAERecorder *AERecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) TMAudioFilterReverb *reverbFilter;

@property (nonatomic, strong) id<TUFileManager> fileManager;

@property (strong, nonatomic, readonly) NSURL *recordedAudioURL;
@property (strong, nonatomic, readonly) NSDictionary *recordSettings;

@property (weak, nonatomic) IBOutlet UIButton *record;
@property (weak, nonatomic) IBOutlet UIButton *stop;
@property (weak, nonatomic) IBOutlet UIButton *play;

@end

@implementation TMViewController

@synthesize recordedAudioURL = _recordedAudioURL;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        TMAssembly* componentFactory = (TMAssembly *)[[TyphoonBlockComponentFactory alloc] initWithAssembly:[TMAssembly assembly]];
        _AERecorderProvider = [componentFactory AERecorder];
        _fileManager =  [(TMAssembly *)componentFactory fileManager];

        _reverbFilter = [[TMAudioFilterReverb alloc] init];
    }
    return self;
}

#pragma mark - Audio recording

- (IBAction)record:(id)sender
{
    [self buttonsEnabledRecord:NO stop:YES play:NO];

    NSString *recordedAudioPath = [self.recordedAudioURL path];
    if([self.fileManager fileExistsAtPath:recordedAudioPath])
    {
        NSError *errorDeletingPreviousFile;
        [self.fileManager removeItemAtPath:recordedAudioPath error:&errorDeletingPreviousFile];
        NSAssert(!errorDeletingPreviousFile, @"%@", errorDeletingPreviousFile);
    }

    NSError *errorRecordingAudio;
    self.AERecorder = [self.AERecorderProvider audioRecorderWithURL:self.recordedAudioURL
                                                           settings:self.recordSettings
                                                              error:&errorRecordingAudio];
    NSAssert(!errorRecordingAudio, @"%@", errorRecordingAudio);

    self.AERecorder.audioFilter = self.reverbFilter;

    [self.AERecorder record];
}

- (NSURL *)recordedAudioURL
{
    if (!_recordedAudioURL)
    {
        NSString *temporaryDirectory = NSTemporaryDirectory();

        NSString *globallyUniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString *filename = [NSString stringWithFormat:@"audio_%@.%@", globallyUniqueString, @"mp4"];

        NSString *filePath = [temporaryDirectory stringByAppendingPathComponent:filename];

        _recordedAudioURL = [NSURL fileURLWithPath:filePath];
    }
    return _recordedAudioURL;
}

- (NSDictionary *)recordSettings
{
    return (@{
              AVFormatIDKey : @(kAudioFormatMPEG4AAC),
              AVSampleRateKey : @(8000),
              AVEncoderBitRateKey : @(16000),
              AVNumberOfChannelsKey : @(1),
              });
}

#pragma mark - Stopping audio recording

- (IBAction)stopRecording:(id)sender
{
    [self buttonsEnabledRecord:YES stop:NO play:YES];

    [self.AERecorder stop];
}

#pragma mark - Playing of recorded audio

- (IBAction)playRecordedAudio:(id)sender
{
    [self buttonsEnabledRecord:NO stop:NO play:NO];

    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedAudioURL
                                                              error:&error];
    self.audioPlayer.delegate = self;
    NSAssert(!error, @"%@", error);

    [self.audioPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self buttonsEnabledRecord:YES stop:NO play:YES];
}

#pragma mark - Convenience methods

- (void)buttonsEnabledRecord:(BOOL)recordEnabled stop:(BOOL)stopEnabled play:(BOOL)playEnabled
{
    self.record.enabled = recordEnabled;
    self.stop.enabled = stopEnabled;
    self.play.enabled = playEnabled;
}

@end
