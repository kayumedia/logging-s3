# Local Logging to S3

A simple iOS application that allows local log files in an iOS application to be uploaded easily to an S3 bucket

## Requirements

This sample project depends on AWSiOSSDKv2

# Usage

```objective-c
#import "SimpleS3Logging.h"
```

## Example Usage

The code below creates a logfile in the local app directory, writes some data to it, displays
that data in the NSLog, and uploads the file to the S3 store, deleting the local file on success.

```objective-c    
    [[SimpleS3Logging alloc] createLogFile];
    
    /* Write lines to log file  */
    NSString *logLine = @"\"test\",2,3";
    
    [[SimpleS3Logging alloc] writeToFile:logLine];

    [[SimpleS3Logging alloc] displayContent];
    [[SimpleS3Logging alloc] moveFileToS3:[[SimpleS3Logging alloc] awsS3FileNameGenerator]];
```