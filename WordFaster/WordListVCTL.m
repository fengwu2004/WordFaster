//
//  WordListVCTL.m
//  WordFaster
//
//  Created by ky on 8/29/16.
//  Copyright © 2016 yellfun. All rights reserved.
//

#import "WordListVCTL.h"
#import "Word.h"
#import "WordCell.h"
#import "IDRNetworkManager.h"
#import "StoreMgr.h"
#import <AVFoundation/AVFoundation.h>

@interface WordListVCTL()

@property (nonatomic, assign) NSInteger nIndex;
@property (nonatomic, assign) NSInteger downloadIndex;

@property (nonatomic, retain) NSMutableArray *words;
@property (nonatomic, retain) NSMutableArray *wordsDetail;

@end

@implementation WordListVCTL

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [_ibTable setAllowsSelection:NO];
    
    if ([self checkExist]) {
        
        [self loadFromStore];
    }
    else {
        
        [self loadFromNet];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"startPress.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onListenEn)];
}

- (BOOL)checkExist {
    
    return [[StoreMgr sharedInstance] checkWordlistExist:_wordFileName];
}

- (void)loadFromStore {
    
    NSArray *dbData = [[StoreMgr sharedInstance] loadWords:_wordFileName];
    
    _wordsDetail = [[NSMutableArray alloc] initWithArray:dbData];
    
    [_ibTable reloadData];
}

- (void)loadFromNet {
    
    [self loadWordFromFile:_wordFileName];
    
    _downloadIndex = 0;
    
    _wordsDetail = [[NSMutableArray alloc] init];
    
    [self serverCall];
}

- (void)onListenEn {
    
    _nIndex = 0;
    
    [self listenEn];
}

- (void)serverCall {
    
    if (_downloadIndex >= _words.count) {
        
        [self finishServerCall];
        
        return;
    }
    
    NSString *word = _words[_downloadIndex];
    
    NSLog(@"%d", (int)_downloadIndex);
    
    NSLog(@"%@", word);
    
    NSString *url = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=wordfaster&key=2006979987&type=data&doctype=json&version=1.1&q=%@", word];
    
    [[IDRNetworkManager sharedInstance] asyncServerCall:url parameters:nil success:^(NSDictionary *response) {
        
        [self saveWordDetail:response];
        
        ++_downloadIndex;
        
        [self serverCall];
        
    }failure:^(NSDictionary *responseData) {
     
        ++_downloadIndex;
        
        [self serverCall];
    }];
}

- (void)finishServerCall {
    
    [[StoreMgr sharedInstance] saveWords:_wordsDetail name:_wordFileName];
    
    [_ibTable reloadData];
}

- (NSString*)wordPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"word"];
    
    return path;
}

- (void)loadWordFromFile:(NSString*)file {
    
    NSString *str = [NSString stringWithFormat:@"%@/%@", [self wordPath], file];
    
    NSString *content = [NSString stringWithContentsOfFile:str encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *array = [content componentsSeparatedByString:@"\r"];
    
    if (!_words) {
        
        _words = [[NSMutableArray alloc] init];
    }
    
    [_words removeAllObjects];
    
    for (NSInteger i = 0; i < array.count; ++i) {
        
        [_words addObject:array[i]];
    }
}

- (UITableViewCell *)cellByClassName:(NSString *)className inNib:(NSString *)nibName forTableView:(UITableView *)tableView {
    
    Class cellClass = NSClassFromString(className);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
    
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        
        for (id oneObject in nib) {
            
            if ([oneObject isMemberOfClass:cellClass]) {
                
                return oneObject;
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.001;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _wordsDetail.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WordCell *cell = (WordCell *)[self cellByClassName:@"WordCell" inNib:@"WordListView" forTableView:tableView];
    
    Word *word = [_wordsDetail objectAtIndex:indexPath.row];
    
    [cell setWord:word];
    
    return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (void)listenEn {
    
    if (_nIndex >= _wordsDetail.count) {
        
        return;
    }
    
    Word *word = _wordsDetail[_nIndex];
    
    AVSpeechSynthesizer *speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:word.en];
    
    utterance.voice = voice;
    
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    
    [speechSynthesizer speakUtterance:utterance];
    
    ++_nIndex;
    
    [self performSelector:@selector(listenEn) withObject:nil afterDelay:3];
}

@end
