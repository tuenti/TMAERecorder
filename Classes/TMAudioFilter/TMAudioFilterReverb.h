//
//  TMAudioFilterReverb.h
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

#import "TMAudioFilter.h"

@interface TMAudioFilterReverb : TMAudioFilter

// From 0.001f to 1.0f seconds
// Defaults to 0.008f seconds
@property (nonatomic, assign) float minDelayTime;

// From 0.001f to 1.0f seconds
// Defaults to 0.05f seconds
@property (nonatomic, assign) float maxDelayTime;

// From 0.001f to 20.0f seconds
// Defaults to 1.0f seconds
@property (nonatomic, assign) float decayTimeAt0Hz;

// From 0.001f to 20.0f seconds
// Defaults to 0.5f seconds
@property (nonatomic, assign) float decayTimeAtNyquist;

// From 1 to 1000
// Defaults to 50
@property (nonatomic, assign) float randomizeReflections;

// From 0 to 100
// Defaults to 50
@property (nonatomic, assign) float dryWetMix;

@end
