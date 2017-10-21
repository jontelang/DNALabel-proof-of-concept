//
//  DNASequence.h
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 5/08/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DNASequence : NSObject

@property NSString *text;
@property UIFont *font;
@property NSMutableArray *allDNAPoints;
@property NSString *currentDNA;

-(id)initWithString:(NSString*)text_ font:(UIFont*)font_;

@end
