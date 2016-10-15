#import "RNFIRStorage.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"
@import Photos;
//@import FirebaseStorage;
#import <AssetsLibrary/AssetsLibrary.h>

@implementation RNFIRStorage
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();




- (void)setBridge:(RCTBridge *)bridge
{
  _bridge = bridge;

 
}



RCT_REMAP_METHOD(uploadFileToFirebase,
                 : (NSString*) localFile
                 : (NSString*) contentType
                 : (NSString*) bucket
                 : (NSString*) key
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
    
    
    NSURL *url = [[NSURL alloc] initWithString:localFile];
    
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage referenceForURL:bucket];
    
    FIRStorageReference *uploadRef = [storageRef child:key];
    
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = contentType;
    
    FIRStorageUploadTask *uploadTask = [uploadRef putFile:url metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
        [uploadTask removeAllObservers];
        [self.bridge.eventDispatcher sendAppEventWithName:@"FirebaseUploadProgressChanged" body: @{ @"progress": [NSNumber numberWithInteger:1], @"key": key}];
        if (error) {
            NSLog(@"Error uploading: %@", error);
            reject(@"Error", @"Failed upload file to firebase", error);
        }
        resolve(@ {@"success": @"123"});
        
    }];
    
    FIRStorageHandle observer = [uploadTask observeStatus:FIRStorageTaskStatusProgress
                                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                                      
                                                      double progress =  ((double)snapshot.progress.completedUnitCount / (double)snapshot.progress.totalUnitCount);
                                                      [self.bridge.eventDispatcher sendAppEventWithName:@"FirebaseUploadProgressChanged" body: @{ @"progress": [NSNumber numberWithDouble:progress], @"key": key}];
                                                      
                                                  }];
    
}

@end
