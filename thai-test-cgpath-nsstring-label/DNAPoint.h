//
//  DNAPoint.h
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 5/08/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface DNAPoint : NSObject

/// tpe
@property CGPathElementType elementType;

/// enum number converter
@property (readonly) NSString *elementTypeNumber;

/// x
@property CGPoint elementPoint0;

/// xx
@property CGPoint elementPoint1;

/// xxx
@property CGPoint elementPoint2;

/// bcxys
@property (assign, atomic) CGPoint position;

/// helper
-(void)addToPath:(CGMutablePathRef)path;

@end
