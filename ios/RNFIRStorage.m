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
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary assetForURL:url resultBlock: ^(ALAsset *asset){
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        CGImageRef imageRef = [representation fullScreenImage];
        if (imageRef) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            imageView.image = [UIImage imageWithCGImage:imageRef scale:representation.scale orientation:representation.orientation];
            
            
            NSData *imageData =  UIImageJPEGRepresentation (imageView.image, 60);
            FIRStorage *storage = [FIRStorage storage];
            FIRStorageReference *storageRef = [storage referenceForURL:bucket];
            
             FIRStorageUploadTask *uploadTask = [[storageRef child:key]
             putData:imageData metadata:nil
             completion:^(FIRStorageMetadata *metadata, NSError *error) {
                 if (error) {
                     NSLog(@"Error uploading: %@", error);
                     reject(@"Error", @"Failed upload file to firebase", error);
                     return;
                 }
                 resolve(@ {@"success": @"123"});
                 
             }];
             
               FIRStorageHandle observer = [uploadTask observeStatus:FIRStorageTaskStatusProgress
            handler:^(FIRStorageTaskSnapshot *snapshot) {
            
              double progress =  ((double)snapshot.progress.completedUnitCount / (double)snapshot.progress.totalUnitCount);
              [self.bridge.eventDispatcher sendAppEventWithName:@"FirebaseUploadProgressChanged" body: @{ @"progress": [NSNumber numberWithDouble:progress], @"key": key}];
              
          }];


            // ...
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error Loading File: %@", error);
        reject(@"Error", @"Failed Open File", error);
    }];
    
    
    
}

@end
