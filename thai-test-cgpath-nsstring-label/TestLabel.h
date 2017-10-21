//
//  ThaiLabel.h
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 9/07/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (explodable)
-(NSArray*)explode;
-(void)explodePrettyPrint;
-(NSString*)explodePrettyPrintString;
@end


@interface TestLabel : UILabel
-(void)update;
@end
