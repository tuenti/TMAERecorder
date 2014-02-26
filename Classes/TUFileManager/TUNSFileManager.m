//
//  TMFileManager.m
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

#import "TUNSFileManager.h"

@interface TUNSFileManager()

@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation TUNSFileManager

#pragma mark Initialization

- (instancetype)initWithFileManager:(NSFileManager *)fileManager
{
	if (self = [super init])
	{
		_fileManager = fileManager;
	}
	return self;
}

- (instancetype)init
{
	NSAssert(NO, @"Please use the designated initializer initWithFileManager:");
	return nil;
}

#pragma mark Method forwarding

- (BOOL)fileExistsAtPath:(NSString *)path
{
	return [self.fileManager fileExistsAtPath:path];
}

- (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error
{
	return [self.fileManager copyItemAtPath:srcPath
									 toPath:dstPath
									  error:error];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
	return [self.fileManager removeItemAtPath:path
										error:error];
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)error
{
	return [self.fileManager createDirectoryAtPath:path
					   withIntermediateDirectories:createIntermediates
										attributes:attributes
											 error:error];
}

- (NSData *)contentsAtPath:(NSString *)path
{
	return [self.fileManager contentsAtPath:path];
}

- (NSArray *)URLsForDirectory:(NSSearchPathDirectory)directory inDomains:(NSSearchPathDomainMask)domainMask
{
	return [self.fileManager URLsForDirectory:directory inDomains:domainMask];
}

@end
