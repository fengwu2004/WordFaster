//
//  StoreMgr.m
//  Lottery
//
//  Created by user on 16/2/16.
//  Copyright © 2016年 user. All rights reserved.
//

#import "IDRLogManager.h"

@interface IDRLogManager()

@property (nonatomic, copy) NSString *logFilePath1;
@property (nonatomic, copy) NSString *logFilePath2;
@property (nonatomic, retain) NSMutableArray *logs1;
@property (nonatomic, retain) NSMutableArray *logs2;

@end

@implementation IDRLogManager

+ (IDRLogManager*)sharedInstance {
    
    static IDRLogManager *_instance = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        
        _instance = [[IDRLogManager alloc] init];
    });
    
    return _instance;
}

- (id)init {
    
    self = [super init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *fileName1 = [NSString stringWithFormat:@"logfile1.log"];
    
    NSString *fileName2 = [NSString stringWithFormat:@"logfile2.log"];
    
    _logFilePath1 = [documentDirectory stringByAppendingPathComponent:fileName1];
    
    _logFilePath2 = [documentDirectory stringByAppendingPathComponent:fileName2];
    
    _logs1 = [[NSMutableArray alloc] init];
    
    _logs2 = [[NSMutableArray alloc] init];
    
    _stopSave = NO;
    
    return self;
}

- (void)clear {
    
    [_logs1 removeAllObjects];
    
    if (_logFilePath1) {
        
        [[NSFileManager defaultManager] removeItemAtPath:_logFilePath1 error:nil];
    }
    
    [_logs2 removeAllObjects];
    
    if (_logFilePath2) {
        
        [[NSFileManager defaultManager] removeItemAtPath:_logFilePath2 error:nil];
    }
}

- (void)clearLog2 {

    [_logs2 removeAllObjects];
    
    if (_logFilePath2) {
        
        [[NSFileManager defaultManager] removeItemAtPath:_logFilePath2 error:nil];
    }
}

- (void)flush {
    
    [self flush:_logs1 filePath:_logFilePath1];
    
    [self flush:_logs2 filePath:_logFilePath2];
}

- (void)flush:(NSMutableArray*)logs filePath:(NSString*)filePath {
    
    if (logs.count <= 0) {
        
        return;
    }
    
    NSString *logTexts = logs[0];
    
    for (int i = 1; i < logs.count; ++i) {
        
        logTexts = [logTexts stringByAppendingString:logs[i]];
    }
    
    FILE *fp = fopen(filePath.UTF8String, "a+");
    
    fprintf(fp, "%s", logTexts.UTF8String);
    
    fclose(fp);
    
    [logs removeAllObjects];
}

- (void)log1:(NSString*)text {
    
    if (_stopSave) {
        
        return;
    }
    
    NSString *logtext = [text stringByAppendingString:@"\n"];
    
    [_logs1 addObject:logtext];
    
    if (_logs1.count > 3600) {
        
        [self flush:_logs1 filePath:_logFilePath1];
    }
}

- (NSString*)pd_fileNameyyyyMMddHHmmssString:(NSDate*)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    NSString *str;
    
    str = [formatter stringFromDate:date];
    
    return str;
}

- (void)log2:(NSString*)text {
    
    if (_stopSave) {
        
        return;
    }
    
    double time = [[NSDate date] timeIntervalSince1970];
    
    time *= 1000000000;
    
//    NSString *time = [self pd_fileNameyyyyMMddHHmmssString:[NSDate date]];
    
    NSString *logtext = [NSString stringWithFormat:@"%lld %@\n", (long long)time, text];
    
    [_logs2 addObject:logtext];
    
    if (_logs2.count > 3600) {
        
        [self flush:_logs2 filePath:_logFilePath2];
    }
}

- (void)logToConsolo:(NSString *)text {
    
    NSLog(@"%@", text);
}

@end
