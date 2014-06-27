extern NSString* const awsSecretKey;
extern NSString* const awsAccessKey;
extern NSString* const logFileName;
extern NSString* const awsS3Bucket;

@class SimpleS3Logging;

@interface SimpleS3Logging : NSObject

- (NSString*) awsS3FileNameGenerator;
- (NSString*) logFileNameFull;
- (void) createLogFile;
- (void) displayContent;
- (void) writeToFile:(NSString *)fileNameString;
- (void) removeFile:(NSString *)fileNameString;
- (void) moveFileToS3:(NSString *)awsS3FileNameString;

@end

@interface SimpleS3Logging()



@end
