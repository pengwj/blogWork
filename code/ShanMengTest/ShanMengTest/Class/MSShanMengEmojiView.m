//
//  MSShanMengEmojiView.m
//  ShanMengTest
//
//  Created by Admin on 2019/8/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "MSShanMengEmojiView.h"
#import "MSShanMengCollectionCell.h"
#import "MSShanMengModel.h"

#define SCHorizontalMargin   4.0f
#define SCVerticalMargin     4.0f
#define MSShanMengEmojiWidth     74.0f

@interface MSShanMengEmojiView ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *emojiArray;

@end

@implementation MSShanMengEmojiView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupView];
        
    }
    return self;
}

- (void)setupView {
    
    self.backgroundColor = [UIColor yellowColor];
    
    // 1.创建流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.collectionView];
    
    self.clipsToBounds = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    /// 设置此属性为yes 不满一屏幕 也能滚动
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self registerNibWithTableView];
}

#pragma mark - 代理方法 Delegate Methods
// 设置分区
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 每个分区上得元素个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emojiArray.count;
}

// 设置cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MSShanMengCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSShanMengCollectionCell" forIndexPath:indexPath];
    if (!cell) {
        
        cell = [[MSShanMengCollectionCell alloc] initWithFrame:CGRectZero];
    }
    
    MSShanMengModel *model = self.emojiArray[indexPath.row];
    
    CGSize imageSize = [self getSizeWithModel:model];
    
    [cell refreshCellWithModel:self.emojiArray[indexPath.row] size:CGSizeMake(imageSize.width, imageSize.height)];

    return cell;
}

// 设置cell大小 itemSize：可以给每一个cell指定不同的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MSShanMengModel *model = self.emojiArray[indexPath.row];

    CGSize imageSize = [self getSizeWithModel:model];

    return imageSize;
}


// 设置UIcollectionView整体的内边距（这样item不贴边显示）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // 上 左 下 右
    return UIEdgeInsetsMake(SCVerticalMargin, SCHorizontalMargin, SCVerticalMargin, SCHorizontalMargin);
}

// 设置minimumLineSpacing：cell上下之间最小的距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return SCHorizontalMargin;
}

// 设置minimumInteritemSpacing：cell左右之间最小的距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return SCHorizontalMargin;
}

// 选中cell的回调
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MSShanMengModel *model = self.emojiArray[indexPath.row];

    if (self.delegate && [self.delegate respondsToSelector:@selector(msShanMengEmojiViewSelectModel:)]) {
        [self.delegate msShanMengEmojiViewSelectModel:model];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self scrollViewEndWith:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewEndWith:scrollView];
}

- (void)scrollViewEndWith:(UIScrollView *)scrollView
{
    CGFloat width = scrollView.contentOffset.x+[[UIScreen mainScreen] bounds].size.width;
    NSUInteger emojiWidth = MSShanMengEmojiWidth+SCHorizontalMargin;
    
    NSUInteger count = width/emojiWidth;
    NSUInteger pageIndex = count/kEmojiPage;
    
    if (count>=(kEmojiPage-2)) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(msShanMengEmojiViewPageIndex:)]) {
            [self.delegate msShanMengEmojiViewPageIndex:pageIndex];
        }
        
    }
}

#pragma mark - 对外方法 Public Methods
/// array数组里面放的元素 必须字符串类型的
- (void)refreshUIWithGifArray:(NSArray<MSShanMengModel *> *)array  {
    [self.emojiArray removeAllObjects];
    [self.emojiArray addObjectsFromArray:array];
    [self.collectionView reloadData];
    
    // 刷新显示状态
    if (array.count>0) {
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
    
}


#pragma mark - 内部方法 Private Methods
// 注册cell
- (void)registerNibWithTableView {
    [self.collectionView registerClass:[MSShanMengCollectionCell class] forCellWithReuseIdentifier:@"MSShanMengCollectionCell"];
}

- (CGSize)getSizeWithModel:(MSShanMengModel *)model
{
    CGFloat thumbW = [model.thumb.w floatValue];
    CGFloat thumbH = [model.thumb.h floatValue];
    
    CGFloat height = MSShanMengEmojiWidth;
    CGFloat width = (thumbW/thumbH)*height;
    
    return CGSizeMake(width, height);
}

#pragma mark - 点击/触碰事件 Action Methods

#pragma mark - 懒加载 Lazy Load

- (NSMutableArray *)emojiArray {
    if (!_emojiArray) {
        _emojiArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _emojiArray;
}


@end
