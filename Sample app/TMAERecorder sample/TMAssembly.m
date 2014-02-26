#import "TMAssembly.h"

#import "TMAERecorder.h"
#import "TUFileManager.h"
#import "TUNSFileManager.h"
#import "AEAudioController.h"
#import "AEMixerBuffer.h"

@implementation TMAssembly

- (id)AERecorder
{
    return [TyphoonFactoryProvider withProtocol:@protocol(TMAERecorderProvider) dependencies:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(audioControllerProvider) withDefinition:[self audioControllerProvider]];
		[definition injectProperty:@selector(mixerBufferProvider) withDefinition:[self mixerBufferProvider]];
		[definition injectProperty:@selector(fileManager) withDefinition:[self fileManager]];
		[definition setScope:TyphoonScopeSingleton];
	} factory:^id (id<TMAERecorderProvider> provider, NSURL *url, NSDictionary *settings, NSError **outError) {
		return [[TMAERecorder alloc] initWithAudioControllerProvider:provider.audioControllerProvider
												 mixerBufferProvider:provider.mixerBufferProvider
														 fileManager:provider.fileManager
																 URL:url
															settings:settings];
	}];
}

- (id)audioControllerProvider
{
	return [TyphoonFactoryProvider withProtocol:@protocol(TMAudioControllerProvider) dependencies:^(TyphoonDefinition *definition) {
		[definition setScope:TyphoonScopeSingleton];
	} factory:^id (id<TMAudioControllerProvider> provider, AudioStreamBasicDescription audioDescription, BOOL enableInput) {
		return [[AEAudioController alloc] initWithAudioDescription:audioDescription
													  inputEnabled:enableInput];
	}];
}

- (id)mixerBufferProvider
{
	return [TyphoonFactoryProvider withProtocol:@protocol(TMMixerBufferProvider) dependencies:^(TyphoonDefinition *definition) {
		[definition setScope:TyphoonScopeSingleton];
	} factory:^id (id<TMMixerBufferProvider> provider, AudioStreamBasicDescription audioDescription) {
		return [[AEMixerBuffer alloc] initWithClientFormat:audioDescription];
	}];
}

- (id)fileManager
{
	return [TyphoonDefinition withClass:[TUNSFileManager class] initialization:^(TyphoonInitializer *initializer) {
		initializer.selector = @selector(initWithFileManager:);
		[initializer injectWithDefinition:[self fileManagerNS]];
	}];
}

- (id)fileManagerNS
{
	return [TyphoonDefinition withClass:[NSFileManager class] initialization:^(TyphoonInitializer *initializer) {
		initializer.selector = @selector(defaultManager);
	}];
}

@end
