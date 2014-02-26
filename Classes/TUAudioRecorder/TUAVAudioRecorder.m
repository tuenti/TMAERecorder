//
//  TUAVAudioRecorder.m
//  TMAERecorder
//
//  Copyright (c) 2014 Tuenti Technologies S.L. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TUAVAudioRecorder.h"

@interface TUAVAudioRecorder () <AVAudioRecorderDelegate>

@end

@implementation TUAVAudioRecorder

@synthesize delegate = _delegate;

- (id)initWithURL:(NSURL *)url settings:(NSDictionary *)settings error:(NSError *__autoreleasing *)outError
{
    self = [super init];
    if (self)
	{
		_audioRecorder = [[AVAudioRecorder alloc] initWithURL:url
													 settings:settings
														error:outError];
    }
    return self;
}

- (void)dealloc
{
    _audioRecorder.delegate = nil;
}

- (NSDictionary *)settings
{
	return self.audioRecorder.settings;
}

- (BOOL)isMeteringEnabled
{
	return self.audioRecorder.meteringEnabled;
}

- (void)setMeteringEnabled:(BOOL)meteringEnabled
{
	self.audioRecorder.meteringEnabled = meteringEnabled;
}

- (NSTimeInterval)currentTime
{
	return self.audioRecorder.currentTime;
}

- (BOOL)isRecording
{
	return self.audioRecorder.recording;
}

- (BOOL)prepareToRecord
{
	return [self.audioRecorder prepareToRecord];
}

- (BOOL)record
{
	return [self.audioRecorder record];
}

- (void)stop
{
	[self.audioRecorder stop];
}

- (BOOL)deleteRecording
{
	return [self.audioRecorder deleteRecording];
}

- (void)updateMeters
{
	[self.audioRecorder updateMeters];
}

- (float)averagePowerForChannel:(NSUInteger)channelNumber
{
	return [self.audioRecorder averagePowerForChannel:channelNumber];
}

#pragma mark - AVAudioRecorderDelegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	if ([self.delegate respondsToSelector:@selector(audioRecorderDidFinishRecording:successfully:)])
	{
		[self.delegate audioRecorderDidFinishRecording:self successfully:flag];
	}
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
	if ([self.delegate respondsToSelector:@selector(audioRecorderEncodeErrorDidOccur:error:)])
	{
		[self.delegate audioRecorderEncodeErrorDidOccur:self error:error];
	}
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
	if ([self.delegate respondsToSelector:@selector(audioRecorderEndInterruption:withOptions:)])
	{
		[self.delegate audioRecorderEndInterruption:self withOptions:flags];
	}
}

@end
