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
#import "GCGiftCollectCell.h"
#import "StoreMgr.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableSet *wordFiles;
@property (nonatomic, retain) NSArray *wordFilesArray;

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
    
    NSString *wordsPath = [self wordPath];
    
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:wordsPath error:nil];
    
    for (NSString *fileName in fileList) {
        
        [_wordFiles addObject:fileName];
    }
    
    _wordFilesArray = [[NSArray alloc] initWithArray:_wordFiles.allObjects];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _wordFilesArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger nIndex = indexPath.row + indexPath.section * 10;
    
    NSString *value = [_wordFilesArray objectAtIndex:nIndex];
    
    WordListVCTL *vctl = [[WordListVCTL alloc] init];
    
    vctl.wordFileName = value;
    
    [self.navigationController pushViewController:vctl animated:YES];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"GCGiftCollectCell";
    
    GCGiftCollectCell *cell = (GCGiftCollectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSInteger nIndex = indexPath.row + indexPath.section * 10;
    
    NSString *value = [_wordFilesArray objectAtIndex:nIndex];
    
    [cell setWordFileName:value];
    
    return cell;
}

@end
