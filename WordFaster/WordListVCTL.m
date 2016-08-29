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
#import <AVFoundation/AVFoundation.h>

@interface WordListVCTL()

@property (nonatomic, assign) NSInteger nIndex;

@end

@implementation WordListVCTL

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
    
    return _words.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WordCell *cell = (WordCell *)[self cellByClassName:@"WordCell" inNib:@"WordListView" forTableView:tableView];
    
    Word *word = [_words objectAtIndex:indexPath.row];
    
    [cell setWord:word];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (void)listenEn {
    
    if (_nIndex >= _words.count) {
        
        return;
    }
    
    Word *word = _words[_nIndex];
    
    AVSpeechSynthesizer *speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:word.en];
    
    utterance.voice = voice;
    
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    
    [speechSynthesizer speakUtterance:utterance];
    
    ++_nIndex;
    
    [self performSelector:@selector(listenEn) withObject:nil afterDelay:3];
}

- (IBAction)onListen:(id)sender {
    
    _nIndex = 0;
    
    [self listenEn];
}

@end
