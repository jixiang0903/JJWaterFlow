//
//  JJWaterFlowView.h
//  JJWaterFlowDemo
//
//  Created by 吉祥 on 2017/5/23.
//  Copyright © 2017年 jixiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJWaterFlowViewCell.h"

#pragma mark - ========================枚举定义========================
typedef enum {
    JJWaterFlowViewMarginTypeTop,
    JJWaterFlowViewMarginTypeBottom,
    JJWaterFlowViewMarginTypeLeft,
    JJWaterFlowViewMarginTypeRight,
    // 列间距
    JJWaterFlowViewMarginTypeColumn,
    // 上下相邻cell间距
    JJWaterFlowViewMarginTypeRow
} JJWaterFlowViewMarginType;

#pragma mark - ========================数据源代理定义========================
@class JJWaterFlowView;
@protocol JJWaterFlowViewDataSource <NSObject>

@required
/**
 *  一共多少cell
 *
 *  @param waterFlowView JJWaterFlowView对象
 *
 *  @return cell总个数，NSUInteger保证正数
 */
- (NSUInteger)numberOfCellsInWaterFlowView:(JJWaterFlowView *)waterFlowView;
/**
 *  返回对应索引的cell
 *
 *  @param waterFlowView JJWaterFlowView对象
 *  @param index         索引
 *
 *  @return 对应索引的cell
 */
- (JJWaterFlowViewCell *)waterFlowView:(JJWaterFlowView *)waterFlowView cellAtIndex:(NSUInteger)index;

@optional
/**
 *  一共多少列，如果数据源没有设置，默认为2列
 *
 *  @param waterFlowView JJWaterFlowView对象
 *
 *  @return 瀑布流列数
 */
- (NSUInteger)numberOfColumnsInWaterFlowView:(JJWaterFlowView *)waterFlowView;

@end

#pragma mark - ========================代理定义=======================
@protocol JJWaterFlowViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  返回对应索引的cell的高度
 *
 *  @param waterFlowView JJWaterFlowView对象
 *  @param index         索引
 *
 *  @return 对应索引的cell的高度
 */
- (CGFloat)waterFlowView:(JJWaterFlowView *)waterFlowView heightAtIndex:(NSUInteger)index;
/**
 *  点击cell回调
 *
 *  @param waterFlowView JJWaterFlowView对象
 *  @param index         索引
 */
- (void)waterFlowView:(JJWaterFlowView *)waterFlowView didSelectCellAtIndex:(NSUInteger)index;
/**
 *  返回对应间距类型的间距
 *
 *  @param waterFlowView JJWaterFlowView对象
 *  @param type          间距类型
 *
 *  @return 对应间距类型的间距
 */
- (CGFloat)waterFlowView:(JJWaterFlowView *)waterFlowView marginForType:(JJWaterFlowViewMarginType)type;


@end

#pragma mark - ========================类定义=======================
@interface JJWaterFlowView : UIScrollView
/**
 *  数据源对象
 */
@property (nonatomic, weak) id<JJWaterFlowViewDataSource> dataSource;
/**
 *   代理对象
 */
@property (nonatomic, weak) id<JJWaterFlowViewDelegate> delegate;

/**
 *  刷新数据
 *  调用该方法会重新向数据源和代理发送请求。获取数据
 */
- (void)reloadData;

/**
 *  根据ID查找可循环利用的cell
 *
 *  @return 可循环利用的cell
 */
- (JJWaterFlowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
