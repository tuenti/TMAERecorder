//
//  TMAERecorder.m
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

#import "TMAERecorder.h"

#import "AEAudioController.h"
#import "AEMixerBuffer.h"
#import "AEAudioFileWriter.h"
#import "AEAudioFileLoaderOperation.h"
#import "TUNSFileManager.h"

#include "AEUtilities.h"

#import "TMAudioFilter.h"

#import <AVFoundation/AVAudioSettings.h>

static NSUInteger const kProcessChunkSize = 8192;

@interface TMAERecorder () <AEAudioReceiver>

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEMixerBuffer *mixerBuffer;

@property (nonatomic, assign) AudioBufferList *audioBufferList;

@property (nonatomic, copy) NSString *outputPath;
@property (nonatomic, assign) ExtAudioFileRef outputAudioFile;

@property(readwrite) NSTimeInterval currentTime;
@property (nonatomic, assign) float averagePowerInDB;
@property (nonatomic, assign) float peakHoldLevel;

@property (nonatomic, assign) Float64 sampleRate;

@property (nonatomic, assign, getter = isPreparedToRecord) BOOL preparedToRecord;
@property(readwrite, getter=isRecording) BOOL recording;

@end

@implementation TMAERecorder

@synthesize
settings = _settings,
meteringEnabled = _meteringEnabled,
delegate = _delegate;

#pragma mark - Initialization and deallocation

- (instancetype)initWithAudioControllerProvider:(id<TMAudioControllerProvider>)audioControllerProvider
							mixerBufferProvider:(id<TMMixerBufferProvider>)mixerBufferProvider
									fileManager:(id<TUFileManager>)fileManager
											URL:(NSURL *)url
									   settings:(NSDictionary *)settings
{
    if (self = [super init])
	{
		NSParameterAssert(audioControllerProvider);
		NSParameterAssert(mixerBufferProvider);
		NSParameterAssert(fileManager);

        _audioControllerProvider = audioControllerProvider;
        _mixerBufferProvider = mixerBufferProvider;
        _fileManager = fileManager;

		_outputPath = [[url path] copy];
		_settings = settings;
	}
    return self;

}

- (void)dealloc
{
	if (_recording) [self stop];
}

- (void)setUp
{
    AudioStreamBasicDescription inputAudioDescription;
    memset(&inputAudioDescription, 0, sizeof(inputAudioDescription));
    inputAudioDescription.mFormatID          = kAudioFormatLinearPCM;
    inputAudioDescription.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    inputAudioDescription.mChannelsPerFrame  = 1;
    inputAudioDescription.mBytesPerPacket    = sizeof(AudioUnitSampleType);
    inputAudioDescription.mFramesPerPacket   = 1;
    inputAudioDescription.mBytesPerFrame     = sizeof(AudioUnitSampleType);
    inputAudioDescription.mBitsPerChannel    = 8 * sizeof(AudioUnitSampleType);
    inputAudioDescription.mSampleRate        = 44100.0;

	_audioController = [_audioControllerProvider audioControllerWithAudioDescription:inputAudioDescription
																		inputEnabled:YES];
	[_audioController addOutputReceiver:self];
	[_audioController addInputReceiver:self];

	_sampleRate = _audioController.audioDescription.mSampleRate;

	_mixerBuffer = [_mixerBufferProvider mixerBufferProviderWithClientFormat:inputAudioDescription];
}

- (void)tearDown
{
	[_audioController stop];
	[_audioController removeOutputReceiver:self];
	[_audioController removeInputReceiver:self];

	_mixerBuffer = nil;
}

#pragma mark - Audio callback

- (AEAudioControllerAudioCallback)receiverCallback
{
    return audioCallback;
}

static void audioCallback(__unsafe_unretained id receiver,
                          __unsafe_unretained AEAudioController *audioController,
                          void *source,
                          const AudioTimeStamp *time,
                          UInt32 frames,
                          AudioBufferList *audio)
{
	/*
	 Instance variables are accessed via the C struct dereference operator
	 as you should avoid making Objective-C calls in a Core Audio
	 realtime thread, including accessing properties via dot notation,
	 because this will cause performance problems.
	 */
    TMAERecorder *self = receiver;
    if (!self->_recording) return;

    AEMixerBufferEnqueue(self->_mixerBuffer, source, audio, frames, time);

    UInt32 audioBufferListLength = kProcessChunkSize;
    for (NSUInteger i = 0; i < self->_audioBufferList->mNumberBuffers; i++)
	{
        self->_audioBufferList->mBuffers[i].mData = NULL;
        self->_audioBufferList->mBuffers[i].mDataByteSize = 0;
    }

    AEMixerBufferDequeue(self->_mixerBuffer,
						 self->_audioBufferList,
						 &audioBufferListLength,
						 NULL);

    if (audioBufferListLength > 0)
	{
		ExtAudioFileWriteAsync(self->_outputAudioFile,
							   audioBufferListLength,
							   self->_audioBufferList);
    }

    self->_currentTime += (frames / self->_sampleRate / 2.0);
}

#pragma mark - Metering

- (void)updateMeters
{
	[self.audioController inputAveragePowerLevel:&_averagePowerInDB
								   peakHoldLevel:&_peakHoldLevel];
}

- (float)averagePowerForChannel:(NSUInteger)channelNumber
{
	return self.averagePowerInDB;
}

#pragma mark - Recording management

- (BOOL)prepareToRecord
{
    _currentTime = 0.0;

	[self setUp];
	BOOL result = [self.audioController start:NULL];

	if (result)
	{
		self.audioFilter.audioController = self.audioController;
		[self.audioFilter apply];

		_outputAudioFile = [self newOutputAudioFile];

		_audioBufferList = AEAllocateAndInitAudioBufferList(self.audioController.audioDescription, 0);
	}
	else
	{
		[self tearDown];
	}

	self.preparedToRecord = result;

    return result;
}

- (BOOL)record
{
	if (![self isPreparedToRecord])
	{
		[self prepareToRecord];
	}
	_recording = self.preparedToRecord;

	return _recording;
}

- (void)stop
{
	if (!self.recording) return;
	self.recording = NO;

	[self.audioFilter remove];

	[self closeOutputFile];
	[self.audioController stop];

	[self tearDown];

	free(_audioBufferList);
}

#pragma mark - Encoding output file

- (void)closeOutputFile
{
	ExtAudioFileDispose(self.outputAudioFile);
}

- (AudioStreamBasicDescription)outputAudioFormat
{
	AudioStreamBasicDescription outputAudioFormat;
	memset(&outputAudioFormat, 0, sizeof(outputAudioFormat));
	outputAudioFormat.mFormatID = kAudioFormatMPEG4AAC;
	outputAudioFormat.mChannelsPerFrame = [self.settings[AVNumberOfChannelsKey] unsignedIntegerValue];
	outputAudioFormat.mSampleRate = [self.settings[AVSampleRateKey] floatValue];
	UInt32 outputAudioDescriptionSize = sizeof(outputAudioFormat);

	AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
						   0,
						   NULL,
						   &outputAudioDescriptionSize,
						   &outputAudioFormat);

	return outputAudioFormat;
}

- (ExtAudioFileRef)newOutputAudioFile
{
	AudioStreamBasicDescription outputAudioFormat = [self outputAudioFormat];
	CFURLRef outputFileURL = CFBridgingRetain([NSURL fileURLWithPath:self.outputPath]);

	ExtAudioFileRef audioFile;
	ExtAudioFileCreateWithURL(outputFileURL,
							  kAudioFileM4AType,
							  &outputAudioFormat,
							  NULL,
							  kAudioFileFlags_EraseFile,
							  &audioFile);
	CFRelease(outputFileURL);

	UInt32 codecManfacturer = kAppleSoftwareAudioCodecManufacturer;
	ExtAudioFileSetProperty(audioFile,
							kExtAudioFileProperty_CodecManufacturer,
							sizeof(codecManfacturer),
							&codecManfacturer);

	AudioStreamBasicDescription inputAudioFormat = self.audioController.audioDescription;
	ExtAudioFileSetProperty(audioFile,
							kExtAudioFileProperty_ClientDataFormat,
							sizeof(inputAudioFormat),
							&inputAudioFormat);

	return audioFile;
}

#pragma mark - Recording deletion

- (BOOL)deleteRecording
{
	if ([self isRecording] || ![self outputFileExists]) return NO;

	NSError *error;
	[self.fileManager removeItemAtPath:self.outputPath
								 error:&error];

	return (error == nil);
}

- (BOOL)outputFileExists
{
	return [self.fileManager fileExistsAtPath:self.outputPath];
}

@end
