#import "RNFIRStorage.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"
@import Photos;
//@import FirebaseStorage;





@implementation RNFIRStorage
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();




- (void)setBridge:(RCTBridge *)bridge
{
  _bridge = bridge;

 
}



RCT_REMAP_METHOD(UploadFileToFirebase,
                 : (NSString*) localFile
                 : (NSString*) contentType
                 : (NSString*) bucket
                 : (NSString*) key
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
  NSURL *url = [[NSURL alloc] initWithString:localFile];
  PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
  PHAsset *asset = [assets firstObject];
  [asset requestContentEditingInputWithOptions:nil
                             completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                 NSDictionary *info) {
                               NSURL *imageFile = contentEditingInput.fullSizeImageURL;


  FIRStorage *storage = [FIRStorage storage];
  // Create a storage reference from our storage service
  FIRStorageReference *storageRef = [storage referenceForURL:bucket];


  // Create a reference to the file you want to upload
  //NSString *storageLocation = [@"images/" stringByAppendingString:key];
  FIRStorageReference *riversRef = [storageRef child:key];

  // Upload the file to the path "images/rivers.jpg"
  FIRStorageUploadTask *uploadTask = [riversRef putFile:imageFile metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
    if (error != nil) {
      // Uh-oh, an error occurred!
      NSLog(@"Error in Uploading File to Firebase", error);
      reject(@"Error", @"Failed upload file to firebase", error);
    } else {
      // Metadata contains file metadata such as size, content-type, and download URL.
      NSURL *downloadURL = metadata.downloadURL;
      NSLog(@"Successfully uploaded File to Firebase", metadata);
      resolve(@ {@"downloadURL": downloadURL});
    }
  }];

  FIRStorageHandle observer = [uploadTask observeStatus:FIRStorageTaskStatusProgress
                                                handler:^(FIRStorageTaskSnapshot *snapshot) {

                                                  float progress = (float) snapshot.progress.totalUnitCount / snapshot.progress.completedUnitCount;
                                                  [self.bridge.eventDispatcher sendAppEventWithName:@"FirebaseUploadProgressChanged" body: @{ @"progress": [NSNumber numberWithFloat:progress], @"key": key}];

                                                }];
                             }];

}

@end
