//
//  TSRightButton.m
//
//  Created by Tim Schröder on 27.12.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//  see http://blog.timschroeder.net/code/
//

#import "TSRightButton.h"

#define roundedRadius 3.0 // Radius of the rounded corners of the button
#define triangleWidth 12.0 // Width of the arrow, should be half of the button's height
#define triangleHeightRatio 2.0 // Ratio of triangle (arrow) Width to button height

#pragma mark -
#pragma mark TSRightButtonCell Interface

@interface TSRightButtonCell : NSButtonCell

@end


#pragma mark -
#pragma mark TSRightButtonCell Implementation

@implementation TSRightButtonCell

// Helper method for modifying NSRects
-(NSRect)modifyRect:(NSRect)frame
             deltaX:(float)deltaX
             deltaY:(float)deltaY
             deltaW:(float)deltaW
             deltaH:(float)deltaH
{
    NSRect result = frame;
    result.origin.x = result.origin.x + deltaX;
    result.origin.y = result.origin.y + deltaY;
    result.size.width = result.size.width + deltaW;
    result.size.height = result.size.height + deltaH;
    return result;
}

// Helper method, constructs bezierPath
-(NSBezierPath*)bezierPathForRect:(NSRect)frame
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(frame.origin.x+roundedRadius, frame.origin.y)];
    [path lineToPoint:NSMakePoint(frame.origin.x+frame.size.width-triangleWidth,frame.origin.y)];
    [path lineToPoint:NSMakePoint(frame.origin.x+frame.size.width, (frame.origin.y+(frame.size.height/triangleHeightRatio)))];
    [path lineToPoint:NSMakePoint(frame.origin.x+frame.size.width-triangleWidth, frame.origin.y+frame.size.height)];
    
    // Bottom left corner
    NSPoint c1org = NSMakePoint(frame.origin.x+roundedRadius, frame.origin.y+frame.size.height);
    [path lineToPoint:c1org];
    NSPoint c1end = NSMakePoint(frame.origin.x, frame.origin.y+frame.size.height-roundedRadius);
    [path curveToPoint:c1end
         controlPoint1:NSMakePoint(c1org.x-roundedRadius, c1org.y)
         controlPoint2:c1end];
    
    // Top left corner
    NSPoint c2org = NSMakePoint(frame.origin.x, frame.origin.y+roundedRadius);
    [path lineToPoint:c2org];
    NSPoint c2end = NSMakePoint(frame.origin.x+roundedRadius, frame.origin.y);
    [path curveToPoint:c2end
         controlPoint1:NSMakePoint(c2org.x,c2org.y-roundedRadius)
         controlPoint2:c2end];
    
    [path closePath];
    return path;
}

// Draws the button
- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    // Background gradient
    [NSGraphicsContext saveGraphicsState];
    NSRect backgroundRect = NSInsetRect(frame, 3.0, 3.0);
    NSBezierPath *backgroundPath = [self bezierPathForRect:backgroundRect];
    NSGradient *backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                      [NSColor colorWithDeviceWhite:0.98 alpha:1.0], 0.0,
                                      [NSColor colorWithDeviceWhite:0.93 alpha:1.0], 1.0,
                                      nil];
    [backgroundGradient drawInBezierPath:backgroundPath angle:90.0];
    [NSGraphicsContext restoreGraphicsState];
    
    
    // Draw overlay if button is pressed
    if([self isHighlighted]) {
        [NSGraphicsContext saveGraphicsState];
        NSRect highlightRect = [self modifyRect:NSInsetRect(frame, 0.5, 2.0)
                                         deltaX:0.0
                                         deltaY:0.0
                                         deltaW:0.0
                                         deltaH:-1.0];
        NSBezierPath *path =  [self bezierPathForRect:highlightRect];
        NSGradient *highlightGradientTop = [[NSGradient alloc] initWithColorsAndLocations:
                                            [NSColor colorWithDeviceWhite:0.73 alpha:1.0], 0.0,
                                            [NSColor colorWithDeviceWhite:0.78 alpha:0.8], 0.1,
                                            [NSColor colorWithDeviceWhite:0.82 alpha:0.8], 0.2,
                                            [NSColor colorWithDeviceWhite:0.85 alpha:0.8], 0.3,
                                            [NSColor colorWithDeviceWhite:0.87 alpha:0.8], 0.5,
                                            [NSColor colorWithDeviceWhite:0.91 alpha:0.8], 1.0,
                                            nil];
        
        [highlightGradientTop drawInBezierPath:path angle:90.0];
        [NSGraphicsContext restoreGraphicsState];
    } else {
        
        // Inner light stroke
        [NSGraphicsContext saveGraphicsState];
        NSRect lightStrokeRect = [self modifyRect:NSInsetRect(frame, 0.0, 2.0)
                                           deltaX:0.0
                                           deltaY:0.0
                                           deltaW:0.0
                                           deltaH:-1.0];
        [[NSColor colorWithDeviceWhite:1.0 alpha:1.0] setStroke];
        NSBezierPath *lightStrokePath = [self bezierPathForRect:lightStrokeRect];
        [lightStrokePath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    // Dark stroke
    [NSGraphicsContext saveGraphicsState];
    [[NSColor colorWithDeviceWhite:0.55 alpha:1.0] setStroke];
    NSRect strokeRect = [self modifyRect:NSInsetRect(frame, 0.5, 1.5)
                                  deltaX:0.0
                                  deltaY:0.0
                                  deltaW:0.0
                                  deltaH:-1.0];
    NSBezierPath *darkStrokePath = [self bezierPathForRect:strokeRect];
    [darkStrokePath stroke];
    [NSGraphicsContext restoreGraphicsState];
}

// Move text a bit to the left to ensure that it is displayed centered
- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    frame.size.width = frame.size.width - (triangleWidth/triangleHeightRatio);
    return ([super drawTitle:title withFrame:frame inView:controlView]);
}

// Draw custom focus ring
- (void)drawFocusRingMaskWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [NSGraphicsContext saveGraphicsState];
    NSRect focusRect = [self modifyRect:NSInsetRect(cellFrame, 0.0, 1.0)
                                 deltaX:0.0
                                 deltaY:0.0
                                 deltaW:+0.5
                                 deltaH:-1.0];
    NSBezierPath *focusPath = [self bezierPathForRect:focusRect];
    [focusPath fill];
    [NSGraphicsContext restoreGraphicsState];
}


@end


#pragma mark -
#pragma mark TSRightButton Implementation

@implementation TSRightButton

// Replace the default button cell with our custom class
- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSButtonCell *originalCell = [self cell];
        TSRightButtonCell *customCell = [[TSRightButtonCell alloc] init];
        customCell.bezelStyle = originalCell.bezelStyle;
        customCell.font = originalCell.font;
        customCell.title = originalCell.title;
        [customCell setEnabled:originalCell.isEnabled];
        [self setCell:customCell];
    }
    return self;
}


// Tests whether mouse click is inside the view or not
// Subclassing -hitTest: is necessary as the button doesn't have rectangular shape
- (NSView *)hitTest:(NSPoint)aPoint
{
    NSRect frame = [self frame];
    float x = aPoint.x-frame.origin.x;
    float y = aPoint.y-frame.origin.y;
    if ((x < 0.0) || (y < 0.0)) return nil;
    if ((x > frame.size.width) || (y > frame.size.height)) return nil;
    float delta = frame.size.width-x;
    if (delta < triangleWidth) {
        float verticalMiddle = (frame.size.height/triangleHeightRatio); // This calculation assumes that triangleWidth is half of the button's height
        float upperLimit = verticalMiddle+delta;
        float lowerLimit = verticalMiddle-delta;
        if ((y > upperLimit) || (y < lowerLimit)) return nil;
    }
    return ([super hitTest:aPoint]);
}


@end
