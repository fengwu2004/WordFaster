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

@property (nonatomic, retain) NSMutableArray *words;
@property (nonatomic, retain) NSMutableArray *wordsDetail;
@property (nonatomic, assign) NSInteger nIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self loadWords];
}

- (void)loadWords {
    
    if (!_words) {
        
        _words = [[NSMutableArray alloc] init];
    }
    
    [_words removeAllObjects];
    
    if (!_wordsDetail) {
        
        _wordsDetail = [[NSMutableArray alloc] init];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
   
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:@"words.txt"];
    
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *array = [str componentsSeparatedByString:@"\r"];
    
    for (NSInteger i = 0; i < array.count; ++i) {
        
        [_words addObject:array[i]];
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
