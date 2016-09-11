//
//  StoreMgr.m
//  Lottery
//
//  Created by user on 16/2/16.
//  Copyright © 2016年 user. All rights reserved.
//

#import "StoreMgr.h"
#import <FMDBManager/FMDBManager.h>

@interface StoreMgr()

@property (nonatomic, retain) FMDatabase *db;

@end

@implementation StoreMgr

+ (StoreMgr*)sharedInstance {
    
    static StoreMgr *_instance = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        
        _instance = [[StoreMgr alloc] init];
    });
    
    return _instance;
}

- (id)init {
    
    self = [super init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"words.db"];
    
    _db = [FMDatabase databaseWithPath:dbPath];
    
    [self createTable];
    
    return self;
}

- (void)createTable {
    
    [_db open];
    
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS word_8_11 (word text PRIMARY KEY,detail text)"];
    
    [_db close];
}

- (void)saveWord:(Word*)word {
    
    if (![_db open]) {
        
        return;
    }
    
    NSString *json = word.toJSONString;
    
    [_db executeUpdate:@"REPLACE INTO word_8_11 (word, detail) VALUES (?, ?)", word.en, json];
    
    [_db close];
}


@end
