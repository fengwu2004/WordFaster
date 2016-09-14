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

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableSet *wordFiles;
@property (nonatomic, retain) NSArray *wordFilesArray;
@property (nonatomic, retain) IBOutlet UICollectionView *collectView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"单词"];
    
    UINib *nib = [UINib nibWithNibName:@"GCGiftCollectCell" bundle:nil];
    
    [_collectView registerNib:nib forCellWithReuseIdentifier:@"GCGiftCollectCell"];
    
    [self setCollectionLayout];
    
    [self loadWords];
    
    [_collectView reloadData];
    
    _collectView.backgroundColor = [UIColor clearColor];
}

- (void)setCollectionLayout {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat width = 60;
    
    CGFloat height = 60;
    
    layout.itemSize = CGSizeMake(width, height);
    
    layout.minimumLineSpacing = 5;
    
    layout.minimumInteritemSpacing = 5;
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    layout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    
    [_collectView setCollectionViewLayout:layout];
    
    _collectView.contentSize = CGSizeMake(800, 300);
}

- (NSString*)wordPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"word"];
    
    return path;
}

- (int)f {
    
    return rand();
}

- (void)loadWords {
    
    NSString *wordsPath = [self wordPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:wordsPath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:wordsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:wordsPath error:nil];
    
    _wordFiles = [[NSMutableSet alloc] init];
    
    for (NSString *fileName in fileList) {
        
        [_wordFiles addObject:fileName];
    }
    
    _wordFilesArray = [[NSArray alloc] initWithArray:_wordFiles.allObjects];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _wordFilesArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger nIndex = indexPath.row;
    
    NSString *value = [_wordFilesArray objectAtIndex:nIndex];
    
    WordListVCTL *vctl = [[WordListVCTL alloc] init];
    
    value = [NSString stringWithFormat:@"word_%@", value];
    
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
    
    NSInteger nIndex = indexPath.row;
    
    NSString *value = [_wordFilesArray objectAtIndex:nIndex];
    
    [cell setWordFileName:value];
    
    return cell;
}

@end
