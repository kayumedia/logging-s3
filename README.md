# Local Logging to S3

A simple iOS application that allows local log files in an iOS application to be uploaded easily to an S3 bucket.

## Purpose

I was in a space where I had developed an app that I wanted to function in an "offline" environment (iPad), but there's click flow data that I really wanted to be able to log and capture in the most lightweight and easy way possible.  Simple text files, stored locally, and then transferred on demand to S3.

If you're looking for a robust REST framework to do live logging with more features, please review [RestKit](http://restkit.org// "RestKit").

## Requirements

This sample project depends on AWSiOSSDKv2

# Usage

```objective-c
#import "SimpleS3Logging.h"
```

## Example Usage

The code below creates a logfile in the local app directory, writes some data to it and uploads the file to the S3 store, deleting the local file on success.

```objective-c    
    [[SimpleS3Logging alloc] createLogFile];
    
    /* Write lines to log file  */
    NSString *logLine = @"\"test\",2,3";
    
    [[SimpleS3Logging alloc] writeToFile:logLine];

    [[SimpleS3Logging alloc] displayContent];
    [[SimpleS3Logging alloc] moveFileToS3:[[SimpleS3Logging alloc] awsS3FileNameGenerator]];
```
