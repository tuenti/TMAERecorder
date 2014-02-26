//
//  TMAudioFilterReverb.m
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

#import "TMAudioFilterReverb.h"

#import "AEAudioUnitFilter.h"

@interface TMAudioFilterReverb ()

@property (nonatomic, strong) AEAudioUnitFilter *audioUnitFilter;

@end

@implementation TMAudioFilterReverb

@synthesize audioController = _audioController;

#pragma mark Set up and tear down of the filter

- (void)dealloc
{
	[self remove];
}

- (void)setUp
{
	AudioComponentDescription audioComponentDescription = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
																						  kAudioUnitType_Effect,
																						  kAudioUnitSubType_Reverb2);

	_audioUnitFilter = [[AEAudioUnitFilter alloc] initWithComponentDescription:audioComponentDescription
															   audioController:self.audioController
																		 error:NULL];

	NSAssert(_audioUnitFilter != nil, @"Couldn't setup converter audio unit");

	AudioUnitSetParameter(_audioUnitFilter.audioUnit,
						  kReverb2Param_DecayTimeAt0Hz,
						  kAudioUnitScope_Global,
						  0,
						  self.decayTimeAt0Hz,
						  0);

	AudioUnitSetParameter(_audioUnitFilter.audioUnit,
						  kReverb2Param_DecayTimeAtNyquist,
						  kAudioUnitScope_Global,
						  0,
						  self.decayTimeAtNyquist,
						  0);

	AudioUnitSetParameter(_audioUnitFilter.audioUnit,
						  kReverb2Param_MinDelayTime,
						  kAudioUnitScope_Global,
						  0,
						  self.minDelayTime,
						  0);

	AudioUnitSetParameter(_audioUnitFilter.audioUnit,
						  kReverb2Param_MaxDelayTime,
						  kAudioUnitScope_Global,
						  0,
						  self.maxDelayTime,
						  0);

	AudioUnitSetParameter(_audioUnitFilter.audioUnit,
						  kReverb2Param_RandomizeReflections,
						  kAudioUnitScope_Global,
						  0,
						  self.randomizeReflections,
						  0);

	AudioUnitSetParameter(_audioUnitFilter.audioUnit,
						  kReverb2Param_DryWetMix,
						  kAudioUnitScope_Global,
						  0,
						  self.dryWetMix,
						  0);
}

- (void)tearDown
{
	// This has to be dealloc-safe
	_audioUnitFilter = nil;
}

#pragma mark - Filter configuration and default values

- (float)decayTimeAt0Hz
{
	if (_decayTimeAt0Hz <= 0)
	{
		_decayTimeAt0Hz = 1.0f;
	}
	return _decayTimeAt0Hz;
}

- (float)decayTimeAtNyquist
{
	if (_decayTimeAtNyquist <= 0)
	{
		_decayTimeAtNyquist = 0.5f;
	}
	return _decayTimeAtNyquist;
}

- (float)minDelayTime
{
	if (_minDelayTime <= 0)
	{
		_minDelayTime = 0.008f;
	}
	return _minDelayTime;
}

- (float)maxDelayTime
{
	if (_maxDelayTime <= 0)
	{
		_maxDelayTime = 0.05f;
	}
	return _maxDelayTime;
}

- (float)randomizeReflections
{
	if (_randomizeReflections <= 0)
	{
		_randomizeReflections = 50.0f;
	}
	return _randomizeReflections;
}

- (float)dryWetMix
{
	if (_dryWetMix <= 0)
	{
		_dryWetMix = 50.0f;
	}
	return _dryWetMix;
}

#pragma mark - Filter control

- (void)apply
{
	[self setUp];
	[self.audioController addInputFilter:self.audioUnitFilter];
}

- (void)remove
{
	// This has to be dealloc-safe
	[_audioController removeFilter:_audioUnitFilter];
	[self tearDown];
}

@end
