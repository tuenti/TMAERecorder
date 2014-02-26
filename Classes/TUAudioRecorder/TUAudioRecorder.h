//
//  TUAudioRecorder.h
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

#import <Foundation/Foundation.h>

@protocol TUAudioRecorderDelegate;

#pragma mark - TUAudioRecorder protocol

@protocol TUAudioRecorder <NSObject>

/* transport control */

/* methods that return BOOL return YES on success and NO on failure. */
- (BOOL)prepareToRecord; /* creates the file and gets ready to record. happens automatically on record. */
- (BOOL)record; /* start or resume recording to file. */
- (void)stop; /* stops recording. closes the file. */

- (BOOL)isRecording; /* is it recording or not? */

- (BOOL)deleteRecording; /* delete the recorded file. recorder must be stopped. returns NO on failure. */

- (void)updateMeters; /* call to refresh meter values */
- (float)averagePowerForChannel:(NSUInteger)channelNumber; /* returns average power in decibels for a given channel */

/* properties */

/* these settings are fully valid only when prepareToRecord has been called */
@property(readonly) NSDictionary *settings;

@property(getter=isMeteringEnabled) BOOL meteringEnabled; /* turns level metering on or off. default is off. */
@property(readonly, getter=isRecording) BOOL recording; /* is it recording or not? */

/* get the current time of the recording - only valid while recording */
@property(readonly) NSTimeInterval currentTime;

/* the delegate will be sent messages from the TUAudioRecorderDelegate protocol */
@property(weak) id<TUAudioRecorderDelegate> delegate;


/* Optional methods to keep the interface compatible with Apple's AVAudioRecorder */
@optional

/* Sets the audio filter which will be used to real time recorded sound filtering */
- (void)setAudioFilter:(id)audioFilter;

@end

#pragma mark - TUAudioRecorderDelegate protocol

@protocol TUAudioRecorderDelegate <NSObject>

@optional

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(id<TUAudioRecorder>)recorder successfully:(BOOL)flag;

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(id<TUAudioRecorder>)recorder error:(NSError *)error;

/* audioRecorderEndInterruption:withOptions: is called when the audio session interruption has ended and this recorder had been interrupted while recording. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioRecorderEndInterruption:(id<TUAudioRecorder>)recorder withOptions:(NSUInteger)flags;

@end

#pragma mark - TUAudioRecorderProvider protocol

@protocol TUAudioRecorderProvider <NSObject>

- (id<TUAudioRecorder>)audioRecorderWithURL:(NSURL *)url settings:(NSDictionary *)settings error:(NSError **)outError;

@end
