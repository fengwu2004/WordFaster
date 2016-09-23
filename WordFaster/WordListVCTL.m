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
#import "WordFaster-swift.h"

@interface WordListVCTL()

@property (nonatomic, assign) BOOL showUnKnown;
@property (nonatomic, assign) BOOL showTrans;
@property (nonatomic, assign) NSInteger nIndex;
@property (nonatomic, assign) NSInteger downloadIndex;

@property (nonatomic, retain) NSMutableArray *words;
@property (nonatomic, retain) NSMutableArray *wordsDetail;
@property (nonatomic, retain) IBOutlet UIView *coverView;
@property (nonatomic, retain) ReadMgr *readMgr;
@property (nonatomic, retain) IBOutlet UIButton *ibBtnShowTrans;
@property (nonatomic, retain) IBOutlet UIButton *ibBtnShowUnknown;

@end

@implementation WordListVCTL

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _showTrans = YES;
    
    [_ibTable setAllowsSelection:NO];
    
    if ([self checkExist]) {
        
        [self loadFromStore];
    }
    else {
        
        [self loadFromNet];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"startPress.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onListenEn)];
    
    NSString *title = _showTrans ? @"不显示释意" : @"显示释意";
    
    [_ibBtnShowTrans setTitle:title forState:UIControlStateNormal];
    
    title = _showUnKnown ? @"显示所有" : @"仅显示未知";
    
    [_ibBtnShowUnknown setTitle:title forState:UIControlStateNormal];
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%d", (int)_wordsDetail.count]];
}

- (BOOL)checkExist {
    
    return [[StoreMgr sharedInstance] checkWordlistExist:[NSString stringWithFormat:@"word_%@", _wordFileName]];
}

- (void)loadFromStore {
    
    NSArray *dbData = [[StoreMgr sharedInstance] loadWords:[NSString stringWithFormat:@"word_%@", _wordFileName]];
    
    if (_showUnKnown) {
        
        _wordsDetail = [[NSMutableArray alloc] initWithArray:dbData];
    }
    else {
        
        _wordsDetail = [[NSMutableArray alloc] init];
        
        for (Word *word in dbData) {
            
            if (![word.known isEqualToNumber:@1]) {
                
                [_wordsDetail addObject:word];
            }
        }
    }
    
    [_ibTable reloadData];
}

- (void)loadFromNet {
    
    [self loadWordFromFile:_wordFileName];
    
    _downloadIndex = 0;
    
    _wordsDetail = [[NSMutableArray alloc] init];
    
    [self serverCall];
}

- (void)onListenEn {
    
    [_coverView setHidden:NO];
    
    _readMgr = nil;

    _readMgr = [[ReadMgr alloc] initWithWords:_wordsDetail];
    
    [_readMgr startRead];
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
    
    [[StoreMgr sharedInstance] saveWords:_wordsDetail name:[NSString stringWithFormat:@"word_%@", _wordFileName]];
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Word *word = [_wordsDetail objectAtIndex:indexPath.row];
    
    word.known = @1;
    
    [[StoreMgr sharedInstance] updateWord:word tableName:[NSString stringWithFormat:@"word_%@", _wordFileName]];
    
    [_wordsDetail removeObject:word];
    
    [_ibTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WordCell *cell = (WordCell *)[self cellByClassName:@"WordCell" inNib:@"WordListView" forTableView:tableView];
    
    Word *word = [_wordsDetail objectAtIndex:indexPath.row];
    
    [cell setWord:word translate:_showTrans];
    
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

- (IBAction)onHideCover:(id)sender {
    
    [_coverView setHidden:YES];
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

- (IBAction)onShowUnknown:(id)sender {
    
    _showUnKnown = !_showUnKnown;
    
    NSString *title = _showUnKnown ? @"仅显示未知" : @"显示所有";
    
    [_ibBtnShowUnknown setTitle:title forState:UIControlStateNormal];
    
    [self loadFromStore];
}

- (IBAction)onShowChinese:(id)sender {
    
    _showTrans = !_showTrans;
    
    NSString *title = _showTrans ? @"不显示释意" : @"显示释意";
    
    [_ibBtnShowTrans setTitle:title forState:UIControlStateNormal];
    
    [_ibTable reloadData];
}

- (void)dealloc {
    
    [_readMgr stopWithClear:YES];
}

@end
