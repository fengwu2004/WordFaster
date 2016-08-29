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
    
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
    
    _db = [FMDatabase databaseWithPath:dbPath];
    
    [_db open];
    
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS Walk (x float,y float,z float,t float)"];
    
    [_db close];
    
    return self;
}

- (void)saveLocation:(double)x andY:(double)y andZ:(double)z andTime:(double)time {
    
    if (_stopSave) {
        
        return;
    }
    
    if (![_db open]) {
        
        return ;
    }
    
    [_db executeUpdate:@"INSERT INTO Walk (x, y, z, t) VALUES (?,?,?,?)", [NSNumber numberWithDouble:x],
     [NSNumber numberWithDouble:y], [NSNumber numberWithDouble:z], [NSNumber numberWithDouble:time]];
    
    [_db close];
}


@end
