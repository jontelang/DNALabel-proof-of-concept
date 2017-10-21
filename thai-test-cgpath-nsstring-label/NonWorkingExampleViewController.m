//
//  NonWorkingExampleViewController.m
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 21/10/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import "NonWorkingExampleViewController.h"

@implementation NonWorkingExampleViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"วาีม"];
    
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,1)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(1,1)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(2,1)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(3,1)];
    
    self.label.attributedText = text;
}

@end
