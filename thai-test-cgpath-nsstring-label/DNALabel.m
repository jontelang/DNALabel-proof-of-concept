//
//  DNALabel.m
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 5/08/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import "DNALabel.h"
#import "DNASequence.h"
#import "DNAPoint.h"

@implementation DNALabel

-(void)setDNASequence:(DNASequence*)sequence_ lookup:(NSDictionary*)lookup_{
    dnasequence = sequence_;
    self.text = sequence_.text;
    self.font = sequence_.font;
    characterDNALookup = lookup_;
    
    // Ensure we redraw it asap
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if( dnasequence == nil ){
        return;
    }
    
    int currentStart = 0;
    
    // Here be drawing
    for (int i = 0; i < self.text.length; i++) {
        NSString *character = [self.text substringWithRange:NSMakeRange(i, 1)];
        
        if( [character isEqualToString:@" "] ){
            continue;
        }
        else{
            NSString *characterDNA = characterDNALookup[character];
            NSRange rangeToLookAt = NSMakeRange(currentStart, dnasequence.currentDNA.length-currentStart);
            NSRange range = [dnasequence.currentDNA rangeOfString:characterDNA
                                                          options:0
                                                            range:rangeToLookAt];
            NSArray *pointsForCharacter = [dnasequence.allDNAPoints subarrayWithRange:range];
            currentStart += range.length;
            
            CGMutablePathRef path = CGPathCreateMutable();
            for (DNAPoint *point in pointsForCharacter) {
                [point addToPath:path];
            }
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSaveGState(ctx);
              CGContextTranslateCTM(ctx,0,0 - 40 + CGRectGetMidY(rect) - self.font.descender + 0);
              CGContextScaleCTM(ctx, 1, -1);
              CGContextAddPath(ctx, path);
              [[UIColor blackColor] setFill];
            
              // TODO remove this, just for demo purposes
              if([character isEqualToString:@"ว"]){[[UIColor blueColor] setFill];}
              if([character isEqualToString:@"า"]){[[UIColor redColor] setFill];}
              if([character isEqualToString:@"ี"]){[[UIColor greenColor] setFill];}
              if([character isEqualToString:@"ม"]){[[UIColor orangeColor] setFill];}
            
              CGContextFillPath(ctx);
            CGContextRestoreGState(ctx);
            
            CGPathRelease(path);
            
            //// Debugging
            //NSLog(@"Drawing: %@ (%@) %@ -- points (%i)",
            //      character,
            //      characterDNA,
            //      NSStringFromRange(range),
            //      (int)pointsForCharacter.count);
        }
    }
}

@end
