//
//  DNAPoint.m
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 5/08/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import "DNAPoint.h"

@implementation DNAPoint

-(NSString*)elementTypeNumber{
    return [NSString stringWithFormat:@"%i", (int)self.elementType];
}

-(void)addToPath:(CGMutablePathRef)path{
    switch (self.elementType) {
        case kCGPathElementMoveToPoint:
            CGPathMoveToPoint(path,
                              nil,
                              self.position.x + self.elementPoint0.x,
                              self.position.y + self.elementPoint0.y);
            break;
            
        case kCGPathElementAddLineToPoint:
            CGPathAddLineToPoint(path,
                                 nil,
                                 self.position.x + self.elementPoint0.x,
                                 self.position.y + self.elementPoint0.y);
            break;
            
        case kCGPathElementAddQuadCurveToPoint:
            CGPathAddQuadCurveToPoint(path,
                                      nil,
                                      self.position.x + self.elementPoint0.x,
                                      self.position.y + self.elementPoint0.y,
                                      self.position.x + self.elementPoint1.x,
                                      self.position.y + self.elementPoint1.y);
            break;
            
        case kCGPathElementAddCurveToPoint:
            CGPathAddCurveToPoint(path,
                                  nil,
                                  self.position.x + self.elementPoint0.x,
                                  self.position.y + self.elementPoint0.y,
                                  self.position.x + self.elementPoint1.x,
                                  self.position.y + self.elementPoint1.y,
                                  self.position.x + self.elementPoint2.x,
                                  self.position.y + self.elementPoint2.y);
            break;
            
        case kCGPathElementCloseSubpath:
            CGPathCloseSubpath(path);
            break;
    }
}

@end
