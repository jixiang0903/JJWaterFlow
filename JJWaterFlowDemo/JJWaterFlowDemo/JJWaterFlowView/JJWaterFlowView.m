//
//  JJWaterFlowView.m
//  JJWaterFlowDemo
//
//  Created by 吉祥 on 2017/5/23.
//  Copyright © 2017年 jixiang. All rights reserved.
//

#import "JJWaterFlowView.h"
#import "JJWaterFlowViewCell.h"
#define JJWaterFlowViewDefaultCellH 50
#define JJWaterFlowViewDefaultColumnsCount 3
#define JJWaterFlowViewDefaultMargin 10

#pragma mark - ========================类扩展=======================
@interface JJWaterFlowView ()

/**
 *  所有cell的frame数组
 */
@property (nonatomic, strong) NSMutableArray *cellFrames;
/**
 *  正在展示的cell字典，key是cell的index
 */
@property (nonatomic, strong) NSMutableDictionary *displayingCells;
/**
 *  缓存cell的Set
 */
@property (nonatomic, strong) NSMutableSet *reusableCells;

@end

#pragma mark - ========================类实现=======================
@implementation JJWaterFlowView

@dynamic delegate;

- (void)layoutSubviews {
    
    NSUInteger cellsCount = self.cellFrames.count;
    for (int i = 0; i < cellsCount; i++) {
        // 对应的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        // 如果该frame在屏幕显示范围内，加载cell
        JJWaterFlowViewCell *cell = self.displayingCells[@(i)];
        if ([self isInScreen:cellFrame]) { // 在屏幕上
            if (cell == nil) {
                // 向代理索取一个cell
                cell = [self.dataSource waterFlowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                self.displayingCells[@(i)] = cell;
            }
            
        } else {// 不在屏幕上
            if (cell != nil) {
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                // 存进缓存池
                [self.reusableCells addObject:cell];
            }
        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self reloadData];
}

#pragma mark - ========================懒加载=======================
- (NSMutableArray *)cellFrames {
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells {
    if (_displayingCells == nil) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells {
    if (_reusableCells == nil) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

#pragma mark - ========================Action=======================
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (![self.delegate respondsToSelector:@selector(waterFlowView:didSelectCellAtIndex:)]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // 找到选中的cell
    __block NSNumber *selectedIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, JJWaterFlowViewCell *cell, BOOL * stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectedIndex = key;
            *stop =YES;
        }
    }];
    
    if (selectedIndex != nil) {
        [self.delegate waterFlowView:self didSelectCellAtIndex:selectedIndex.unsignedIntegerValue];
    }
    
}

#pragma mark - ========================public=======================
- (void)reloadData {
    // 1.计算每一个cell的尺寸位置
    // cell总数
    NSUInteger cellsCount = [self.dataSource numberOfCellsInWaterFlowView:self];
    // 瀑布流列数
    NSUInteger columnsCount = [self numberOfColumns];
    
    CGFloat marginTop = [self marginForType:JJWaterFlowViewMarginTypeTop];
    CGFloat marginBottom = [self marginForType:JJWaterFlowViewMarginTypeBottom];
    CGFloat marginLeft = [self marginForType:JJWaterFlowViewMarginTypeLeft];
    CGFloat marginRight = [self marginForType:JJWaterFlowViewMarginTypeRight];
    CGFloat marginRow = [self marginForType:JJWaterFlowViewMarginTypeRow];
    CGFloat marginColumn = [self marginForType:JJWaterFlowViewMarginTypeColumn];
    
    CGFloat cellW = (self.frame.size.width - marginLeft - marginRight - (columnsCount - 1) * marginColumn) / columnsCount;
    
    CGFloat maxYOfColumns[columnsCount];
    for (int i = 0; i < columnsCount; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    for (int i = 0; i < cellsCount; i++) {
        NSUInteger cellColumn = 0;
        NSUInteger maxYOfColumn = maxYOfColumns[cellColumn];
        
        // 找到当前最短的一列
        for (int j = 0; j < columnsCount; j++) {
            if (maxYOfColumns[j] < maxYOfColumn) {
                // 这个cell将会加在该列
                cellColumn = j;
                maxYOfColumn = maxYOfColumns[j];
            }
        }
        
        CGFloat cellH = [self heightAtIndex:i];
        CGFloat cellX = marginLeft + cellColumn * (cellW + marginColumn);
        
        CGFloat cellY = 0;
        
        if (maxYOfColumn == 0.0) { //第一行需要有间距
            cellY = marginTop;
        } else {
            cellY = maxYOfColumn + marginRow;
        }
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        // 更新这一列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
    }
    
    // 设置contentSize
    CGFloat contentH = maxYOfColumns[0];
    
    // 找到当前最短的一列
    for (int i = 0; i < columnsCount; i++) {
        if (maxYOfColumns[i] > contentH) {
            contentH = maxYOfColumns[i];
        }
    }
    contentH += marginBottom;
    
    self.contentSize = CGSizeMake(0, contentH);
}

- (JJWaterFlowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    
    __block JJWaterFlowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(JJWaterFlowViewCell *cell, BOOL * stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell != nil) { // 如果缓存池中有
        // 从缓存池中移除
        [self.reusableCells removeObject:reusableCell];
    }
    
    return reusableCell;
}

#pragma mark - ========================private=======================
- (CGFloat)heightAtIndex:(NSUInteger)index {
    CGFloat cellH = JJWaterFlowViewDefaultCellH;
    
    if ([self.delegate respondsToSelector:@selector(waterFlowView:heightAtIndex:)]) {
        cellH = [self.delegate waterFlowView:self heightAtIndex:index];
    }
    
    return cellH;
}

- (CGFloat)numberOfColumns {
    CGFloat columsCount =  JJWaterFlowViewDefaultColumnsCount;
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterFlowView:)]) {
        columsCount = [self.dataSource numberOfColumnsInWaterFlowView:self];
    }
    return columsCount;
}

- (CGFloat)marginForType:(JJWaterFlowViewMarginType)type {
    CGFloat margin = JJWaterFlowViewDefaultMargin;
    if ([self.delegate respondsToSelector:@selector(waterFlowView:marginForType:)]) {
        margin = [self.delegate waterFlowView:self marginForType:type];
    }
    return margin;
}

/**
 *  判断给定frame是否在显示范围内
 *
 *  @return 给定frame是否在显示范围内
 */
- (BOOL)isInScreen:(CGRect)frame {
    // contentOffset.y 滚动到的y值
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMinY(frame) < self.contentOffset.y + self.frame.size.height);
}

@end
