//
//  Pathfinder_Tools.h
//  Pathfinder Tools
//
//  Created by Andrew Manzyk on 04/10/2023.
//  Copyright © 2023 Andrew Manzyk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GlyphsToolDrawProtocol.h>
#import <GlyphsCore/GlyphsToolEventProtocol.h>
#import <GlyphsCore/GlyphsPathPlugin.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSPath.h>
#import <GlyphsCore/GSNode.h>

@interface Pathfinder_Tools : GlyphsPathPlugin {
    double extrudeAngle;
    double extrudeDistance;
    int extrudeQuantization;
    BOOL canExtrude;
    BOOL selectionValid;
    BOOL crossesBounds;
    BOOL extrudeInfo;
    BOOL isMerging;
    BOOL isSubtracting;
    BOOL isIntersecting;
    BOOL isExcluding;
    GSPathDirection pathDirection;
    NSPoint mousePosition;
    NSPoint midpoint;
    NSBezierPath *bgPath;
    GSLayer *layer;
    NSMutableArray *sortedSelection;
    NSMutableArray *sortedSelectionCoords;
    NSString *extrudeQuantizationString;
    NSTextField *valueField;
}

- (void)mergeSelectedPaths;
- (void)subtractSelectedPaths;
- (void)intersectSelectedPaths;
- (void)excludeSelectedPaths;

@end
