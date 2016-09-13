//
//  ViewController.m
//  WordFaster
//
//  Created by ky on 8/29/16.
//  Copyright © 2016 yellfun. All rights reserved.
//

#import "ViewController.h"
#import "IDRNetworkManager.h"
#import "WordListVCTL.h"
#import "Word.h"
#import "StoreMgr.h"

@interface ViewController ()

@property (nonatomic, retain) NSMutableDictionary *wordDic;
@property (nonatomic, retain) NSMutableArray *wordsDetail;
@property (nonatomic, assign) NSInteger nIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self loadWords];
}

- (NSString*)wordPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"word"];
    
    return path;
}

- (void)loadWords {
    
    if (!_wordsDetail) {
        
        _wordsDetail = [[NSMutableArray alloc] init];
    }
    
    NSString *wordsPath = [self wordPath];
    
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:wordsPath error:nil];
    
    NSMutableArray *needUpdateList = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in fileList) {
        
        if (![self checkExist:fileName]) {
            
            [needUpdateList addObject:fileName];
        }
    }
    
    [self loadWordList:needUpdateList];
}

- (BOOL)checkExist:(NSString*)listName {
    
    return YES;
}

- (void)loadWordFromFile:(NSString*)file {
    
    NSString *str = [NSString stringWithFormat:@"%@/%@", [self wordPath], file];
    
    NSString *content = [NSString stringWithContentsOfFile:str encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *array = [content componentsSeparatedByString:@"\r"];
    
    NSMutableArray *words = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < array.count; ++i) {
        
        [words addObject:array[i]];
    }
    
    [_wordDic setObject:words forKey:file];
}

- (void)loadWordList:(NSArray*)wordlist {
    
    for (NSString *wordListName in wordlist) {
        
        [self loadWordFromFile:wordListName];
    }
}

- (void)serverCall {
    
    if (_nIndex >= _words.count) {
        
        [self finishServerCall];
        
        return;
    }
    
    NSString *word = _words[_nIndex];
    
    NSString *url = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=wordfaster&key=2006979987&type=data&doctype=json&version=1.1&q=%@", word];
    
    [[IDRNetworkManager sharedInstance] asyncServerCall:url parameters:nil success:^(NSDictionary *response) {
        
        [self saveWordDetail:response];
        
        ++_nIndex;
        
        [self serverCall];
    }];
}

- (void)finishServerCall {
    
    for (Word *word in _wordsDetail) {
        
        [[StoreMgr sharedInstance] saveWord:word];
    }
    
    WordListVCTL *vctl = [[WordListVCTL alloc] init];
    
    vctl.words = [_wordsDetail copy];
    
    [self.navigationController pushViewController:vctl animated:YES];
}

- (void)saveWordDetail:(NSDictionary*)data {
    
    NSDictionary *basic = data[@"basic"];
    
    Word *word = [[Word alloc] init];
    
    word.en = [data objectForKey:@"query"];
    
    NSArray *explains = [basic objectForKey:@"explains"];
    
    if (explains.count > 0) {
        
        word.ch = [explains firstObject];
    }
    
    word.read = [basic objectForKey:@"us-phonetic"];
    
    [_wordsDetail addObject:word];
}

- (IBAction)start:(id)sender {
    
    _nIndex = 0;
    
    [self serverCall];
}

@end
