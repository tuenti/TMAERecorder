//
//  TMAudioFilter.h
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

typedef NS_ENUM(NSUInteger, TMAudioFilterType) {
    TMAudioFilterTypeNone,
    TMAudioFilterTypeBackgroundMixer,
    TMAudioFilterTypePitchChanger,
    TMAudioFilterTypeReverb,
};

@class AEAudioController;

@interface TMAudioFilter : NSObject

@property (nonatomic, copy) NSString *filterId;
@property (nonatomic, weak) AEAudioController *audioController;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, getter = isRecentlyAdded) BOOL recentlyAdded;

- (void)apply;
- (void)remove;

@end
