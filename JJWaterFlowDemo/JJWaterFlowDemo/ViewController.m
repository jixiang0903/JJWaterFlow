//
//  ViewController.m
//  JJWaterFlowDemo
//
//  Created by 吉祥 on 2017/5/23.
//  Copyright © 2017年 jixiang. All rights reserved.
//

#import "ViewController.h"
#import "JJWaterFlowView.h"
#import "JJWaterFlowViewCell.h"

@interface ViewController ()<JJWaterFlowViewDataSource,JJWaterFlowViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JJWaterFlowView *waterFlowView = [[JJWaterFlowView alloc] init];
    waterFlowView.frame = self.view.bounds;
    waterFlowView.dataSource = self;
    waterFlowView.delegate = self;
    [self.view addSubview:waterFlowView];
}
#pragma mark - =======================JJWaterFlowView数据源=======================
- (NSUInteger)numberOfCellsInWaterFlowView:(JJWaterFlowView *)waterFlowView {
    return 100;
}

- (NSUInteger)numberOfColumnsInWaterFlowView:(JJWaterFlowView *)waterFlowView {
    return 3;
}

- (JJWaterFlowViewCell *)waterFlowView:(JJWaterFlowView *)waterFlowView cellAtIndex:(NSUInteger)index {
    JJWaterFlowViewCell *cell = [waterFlowView dequeueReusableCellWithIdentifier:@"reuseID"];
    
    if (cell == nil) {
        cell = [[JJWaterFlowViewCell alloc] init];
        cell.identifier = @"reuseID";
        cell.backgroundColor = [self randomColor];
        UILabel *label = [[UILabel alloc] init];
        label.tag = 101;
        label.frame = CGRectMake(20, 20, 30, 30);
        
        [cell addSubview:label];
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    label.text = [NSString stringWithFormat:@"%ld",index];
    
    return cell;
}

#pragma mark - =======================JJWaterFlowView代理=======================
- (CGFloat)waterFlowView:(JJWaterFlowView *)waterFlowView heightAtIndex:(NSUInteger)index {
    // [500,150)
    return (arc4random() % 101) + 100;;
    
}

- (CGFloat)waterFlowView:(JJWaterFlowView *)waterFlowView marginForType:(JJWaterFlowViewMarginType)type {
    switch (type) {
        case JJWaterFlowViewMarginTypeTop:
        case JJWaterFlowViewMarginTypeBottom:
        case JJWaterFlowViewMarginTypeLeft:
        case JJWaterFlowViewMarginTypeRight:
            return 12;
            break;
        default:
            return 5;
            break;
    }
}


#pragma mark - =======================Other=======================
- (void)waterFlowView:(JJWaterFlowView *)waterFlowView didSelectCellAtIndex:(NSUInteger)index {
    NSLog(@"点击cell，位置：%ld", index);
}

- (UIColor *)colorWithR:(NSUInteger)r G:(NSUInteger)g B:(NSUInteger)b {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

- (UIColor *)randomColor {
    return [self colorWithR:arc4random_uniform(255) G:arc4random_uniform(255) B:arc4random_uniform(255)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
