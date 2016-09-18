//
//  StoreMgr.m
//  Lottery
//
//  Created by user on 16/2/16.
//  Copyright © 2016年 user. All rights reserved.
//

#import "StoreMgr.h"
#import <FMDB/FMDB.h>

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
    
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS wordlist (wordFile text PRIMARY KEY, time integer)"];
    
    [_db close];
}

- (NSArray*)loadWords:(NSString*)file {
    
    NSString *sql = [NSString stringWithFormat:@"SELECT detail FROM %@", file];
    
    FMResultSet *results = [_db executeQuery:sql];
    
    NSMutableArray *details = [[NSMutableArray alloc] init];
    
    while ([results next]) {
        
        NSString *detail = results[@"detail"];
        
        Word *word = [[Word alloc] initWithString:detail error:nil];
        
        [details addObject:word];
    }
    
    return [details copy];
}

- (BOOL)checkWordlistExist:(NSString*)wordlistName {
    
    if (![_db open]) {
        
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT time FROM wordlist WHERE wordFile='%@'", wordlistName];
    
    FMResultSet *results = [_db executeQuery:sql];
    
    BOOL exist = NO;
    
    while ([results next]) {
        
        exist = YES;
        
        break;
    }
    
    return exist;
}

- (void)saveWords:(NSArray*)words name:(NSString*)tableName {
    
    if (![_db open]) {
        
        return;
    }
    
    [_db executeUpdate:@"REPLACE INTO wordlist (wordFile, time) VALUES (?, ?)", tableName, [NSNumber numberWithInteger:1]];
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (word text PRIMARY KEY, detail text)", tableName];
    
    [_db executeUpdate:sql];
    
    [_db beginTransaction];
    
    for (Word *word in words) {
        
        [self saveWord:word tableName:tableName];
    }
    
    [_db commit];
    
    [_db close];
}

- (void)saveWord:(Word*)word tableName:(NSString*)tableName {
    
    if (![_db open]) {
        
        return;
    }
    
    NSString *json = word.toJSONString;
    
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (word, detail) VALUES (?, ?)", tableName];
    
    [_db executeUpdate:sql, word.en, json];
}

@end
