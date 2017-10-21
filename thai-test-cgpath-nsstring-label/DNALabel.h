//
//  DNALabel.h
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 5/08/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNASequence;
@class DNAPoint;

@interface DNALabel : UILabel{
    DNASequence *dnasequence;
    NSDictionary *characterDNALookup;
}

-(void)setDNASequence:(DNASequence*)sequence_ lookup:(NSDictionary*)lookup_;

@end
