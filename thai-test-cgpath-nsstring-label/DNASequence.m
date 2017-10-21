//
//  DNASequence.m
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 5/08/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import "DNASequence.h"
#import "DNAPoint.h"
#import <CoreText/CoreText.h>

@implementation DNASequence

-(id)initWithString:(NSString*)text_ font:(UIFont*)font_{
    if( self = [super init] ){
        self.text = text_;
        self.font = font_;
        [self buildDNASequence];
    }
    return self;
}

-(void)buildDNASequence{
    NSLog(@"[DNASequence] Start gathering DNAPoints (via CGPaths)");
    NSLog(@"[DNASequence] Text: %@", self.text);
    NSLog(@"[DNASequence] Font: %@", self.font);
    
    self.allDNAPoints = [[NSMutableArray alloc] init];
    
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)[self asAttributedString]);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++){
        
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++){
            
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            CGPathRef glyphPath = CTFontCreatePathForGlyph(runFont, glyph, NULL);
            
            // "Apply" the path so that we can capture each point and position
            NSMutableArray *temporaryGlyphPoints = [[NSMutableArray alloc] init];
            CGPathApply(glyphPath, (__bridge void * _Nullable)(temporaryGlyphPoints), iterateCGPathPoints);
            
            // Set the position for later correct writing-position
            for (DNAPoint *point in temporaryGlyphPoints) {
                [point setPosition:position];
            }
            
            // Add to 'global'
            [self.allDNAPoints addObjectsFromArray:temporaryGlyphPoints];
        }
    }
    
    // After we gathered it all, generate the points cumulative DNA for speedy lookup
    self.currentDNA = @"";
    for (DNAPoint *point in self.allDNAPoints) {
        self.currentDNA = [self.currentDNA stringByAppendingString:point.elementTypeNumber];
    }
    
    NSLog(@"[DNASequence] Sequence gathered: %@", self.currentDNA);
}

void iterateCGPathPoints(void *data, const CGPathElement *element){
    DNAPoint *dnaPoint = [[DNAPoint alloc] init];
    dnaPoint.elementType = element->type;
    dnaPoint.elementPoint0 = CGPointMake(element->points[0].x,element->points[0].y);
    dnaPoint.elementPoint1 = CGPointMake(element->points[1].x,element->points[1].y);
    dnaPoint.elementPoint2 = CGPointMake(element->points[2].x,element->points[2].y);
    NSMutableArray *tempArrayReference = (__bridge NSMutableArray*)data;
    [tempArrayReference addObject:dnaPoint];
}

-(NSAttributedString*)asAttributedString{
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:self.font, kCTFontAttributeName, nil];
    return [[NSAttributedString alloc] initWithString:self.text attributes:attrs];
}

@end
