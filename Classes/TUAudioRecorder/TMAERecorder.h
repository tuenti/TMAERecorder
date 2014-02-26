//
//  TMAERecorder.h
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
#import <CoreAudio/CoreAudioTypes.h>

#import "TUAudioRecorder.h"

@class AEAudioController;
@class AEMixerBuffer;
@class TMAudioFilter;

@protocol TUFileManager;
@protocol TMAudioControllerProvider;
@protocol TMMixerBufferProvider;

@interface TMAERecorder : NSObject <TUAudioRecorder>

@property (nonatomic, strong) TMAudioFilter *audioFilter;

// Dependencies
@property (nonatomic, strong, readonly) id<TMAudioControllerProvider> audioControllerProvider;
@property (nonatomic, strong, readonly) id<TMMixerBufferProvider> mixerBufferProvider;
@property (nonatomic, strong, readonly) id<TUFileManager> fileManager;

- (instancetype)initWithAudioControllerProvider:(id<TMAudioControllerProvider>)audioControllerProvider
							mixerBufferProvider:(id<TMMixerBufferProvider>)mixerBufferProvider
									fileManager:(id<TUFileManager>)fileManager
											URL:(NSURL *)url
									   settings:(NSDictionary *)settings;

@end

@protocol TMAERecorderProvider <TUAudioRecorderProvider>

@property (nonatomic, strong, readonly) id<TMAudioControllerProvider>audioControllerProvider;
@property (nonatomic, strong, readonly) id<TMMixerBufferProvider>mixerBufferProvider;
@property (nonatomic, strong, readonly) id<TUFileManager>fileManager;

- (id<TUAudioRecorder>)audioRecorderWithURL:(NSURL *)url
								   settings:(NSDictionary *)settings
									  error:(NSError **)outError;

@end

@protocol TMAudioControllerProvider <NSObject>

- (AEAudioController *)audioControllerWithAudioDescription:(AudioStreamBasicDescription)audioDescription
											  inputEnabled:(BOOL)enableInput;

@end

@protocol TMMixerBufferProvider <NSObject>

- (AEMixerBuffer *)mixerBufferProviderWithClientFormat:(AudioStreamBasicDescription)clientFormat;

@end
