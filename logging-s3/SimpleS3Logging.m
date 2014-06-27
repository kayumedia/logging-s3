#import "SimpleS3Logging.h"
#import <AWSiOSSDKv2/S3.h>


NSString* const awsSecretKey = @"";
NSString* const awsAccessKey = @"";
NSString* const logFileName = @"activity.log";
NSString* const awsS3Bucket = @"test";


@implementation SimpleS3Logging : NSObject

- (NSString*) awsS3FileNameGenerator
{
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    CFUUIDRef sessionId = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, sessionId);
    CFRelease(sessionId);
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    NSString *timeInMilisecondsString = [NSString stringWithFormat:@"%i", (int)(timeInMiliseconds+0.5)];
    
    NSString *awsS3FileName = [NSString stringWithFormat:@"%@:%@:%@",idfv,uuidString,timeInMilisecondsString];
    return awsS3FileName;
}

- (NSString*) logFileNameFull
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:logFileName];
    return fileName;
}

-(void) writeToFile:(NSString *)content
{
   
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    NSString *timeInMilisecondsString = [NSString stringWithFormat:@"%f", timeInMiliseconds];
    
    /* Add the newline character to the content */
    content = [content stringByAppendingFormat:@",%@\r\n",timeInMilisecondsString];
    
    NSString *fileName = [[SimpleS3Logging alloc] logFileNameFull];
    
    /* Open and write to the last line of the file */
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
}

-(void) displayContent
{
    /* get the documents directory */
    NSString *fileName = [[SimpleS3Logging alloc] logFileNameFull];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    NSLog(@"%@",content);
    
}

- (void) createLogFile
{
    NSString *fileName = [[SimpleS3Logging alloc] logFileNameFull];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
}

- (void) moveFileToS3:(NSString*)awsS3FileNameString
{
    NSString *fileName = [[SimpleS3Logging alloc] logFileNameFull];
    
    /* Get the AWS Credentials */
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:awsAccessKey secretKey:awsSecretKey];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    AWSS3 *transferManager = [[AWSS3 alloc] initWithConfiguration:configuration];
    AWSS3PutObjectRequest *getLog = [AWSS3PutObjectRequest new];
    getLog.bucket = awsS3Bucket;
    getLog.key = awsS3FileNameString;
    
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil][NSFileSize] longLongValue];
    
    /* Set headers */
    getLog.contentType = @"text/plain";
    getLog.body = [NSURL fileURLWithPath:fileName];
    getLog.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
    
    [[transferManager putObject:getLog] continueWithBlock:^id(BFTask *task) {
        if(task.error)
        {
            NSLog(@"Error: %@",task.error);
        }
        else
        {
            /* If the file was able to be uploaded, then remove local copy */
            [self removeFile:fileName];
        }
        return nil;
    }];
}

- (void)removeFile:(NSString *)fileNameString
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:fileNameString error:&error];
    if (success) {
        NSLog(@"File Removed: %@", fileNameString);
    }
    else
    {
        NSLog(@"Could not delete file: %@ ",[error localizedDescription]);
    }
}


@end
