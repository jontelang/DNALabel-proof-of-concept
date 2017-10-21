//
//
//
//
//
//
//
//
//
//
//
// Warning
//
// This code is VERY much WIP/Trash/Throwaway/Attempt
// and is basically a predecessor to the DNALabel and
// the other files around the DNA thing. However, the
// test did have some nice working features so I decided
// to keep it in.
// It has
//  - Shows rendering in steps (each index)
//  - Random color per item while rendering
//
// Check out the VC, will make more sense..
//
//
//
//
//
//
//



#import <CoreText/CoreText.h>

//
//  ThaiLabel.m
//  thai-test-cgpath-nsstring-label
//
//  Created by Jonathan Winger-lang on 9/07/2017.
//  Copyright © 2017 jonathan. All rights reserved.
//

#import "TestLabel.h"

static int indexToRender = 0;
static NSMutableArray *types;
static NSMutableArray *actual_elements;

@interface CoolPath : NSObject
@property NSArray *points;
@property NSArray *offset;
@property NSString *type;
@end

@implementation CoolPath
-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ - %@", self.type, self.offset, self.points];
}
@end


@implementation NSString (explodable)
-(NSArray*)explode{
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[self length]];
    for (int i=0; i < [self length]; i++) {
        [characters addObject:[self substringWithRange:NSMakeRange(i, 1)]];
    }
    return characters;
}
-(void)explodePrettyPrint{
    NSMutableString *s = [@"[" mutableCopy];
    for (NSString *ss in [self explode]) {
        [s appendString:@" "];
        [s appendString:ss];
        [s appendString:@" "];
    }
    [s appendString:@"]"];
    //-NSLog(@"Text exploded: %@", s);
}
-(NSString*)explodePrettyPrintString{
    NSMutableString *s = [@"[" mutableCopy];
    for (NSString *ss in [self explode]) {
        [s appendString:@" "];
        [s appendString:ss];
        [s appendString:@" "];
    }
    [s appendString:@"]"];
    return s;
}
@end

@implementation TestLabel

static NSDictionary *mapping;
static int step;
static int step_now;
static BOOL gather;

-(void)awakeFromNib{
    [super awakeFromNib];
    //self.text = @"ก้ ก้ มก้ มก้่";
    //self.text = @"ก้่";
    //self.text = @"ก้่ ก ก่";
    //self.text = @"ก้ ก่ ก้่ ก่้ ก";
    //self.text = @"กก กข กฃ กค กฅ";
    //self.text = @"กขฃคฅฆงจฉชซฌญฎฏฐฑฒณดตถทธนบปผฝพฟภมยรลวศษสหฬอฮ";
    //self.text = @"ฎ้่ฏ่ฐ้ฑ่้ฒ้่ณ่ด้ต่้ถ่้ท่้ธ้่น่บ่ป้่ผ่ฝ้่";
    self.text = @"ก กำ กำ้ ก้ำ ก่ำ กำ่ ก่ำ้่";
    //self.text = @"กำ กิ";
    //self.text = @"กำ";
    gather = YES;
    step = 0;
    step_now = 0;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    mapping = @{ @"ม" : @[@YES,@NO,@NO],
                 @"ก" : @[@YES],
                 @"ด" : @[@YES,@NO],
                 @"ำ" : @[@YES,@NO,@YES],
                 @"้" : @[@YES,@NO],
                 @"่" : @[@YES] } ;
    
    //-NSLog(@"Self text: %@", self.text);
    //-NSLog(@"Self length: %i", (int)self.text.length);
    [self.text explodePrettyPrint];
    
    NSMutableArray *ranges = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.text.length; i++) {
        NSRange ra = [self.text rangeOfComposedCharacterSequenceAtIndex:i];
        
        NSValue *rangeAsValue = [NSValue valueWithRange:ra];
        if( [ranges containsObject:rangeAsValue] == NO ){
            [ranges addObject:rangeAsValue];
        }
        //-NSLog(@"   %@ = %@ = %@",
        //      [self.text substringWithRange:NSMakeRange(i, 1)],
        //      NSStringFromRange(ra),
        //      [self.text substringWithRange:ra]);
    }
    ////-NSLog(@"ranges: %@", ranges);
    
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           self.font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.text
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    //-NSLog(@"Runs in CTLine: %li\n---------", CFArrayGetCount(runArray));
    
    //CGMutablePathRef letters = CGPathCreateMutable();
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    int currentIndex = 0;
    
    int drawnsteps = 0;
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        //-NSLog(@" ");
        //-NSLog(@"runIndex: %li", runIndex);
        
        // Color per run
        //[[self r] setFill];
        
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        int cur_sub_range = 0;
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            //NSRange currange = [[ranges objectAtIndex:currentIndex] rangeValue];
            //-NSLog(@" runGlyphIndex: %li (%i)", runGlyphIndex, currentIndex);
            
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Color per glyph in run
            [[self r] setFill];
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                NSMutableArray *pathElements = [NSMutableArray array];
                
                //-NSLog(@"----- start path for glyph -----");
                ////-NSLog(@"  glyph: %@", [self.text substringWithRange:currange]);
                CGPathApply(letter, (__bridge void * _Nullable)(pathElements), getPointsFromBezier);
                //-NSLog(@"----- end path for glyph -----");
                
                for (CoolPath *p in actual_elements) {
                    if ( p.offset == nil ){
                        p.offset = @[@(position.x),@(position.y)];
                    }
                }
                
                
//                //-NSLog(@"  range: %@", NSStringFromRange(currange));
//                //-NSLog(@"  path elements: %i", (int)pathElements.count);
//                //-NSLog(@"  chars at index: %i", (int)currange.length);
//                //-NSLog(@"  chars at index: %@", [[self.text substringWithRange:currange] explodePrettyPrintString]);
                
                
                
                for (int i = 0; i<pathElements.count; i++) {
                    CGContextSaveGState(ctx);
                    CGContextTranslateCTM(ctx,position.x,0 + 80 + CGRectGetMidY(rect) - self.font.descender + position.y);
                    CGContextScaleCTM(ctx, 1, -1);
                    CGPathRef e = (__bridge CGPathRef)pathElements[i];
                    CGContextAddPath(ctx, e);
                    [[self r] setFill];
                    CGContextFillPath(ctx);
                    CGContextRestoreGState(ctx);
                    //
                }
                
                path = nil;
                CGPathRelease(path);
                
                CGPathRelease(letter);
                
                //-NSLog(@"  sub_range %i", cur_sub_range);
                cur_sub_range++;
            }
            
            currentIndex++;
        }
    }
    CFRelease(line);
    
    //-NSLog(@"gethered %i pathelements to draw", step);
    gather = NO;
    
    
    
    
    
    for (int i = 0; i < [[self.text explode] count]; i++) {
        NSString *xxx = [self.text explode][i];
        if( [xxx isEqualToString:@" "] ){
            continue;
        }
        
        //-NSLog(@"looking for sequence for %@: %@", xxx, [self sequenceForKey:xxx]);
        NSArray *pointsForCharacter = [self findPointsForChar:xxx];
        
        CGMutablePathRef pppath = CGPathCreateMutable();
        for (CoolPath *p in pointsForCharacter) {
            
            CGPoint position = CGPointMake([p.offset[0] floatValue], [p.offset[1] floatValue]);
            
            if( [p.type isEqualToString:@"0"] ){
                CGPathMoveToPoint(pppath, nil,
                                  position.x + [p.points[0] floatValue],
                                  position.y + [p.points[1] floatValue]);
            }
            else if( [p.type isEqualToString:@"1"] ){
                CGPathAddLineToPoint(pppath, nil,
                                     position.x + [p.points[0] floatValue],
                                     position.y + [p.points[1] floatValue]);
            }
            else if( [p.type isEqualToString:@"2"] ){
                CGPathAddQuadCurveToPoint(pppath, nil,
                                          position.x + [p.points[0] floatValue],
                                          position.y + [p.points[1] floatValue],
                                          position.x + [p.points[2] floatValue],
                                          position.y + [p.points[3] floatValue]);
            }
            else if( [p.type isEqualToString:@"3"] ){
                CGPathAddCurveToPoint(pppath, nil,
                                      position.x + [p.points[0] floatValue],
                                      position.y + [p.points[1] floatValue],
                                      position.x + [p.points[2] floatValue],
                                      position.y + [p.points[3] floatValue],
                                      position.x + [p.points[4] floatValue],
                                      position.y + [p.points[5] floatValue]);
            }
            else if( [p.type isEqualToString:@"4"] ){
                CGPathCloseSubpath(pppath);
            }
        }
        
        UIColor *fill = [self r];
        if( i == indexToRender ){
            // Random
        }else{
            fill = [UIColor grayColor];
        }
        
        CGContextSaveGState(ctx);
            CGContextTranslateCTM(ctx,0,0 - 80 + CGRectGetMidY(rect) - self.font.descender + 0);
            CGContextScaleCTM(ctx, 1, -1);
            CGContextAddPath(ctx, pppath);
            [fill setFill];
            CGContextFillPath(ctx);
            CGContextRestoreGState(ctx);
    }
}

-(NSArray*)findPointsForChar:(NSString*)characterToFind{
    NSMutableString *flattenedStuff = [[NSMutableString alloc] init];
    for (CoolPath *tmppath in actual_elements) {
        [flattenedStuff appendString:tmppath.type];
    }
    //-NSLog(@"flat: %@", flattenedStuff);
    NSString *sequence = [self sequenceForKey:characterToFind];
    NSRange r = [flattenedStuff rangeOfString:sequence];
    
    NSArray *returnableArray = [actual_elements subarrayWithRange:r];
    
    // ensure XX in XXYYYYYYXX is found second time (prevent grabbing 1st again)
    [actual_elements removeObjectsInRange:r];
    
    return returnableArray;
}

-(NSString*)sequenceForKey:(NSString*)chara{
    return @{
             @"่" : @"01114", // mai ek
             @"้" : @"0222222222221221224022224", // mai tho
             @"ำ" : @"01122221222240222222224022222224", // sara am
             
             @"ก" : @"012222221122111222112222222214",
             @"ข" : @"012211112222212222222222222222211221402222224",
             @"ฃ" : @"01221111222222222222222222222222211221402222224",
             @"ค" : @"012222222221112222222222222222224022222224",
             @"ฅ" : @"0222222222222211122222222222222222222222224022222224",
             @"ฆ" : @"02212211122222212222222222222222222222222222222222222402222224022212224",
             @"ง" : @"02222222211222221221222140222222224",
             @"จ" : @"0122222222212221222222122222212122122240222221224",
             @"ฉ" : @"0222211222221221222222222112222222212224022222224022224",
             @"ช" : @"0122111122222122222222222222221122122212222122221222240222222224",
             @"ซ" : @"022222222222222222222211221222122221222212222112211112222402222224",
             @"ฌ" : @"01122222212222222122222112221222222221222112222221224022212224022222224",
             @"ญ" : @"02221122222222240222111222222112211122112222211221222222224022222224",
             @"ฎ" : @"022222112212222222122211222222211222222222211112240222222224022222224",
             @"ฏ" : @"0122222112212222222122211222222211111112222222221221140222222224022224",
             @"ฐ" : @"02222221221111222222222122111122402221222122222222222122122222222122222222222224022222222402222224022224",
             @"ฑ" : @"0222222211122222111222222222222222222222222222402222224",
             @"ฒ" : @"01221112222221222222212222222222212222222221222221212122222222222224022212224022222224",
             @"ณ" : @"0221122222112212222222212221112222221222111221222122222212224022224022222224",
             @"ด" : @"0122222122222222222221222222222140222222224",
             @"ต" : @"0122222222222122122221222222121222222222222222214022222224",
             @"ถ" : @"0222222221222112222222211122222211224022222224",
             @"ท" : @"02222222211122222211122222140222222224",
             @"ธ" : @"0221222222221222222222212221111122124",
             @"น" : @"02222222212222111222222222221402222222240222224",
             @"บ" : @"021122111221111222222240222222224",
             @"ป" : @"021122111221111222222240222222224",
             @"ผ" : @"01111111222222211114022222224",
             @"ฝ" : @"01111111222222211114022222224",
             @"พ" : @"011112222222211111111140222222224",
             @"ฟ" : @"011112222222211111111140222222224",
             @"ภ" : @"022222222122211222222111222211224022222224",
             @"ม" : @"011222222122222221122222222122224022222222402122212224",
             @"ย" : @"022111221111222222222222222221112214022222224",
             @"ร" : @"02222222221222222222221222222212240222222224",
             @"ล" : @"022222222222221222211222221112222240222222224",
             @"ว" : @"02222222212222122224022222224",
             @"ศ" : @"022122221112222222122222222211222222224022222224",
             @"ษ" : @"02222222121112212211221111222222221122140222240222222224",
             @"ส" : @"022111222222222222222222122221122222212240222222224",
             @"ห" : @"022112222222212222212222222211122402222222240222222224",
             @"ฬ" : @"0111112222222211111112222222222212212402222222240222222224",
             @"อ" : @"02112222222221122122221222212240222222224",
             @"ฮ" : @"02222222212222122112222222221122221222402222222402222224"
             }[chara];
}

-(void)update{
    indexToRender += 1;
    [self setNeedsDisplay];
    //-NSLog(@"step_now: %i", step_now);
}

static CGMutablePathRef path;

void getPointsFromBezier(void *info, const CGPathElement *element){
    CGPoint *points = element->points;
    
    if(!types){types=[@[] mutableCopy];}
    if(!actual_elements){actual_elements=[@[] mutableCopy];}
    
    CoolPath *p = [[CoolPath alloc] init];
    
    
    
    BOOL log = YES;
    
    if ( element->type == kCGPathElementMoveToPoint ){
        if(log){
            ////-NSLog(@"kCGPathElementMoveToPoint (0)");
            //-NSLog(@"0");
        }
        [types addObject:@"kCGPathElementMoveToPoint"];
        
        path = CGPathCreateMutable();
        
        CGPoint *p0 = &points[0];
        CGPathMoveToPoint(path,
                          nil,
                          p0->x,
                          p0->y);
        
        p.type = @"0";
        p.points = @[@(p0->x),@(p0->y)];
    }
    
    else if ( element->type == kCGPathElementAddLineToPoint ){
        if(log){
            ////-NSLog(@"  kCGPathElementAddLineToPoint (1)");
            //-NSLog(@"1");
        }
        [types addObject:@"kCGPathElementAddLineToPoint"];
        p.type = @"1";
        CGPoint *p0 = &points[0];
        CGPathAddLineToPoint(path,
                             nil,
                             p0->x,
                             p0->y);
        p.points = @[@(p0->x),@(p0->y)];
    }
    
    else if ( element->type == kCGPathElementAddQuadCurveToPoint ){
        if(log){
            ////-NSLog(@"  kCGPathElementAddQuadCurveToPoint (2)");
            //-NSLog(@"2");
        }
        [types addObject:@"kCGPathElementAddQuadCurveToPoint"];
        p.type = @"2";
        CGPoint *p0 = &points[0]; // Control points for bezier path
        CGPoint *p1 = &points[1]; // Actual points
        CGPathAddQuadCurveToPoint(path,
                                  nil,
                                  p0->x,
                                  p0->y,
                                  p1->x,
                                  p1->y);
        p.points = @[@(p0->x),@(p0->y),@(p1->x),@(p1->y)];
    }
    
    else if ( element->type == kCGPathElementAddCurveToPoint ){
        if(log){
            ////-NSLog(@"  kCGPathElementAddCurveToPoint (3)");
            //-NSLog(@"3");
        }
        [types addObject:@"kCGPathElementAddCurveToPoint"];
        p.type = @"3";
        CGPoint *p0 = &points[0]; // Control point 1
        CGPoint *p1 = &points[1]; // Control point 2
        CGPoint *p2 = &points[2]; // Actual point
        CGPathAddCurveToPoint(path,
                              nil,
                              p0->x,
                              p0->y,
                              p1->x,
                              p1->y,
                              p2->x,
                              p2->y);
        p.points = @[@(p0->x),@(p0->y),@(p1->x),@(p1->y),@(p2->x),@(p2->y)];
    }
    
    else if ( element->type == kCGPathElementCloseSubpath ){
        if(log){
            ////-NSLog(@"kCGPathElementCloseSubpath (4)\n");
            //-NSLog(@"4\n");
        }
        [types addObject:@"kCGPathElementCloseSubpath"];
        p.type = @"4";
        p.points = nil;
        CGPathCloseSubpath(path);
        [((__bridge NSMutableArray*)info) addObject:(__bridge id _Nonnull)(path)];
        path = nil;
        CGPathRelease(path);
    }
    
    else {
        if(log){
            //-NSLog(@"Else ???");
        }
    }
    
    [actual_elements addObject:p];
    ////-NSLog(@"p = %@", [p description]);
}

-(UIColor*)r{
    return [UIColor colorWithRed:(20.0f+(float)(arc4random()%220))/255.0f
                           green:(20.0f+(float)(arc4random()%220))/255.0f
                            blue:(20.0f+(float)(arc4random()%220))/255.0f
                           alpha:1];
}

@end















































//#import <CoreText/CoreText.h>
//
////
////  ThaiLabel.m
////  thai-test-cgpath-nsstring-label
////
////  Created by Jonathan Winger-lang on 9/07/2017.
////  Copyright © 2017 jonathan. All rights reserved.
////
//
//#import "ThaiLabel.h"
//
//static NSMutableArray *types;
//static NSMutableArray *actual_elements;
//
//@interface CoolPath : NSObject
//@property NSArray *points;
//@property NSString *type;
//@end
//
//@implementation CoolPath
//-(NSString *)description{
//    return [NSString stringWithFormat:@"%@ - %@", self.type, self.points];
//}
//@end
//
//
//@implementation NSString (explodable)
//-(NSArray*)explode{
//    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[self length]];
//    for (int i=0; i < [self length]; i++) {
//        [characters addObject:[self substringWithRange:NSMakeRange(i, 1)]];
//    }
//    return characters;
//}
//-(void)explodePrettyPrint{
//    NSMutableString *s = [@"[" mutableCopy];
//    for (NSString *ss in [self explode]) {
//        [s appendString:@" "];
//        [s appendString:ss];
//        [s appendString:@" "];
//    }
//    [s appendString:@"]"];
//    //-NSLog(@"Text exploded: %@", s);
//}
//-(NSString*)explodePrettyPrintString{
//    NSMutableString *s = [@"[" mutableCopy];
//    for (NSString *ss in [self explode]) {
//        [s appendString:@" "];
//        [s appendString:ss];
//        [s appendString:@" "];
//    }
//    [s appendString:@"]"];
//    return s;
//}
//@end
//
//@implementation ThaiLabel
//
//static NSDictionary *mapping;
//static int step;
//static int step_now;
//static BOOL gather;
//
//-(void)awakeFromNib{
//    [super awakeFromNib];
////    self.text = @"ก้ ก้ มก้ มก้่";
//    //self.text = @"ก้่";
////    self.text = @"ก้่ ก ก่";
//    self.text = @"ก้ ก่ ก้่ ก่้ ก";
//    //self.text = @"กำ กิ";
//    gather = YES;
//    step = 0;
//    step_now = 0;
//}
//
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//
//    mapping = @{ @"ม" : @[@YES,@NO,@NO],
//                 @"ก" : @[@YES],
//                 @"ด" : @[@YES,@NO],
//                 @"ำ" : @[@YES,@NO,@YES],
//                 @"้" : @[@YES,@NO],
//                 @"่" : @[@YES] } ;
//
//    //-NSLog(@"Self text: %@", self.text);
//    //-NSLog(@"Self length: %i", (int)self.text.length);
//    [self.text explodePrettyPrint];
//
//    NSMutableArray *ranges = [[NSMutableArray alloc] init];
//    for (int i = 0; i < self.text.length; i++) {
//        NSRange ra = [self.text rangeOfComposedCharacterSequenceAtIndex:i];
//
//        NSValue *rangeAsValue = [NSValue valueWithRange:ra];
//        if( [ranges containsObject:rangeAsValue] == NO ){
//            [ranges addObject:rangeAsValue];
//        }
//        //-NSLog(@"   %@ = %@ = %@",
//              [self.text substringWithRange:NSMakeRange(i, 1)],
//              NSStringFromRange(ra),
//              [self.text substringWithRange:ra]);
//    }
//    ////-NSLog(@"ranges: %@", ranges);
//
//
//    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
//                           self.font, kCTFontAttributeName,
//                           nil];
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.text
//                                                                     attributes:attrs];
//    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
//    CFArrayRef runArray = CTLineGetGlyphRuns(line);
//    //-NSLog(@"Runs in CTLine: %li\n---------", CFArrayGetCount(runArray));
//
//    //CGMutablePathRef letters = CGPathCreateMutable();
//
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//
//    int currentIndex = 0;
//
//    int drawnsteps = 0;
//
//    // for each RUN
//    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
//    {
//        //-NSLog(@" ");
//        //-NSLog(@"runIndex: %li", runIndex);
//
//        // Color per run
//        //[[self r] setFill];
//
//        // Get FONT for this run
//        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
//        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
//
//        // for each GLYPH in run
//        int cur_sub_range = 0;
//        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
//        {
//            NSRange currange = [[ranges objectAtIndex:currentIndex] rangeValue];
//            //-NSLog(@" runGlyphIndex: %li (%i)", runGlyphIndex, currentIndex);
//
//            // get Glyph & Glyph-data
//            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
//            CGGlyph glyph;
//            CGPoint position;
//            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
//            CTRunGetPositions(run, thisGlyphRange, &position);
//
//            // Color per glyph in run
//            [[self r] setFill];
//
//            // Get PATH of outline
//            {
//                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
//                NSMutableArray *pathElements = [NSMutableArray array];
//                
//                //-NSLog(@"----- start path for glyph -----");
//                CGPathApply(letter, (__bridge void * _Nullable)(pathElements), getPointsFromBezier);
//                //-NSLog(@"----- end path for glyph -----");
//
//                //-NSLog(@"  glyph: %@", [self.text substringWithRange:currange]);
//                //-NSLog(@"  range: %@", NSStringFromRange(currange));
//                //-NSLog(@"  path elements: %i", (int)pathElements.count);
//                //-NSLog(@"  chars at index: %i", (int)currange.length);
//                //-NSLog(@"  chars at index: %@", [[self.text substringWithRange:currange] explodePrettyPrintString]);
//
//                //
//                // Find specific order or stuffs
//                //
//                
//                for (NSString *xxx in [[self.text substringWithRange:currange] explode]) {
//                    if( [xxx isEqualToString:@" "] ){
//                        continue;
//                    }
//                    
//                    //-NSLog(@"looking for sequence for %@: %@", xxx, [self sequenceForKey:xxx]);
//                    NSArray *pointsForCharacter = [self findPointsForChar:xxx];
//                    
//                    CGMutablePathRef pppath = CGPathCreateMutable();
//                    for (CoolPath *p in pointsForCharacter) {
//                        if( [p.type isEqualToString:@"0"] ){
//                            CGPathMoveToPoint(pppath, nil,
//                                              position.x + [p.points[0] floatValue],
//                                              position.y + [p.points[1] floatValue]);
//                        }
//                        else if( [p.type isEqualToString:@"1"] ){
//                            CGPathAddLineToPoint(pppath, nil,
//                                                 position.x + [p.points[0] floatValue],
//                                                 position.y + [p.points[1] floatValue]);
//                        }
//                        else if( [p.type isEqualToString:@"2"] ){
//                            CGPathAddQuadCurveToPoint(pppath, nil,
//                                                 position.x + [p.points[0] floatValue],
//                                                 position.y + [p.points[1] floatValue],
//                                                 position.x + [p.points[2] floatValue],
//                                                 position.y + [p.points[3] floatValue]);
//                        }
//                        else if( [p.type isEqualToString:@"3"] ){
//                            CGPathAddCurveToPoint(pppath, nil,
//                                                 position.x + [p.points[0] floatValue],
//                                                 position.y + [p.points[1] floatValue],
//                                                 position.x + [p.points[2] floatValue],
//                                                 position.y + [p.points[3] floatValue],
//                                                 position.x + [p.points[4] floatValue],
//                                                 position.y + [p.points[5] floatValue]);
//                        }
//                        else if( [p.type isEqualToString:@"4"] ){
//                            CGPathCloseSubpath(pppath);
//                        }
//                    }
//                    
//                    UIColor *fill = [self r];
//                    //if( [xxx isEqualToString:@"ก"] == YES ){
//                    //    fill = [UIColor clearColor];
//                    //}
//                    
//                    CGContextSaveGState(ctx);
//                        CGContextTranslateCTM(ctx,0,0 - 80 + CGRectGetMidY(rect) - self.font.descender + 0);
//                        //CGContextTranslateCTM(ctx,position.x,0 - 80 + CGRectGetMidY(rect) - self.font.descender + position.y);
//                        CGContextScaleCTM(ctx, 1, -1);
//                        CGContextAddPath(ctx, pppath);
//                        [fill setFill];
//                        CGContextFillPath(ctx);
//                        CGContextRestoreGState(ctx);
//                }
//                
//                
//                for (int i = 0; i<pathElements.count; i++) {
//                    CGContextSaveGState(ctx);
//                        CGContextTranslateCTM(ctx,position.x,0 + 80 + CGRectGetMidY(rect) - self.font.descender + position.y);
//                        CGContextScaleCTM(ctx, 1, -1);
//                        CGPathRef e = (__bridge CGPathRef)pathElements[i];
//                        CGContextAddPath(ctx, e);
//                        [[self r] setFill];
//                        CGContextFillPath(ctx);
//                        CGContextRestoreGState(ctx);
//                    //
//                }
//
//                path = nil;
//                CGPathRelease(path);
//                
//                CGPathRelease(letter);
//
//                //-NSLog(@"  sub_range %i", cur_sub_range);
//                cur_sub_range++;
//            }
//
//            currentIndex++;
//        }
//    }
//    CFRelease(line);
//
//    //-NSLog(@"gethered %i pathelements to draw", step);
//    gather = NO;
//}
//
//-(NSArray*)findPointsForChar:(NSString*)characterToFind{
//    NSMutableString *flattenedStuff = [[NSMutableString alloc] init];
//    for (CoolPath *tmppath in actual_elements) {
//        [flattenedStuff appendString:tmppath.type];
//    }
//    //-NSLog(@"flat: %@", flattenedStuff);
//    NSString *sequence = [self sequenceForKey:characterToFind];
//    NSRange r = [flattenedStuff rangeOfString:sequence];
//    
//    NSArray *returnableArray = [actual_elements subarrayWithRange:r];
//    
//    // ensure XX in XXYYYYYYXX is found second time (prevent grabbing 1st again)
//    [actual_elements removeObjectsInRange:r];
//    
//    return returnableArray;
//}
//
//-(NSString*)sequenceForKey:(NSString*)chara{
//    return @{
//             @"่" : @"01114", // mai ek
//             @"้" : @"0222222222221221224022224", // mai tho
//             @"ก" : @"012222221122111222112222222214", // go gai
//             @"ำ" : @"01122221222240222222224022222224" // sara am
//            }[chara];
//}
//
//-(void)update{
//    step_now += 1;
//    [self setNeedsDisplay];
//    //-NSLog(@"step_now: %i", step_now);
//}
//
//static CGMutablePathRef path;
//
//void getPointsFromBezier(void *info, const CGPathElement *element){
//    CGPoint *points = element->points;
//    
//    if(!types){types=[@[] mutableCopy];}
//    if(!actual_elements){actual_elements=[@[] mutableCopy];}
//
//    CoolPath *p = [[CoolPath alloc] init];
//    
//    
//    
//    BOOL log = YES;
//
//    if ( element->type == kCGPathElementMoveToPoint ){
//        if(log) //-NSLog(@"kCGPathElementMoveToPoint (0)");
//        [types addObject:@"kCGPathElementMoveToPoint"];
//        
//        path = CGPathCreateMutable();
//        
//        CGPoint *p0 = &points[0];
//        CGPathMoveToPoint(path,
//                          nil,
//                          p0->x,
//                          p0->y);
//        
//        p.type = @"0";
//        p.points = @[@(p0->x),@(p0->y)];
//    }
//    
//    else if ( element->type == kCGPathElementAddLineToPoint ){
//        if(log) //-NSLog(@"  kCGPathElementAddLineToPoint (1)");
//        [types addObject:@"kCGPathElementAddLineToPoint"];
//        p.type = @"1";
//        CGPoint *p0 = &points[0];
//        CGPathAddLineToPoint(path,
//                             nil,
//                             p0->x,
//                             p0->y);
//        p.points = @[@(p0->x),@(p0->y)];
//    }
//    
//    else if ( element->type == kCGPathElementAddQuadCurveToPoint ){
//        if(log) //-NSLog(@"  kCGPathElementAddQuadCurveToPoint (2)");
//        [types addObject:@"kCGPathElementAddQuadCurveToPoint"];
//        p.type = @"2";
//        CGPoint *p0 = &points[0]; // Control points for bezier path
//        CGPoint *p1 = &points[1]; // Actual points
//        CGPathAddQuadCurveToPoint(path,
//                                  nil,
//                                  p0->x,
//                                  p0->y,
//                                  p1->x,
//                                  p1->y);
//        p.points = @[@(p0->x),@(p0->y),@(p1->x),@(p1->y)];
//    }
//    
//    else if ( element->type == kCGPathElementAddCurveToPoint ){
//        if(log) //-NSLog(@"  kCGPathElementAddCurveToPoint (3)");
//        [types addObject:@"kCGPathElementAddCurveToPoint"];
//        p.type = @"3";
//        CGPoint *p0 = &points[0]; // Control point 1
//        CGPoint *p1 = &points[1]; // Control point 2
//        CGPoint *p2 = &points[2]; // Actual point
//        CGPathAddCurveToPoint(path,
//                              nil,
//                              p0->x,
//                              p0->y,
//                              p1->x,
//                              p1->y,
//                              p2->x,
//                              p2->y);
//        p.points = @[@(p0->x),@(p0->y),@(p1->x),@(p1->y),@(p2->x),@(p2->y)];
//    }
//    
//    else if ( element->type == kCGPathElementCloseSubpath ){
//        if(log) //-NSLog(@"kCGPathElementCloseSubpath (4)\n");
//        [types addObject:@"kCGPathElementCloseSubpath"];
//        p.type = @"4";
//        p.points = nil;
//        CGPathCloseSubpath(path);
//        [((__bridge NSMutableArray*)info) addObject:(__bridge id _Nonnull)(path)];
//        path = nil;
//        CGPathRelease(path);
//    }
//    
//    else {
//        if(log) //-NSLog(@"Else ???");
//    }
//    
//    [actual_elements addObject:p];
//    ////-NSLog(@"p = %@", [p description]);
//}
//
//-(UIColor*)r{
//    return [UIColor colorWithRed:(20.0f+(float)(arc4random()%220))/255.0f
//                           green:(20.0f+(float)(arc4random()%220))/255.0f
//                            blue:(20.0f+(float)(arc4random()%220))/255.0f
//                           alpha:1];
//}
//
//@end












































































//
// This solution didnt work well because glyph order is not same as actual string characters order..
//
//#import <CoreText/CoreText.h>
//
////
////  ThaiLabel.m
////  thai-test-cgpath-nsstring-label
////
////  Created by Jonathan Winger-lang on 9/07/2017.
////  Copyright © 2017 jonathan. All rights reserved.
////
//
//#import "ThaiLabel.h"
//
//@implementation NSString (explodable)
//-(NSArray*)explode{
//    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[self length]];
//    for (int i=0; i < [self length]; i++) {
//        [characters addObject:[self substringWithRange:NSMakeRange(i, 1)]];
//    }
//    return characters;
//}
//-(void)explodePrettyPrint{
//    NSMutableString *s = [@"[" mutableCopy];
//    for (NSString *ss in [self explode]) {
//        [s appendString:@" "];
//        [s appendString:ss];
//        [s appendString:@" "];
//    }
//    [s appendString:@"]"];
//    //-NSLog(@"Text exploded: %@", s);
//}
//-(NSString*)explodePrettyPrintString{
//    NSMutableString *s = [@"[" mutableCopy];
//    for (NSString *ss in [self explode]) {
//        [s appendString:@" "];
//        [s appendString:ss];
//        [s appendString:@" "];
//    }
//    [s appendString:@"]"];
//    return s;
//}
//@end
//
//@implementation ThaiLabel
//
//static NSDictionary *mapping;
//static int step;
//static int step_now;
//static BOOL gather;
//
//-(void)awakeFromNib{
//    [super awakeFromNib];
////    self.text = @"ก้ ก้ มก้ มก้่";
////    self.text = @"ก้่";
//    self.text = @"กำ";
//    gather = YES;
//    step = 0;
//    step_now = 0;
//}
//
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    mapping = @{ @"ม" : @[@YES,@NO,@NO],
//                 @"ก" : @[@YES],
//                 @"ด" : @[@YES,@NO],
//                 @"ำ" : @[@YES,@NO,@YES],
//                 @"้" : @[@YES,@NO],
//                 @"่" : @[@YES] } ;
//    
//    //-NSLog(@"Self text: %@", self.text);
//    //-NSLog(@"Self length: %i", (int)self.text.length);
//    [self.text explodePrettyPrint];
//    
//    NSMutableArray *ranges = [[NSMutableArray alloc] init];
//    for (int i = 0; i < self.text.length; i++) {
//        NSRange ra = [self.text rangeOfComposedCharacterSequenceAtIndex:i];
//        
//        NSValue *rangeAsValue = [NSValue valueWithRange:ra];
//        if( [ranges containsObject:rangeAsValue] == NO ){
//            [ranges addObject:rangeAsValue];
//        }
//        //-NSLog(@"   %@ = %@ = %@",
//              [self.text substringWithRange:NSMakeRange(i, 1)],
//              NSStringFromRange(ra),
//              [self.text substringWithRange:ra]);
//    }
//    //-NSLog(@"ranges: %@", ranges);
//    
//    
//    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
//                           self.font, kCTFontAttributeName,
//                           nil];
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.text
//                                                                     attributes:attrs];
//    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
//    CFArrayRef runArray = CTLineGetGlyphRuns(line);
//    //-NSLog(@"Runs in CTLine: %li\n---------", CFArrayGetCount(runArray));
//    
//    //CGMutablePathRef letters = CGPathCreateMutable();
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    int currentIndex = 0;
//    
//    int drawnsteps = 0;
//    
//    // for each RUN
//    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
//    {
//        //-NSLog(@" ");
//        //-NSLog(@"runIndex: %li", runIndex);
//        
//        // Color per run
//        //[[self r] setFill];
//        
//        // Get FONT for this run
//        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
//        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
//        
//        // for each GLYPH in run
//        int cur_sub_range = 0;
//        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
//        {
//            NSRange currange = [[ranges objectAtIndex:currentIndex] rangeValue];
//            //-NSLog(@" runGlyphIndex: %li (%i)", runGlyphIndex, currentIndex);
//            
//            // get Glyph & Glyph-data
//            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
//            CGGlyph glyph;
//            CGPoint position;
//            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
//            CTRunGetPositions(run, thisGlyphRange, &position);
//            
//            // Color per glyph in run
//            [[self r] setFill];
//            
//            // Get PATH of outline
//            {
//                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
//                NSMutableArray *pathElements = [NSMutableArray array];
//                CGPathApply(letter, (__bridge void * _Nullable)(pathElements), getPointsFromBezier);
//                
//                //-NSLog(@"  glyph: %@", [self.text substringWithRange:currange]);
//                //-NSLog(@"  range: %@", NSStringFromRange(currange));
//                //-NSLog(@"  path elements: %i", (int)pathElements.count);
//                //-NSLog(@"  chars at index: %i", (int)currange.length);
//                //-NSLog(@"  chars at index: %@", [[self.text substringWithRange:currange] explodePrettyPrintString]);
//                
//                if(gather){
//                    step += pathElements.count;
//                }
//                
//                //
//                //
//                //
//                NSMutableArray *sequence = [@[] mutableCopy];
//                for (NSString *cr in [[self.text substringWithRange:currange] explode]) {
////                    //-NSLog(@"--- building sequence");
////                    //-NSLog(@" key: %@   sequence: %@ ", cr, mapping[cr]);
////                    //-NSLog(@"--- ");
//                    [sequence addObjectsFromArray:mapping[cr]];
//                }
//                //-NSLog(@"seq: %@", sequence);
//                
//                for (int i = 0; i < sequence.count; i++) {
//                    
//                    //if( drawnsteps < step_now ){
//                        [[self r]setFill];
//                        CGContextSaveGState(ctx);
//                        CGContextTranslateCTM(ctx,position.x,0 - 50 + CGRectGetMidY(rect) - self.font.descender + position.y);
//                        CGContextScaleCTM(ctx, 1, -1);
//                        
//                        CGPathRef e = (__bridge CGPathRef)pathElements[i];
//                        CGContextAddPath(ctx, e);
//                        
//                        if ( [sequence[i] boolValue] == YES ) {
//                            [[UIColor blackColor] setFill];
//                        }else{
//                            // Lol
//                            [[UIColor redColor] setFill];
//                        }
//                        
//                        CGContextFillPath(ctx);
//                        CGContextRestoreGState(ctx);
//                        
//                        //drawnsteps += 1;
//                    //}
//                }
//                
//                CGPathRelease(letter);
//                
//                //-NSLog(@"  sub_range %i", cur_sub_range);
//                cur_sub_range++;
//                
//            }
//            
//            currentIndex++;
//        }
//    }
//    CFRelease(line);
//    
//    //-NSLog(@"gethered %i pathelements to draw", step);
//    gather = NO;
//}
//
//-(void)update{
//    step_now += 1;
//    [self setNeedsDisplay];
//    //-NSLog(@"step_now: %i", step_now);
//}
//
//static CGMutablePathRef path;
//
//void getPointsFromBezier(void *info, const CGPathElement *element){
//    CGPoint *points = element->points;
//    
//    BOOL log = NO;
//    
//    if ( element->type == kCGPathElementMoveToPoint ){
//        if(log) //-NSLog(@"kCGPathElementMoveToPoint");
//        path = CGPathCreateMutable();
//        
//        CGPoint *p0 = &points[0];
//        CGPathMoveToPoint(path,
//                          nil,
//                          p0->x,
//                          p0->y);
//    }
//    
//    else if ( element->type == kCGPathElementAddLineToPoint ){
//        if(log) //-NSLog(@"kCGPathElementAddLineToPoint");
//        CGPoint *p0 = &points[0];
//        CGPathAddLineToPoint(path,
//                             nil,
//                             p0->x,
//                             p0->y);
//    }
//    
//    else if ( element->type == kCGPathElementAddQuadCurveToPoint ){
//        if(log) //-NSLog(@"kCGPathElementAddQuadCurveToPoint");
//        CGPoint *p0 = &points[0]; // Control points for bezier path
//        CGPoint *p1 = &points[1]; // Actual points
//        CGPathAddQuadCurveToPoint(path,
//                                  nil,
//                                  p0->x,
//                                  p0->y,
//                                  p1->x,
//                                  p1->y);
//    }
//    
//    else if ( element->type == kCGPathElementAddCurveToPoint ){
//        if(log) //-NSLog(@"kCGPathElementAddCurveToPoint");
//        CGPoint *p0 = &points[0]; // Control point 1
//        CGPoint *p1 = &points[1]; // Control point 2
//        CGPoint *p2 = &points[2]; // Actual point
//        CGPathAddCurveToPoint(path,
//                              nil,
//                              p0->x,
//                              p0->y,
//                              p1->x,
//                              p1->y,
//                              p2->x,
//                              p2->y);
//    }
//    
//    else if ( element->type == kCGPathElementCloseSubpath ){
//        if(log) //-NSLog(@"kCGPathElementCloseSubpath");
//        CGPathCloseSubpath(path);
//        [((__bridge NSMutableArray*)info) addObject:(__bridge id _Nonnull)(path)];
//        path = nil;
//        CGPathRelease(path);
//    }
//    
//    else {
//        if(log) //-NSLog(@"Else ???");
//    }
//}
//
//-(UIColor*)r{
//    return [UIColor colorWithRed:(20.0f+(float)(arc4random()%220))/255.0f
//                           green:(20.0f+(float)(arc4random()%220))/255.0f
//                            blue:(20.0f+(float)(arc4random()%220))/255.0f
//                           alpha:1];
//}
//
//@end
