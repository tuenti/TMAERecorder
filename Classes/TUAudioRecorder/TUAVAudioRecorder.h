//
//  TUAVAudioRecorder.h
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

#import <AVFoundation/AVFoundation.h>

#import "TUAudioRecorder.h"

@interface TUAVAudioRecorder : NSObject <TUAudioRecorder>

@property (nonatomic, strong, readonly) AVAudioRecorder *audioRecorder;

/* The file type to record is inferred from the file extension. Will overwrite a file at the specified url if a file exists */
- (id)initWithURL:(NSURL *)url settings:(NSDictionary *)settings error:(NSError **)outError;

@end
