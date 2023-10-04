//
//  Pathfinder_Tools.m
//  Pathfinder Tools
//
//  Created by Andrew Manzyk on 04/10/2023.
//  Copyright © 2023 Andrew Manzyk. All rights reserved.
//

#import "Pathfinder_Tools.h"

@implementation Pathfinder_Tools

- (id)init {
    self = [super init];
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    if (thisBundle) {
        // The toolbar icon:
        _toolBarIcon = [[NSImage alloc] initWithContentsOfFile:[thisBundle pathForImageResource:@"ToolbarIconTemplate"]];
        [_toolBarIcon setTemplate:YES];
    }
    extrudeInfo = YES;
    canExtrude = NO;
    selectionValid = NO;
    self.dragging = NO;
    extrudeAngle = 0;
    extrudeDistance = 0;
    extrudeQuantization = 0;
    sortedSelectionCoords = [[NSMutableArray alloc] init];

    return self;
}


- (void)addMenuItemsForEvent:(NSEvent *)theEvent toMenu:(NSMenu *)theMenu {
    NSMenuItem *mergeItem = [[NSMenuItem alloc] initWithTitle:@"Merge" action:@selector(mergeMenuItemSelected:) keyEquivalent:@""];
    NSMenuItem *subtractItem = [[NSMenuItem alloc] initWithTitle:@"Subtract" action:@selector(subtractMenuItemSelected:) keyEquivalent:@""];
    NSMenuItem *intersectItem = [[NSMenuItem alloc] initWithTitle:@"Intersect" action:@selector(intersectMenuItemSelected:) keyEquivalent:@""];
    NSMenuItem *excludeItem = [[NSMenuItem alloc] initWithTitle:@"Exclude" action:@selector(excludeMenuItemSelected:) keyEquivalent:@""];
    
    [theMenu addItem:mergeItem];
    [theMenu addItem:subtractItem];
    [theMenu addItem:intersectItem];
    [theMenu addItem:excludeItem];
}

- (void)mergeSelectedPaths {
    if (!canExtrude || !selectionValid) {
        return;
    }
    
    GSLayer *activeLayer = [_editViewController.graphicView activeLayer];
    GSPath *mergedPath = [GSPath new];
    
    for (GSNode *node in sortedSelection) {
        [mergedPath addNode:[node copy]];  // Создаем копии узлов
    }
    
    [activeLayer clearSelection];
    [activeLayer addPath:mergedPath];
    
    NSLog(@"Merge button pressed. Paths merged.");
}

- (void)subtractSelectedPaths {
    if (!canExtrude || !selectionValid) {
        return;
    }
    
    // Создаем копию активного слоя
    GSLayer *activeLayer = [_editViewController.graphicView activeLayer];
    GSLayer *copyLayer = [activeLayer copy];
    
    // Удаляем верхний путь из нижнего
    [copyLayer.paths removeObjectsInArray:[sortedSelection copy]];
    
    [activeLayer clearSelection];
    
    // Заменяем активный слой скопированным слоем
    [activeLayer setPaths:copyLayer.paths];
    
    NSLog(@"Subtract button pressed.");
}

- (void)intersectSelectedPaths {
    if (!canExtrude || !selectionValid) {
        return;
    }
    
    // Создаем новый путь для пересечения
    GSPath *intersectedPath = [GSPath new];
    
    // Исходим из того, что первый путь из выбранных - это основной путь
    GSPath *mainPath = [sortedSelection[0] parent];
    
    // Перебираем узлы в основном пути
    for (GSNode *node in [mainPath nodes]) {
        BOOL isInAllPaths = YES;
        
        // Проверяем, есть ли этот узел в остальных выбранных путях
        for (NSInteger i = 1; i < [sortedSelection count]; i++) {
            GSPath *path = [sortedSelection[i] parent];
            
            if (![path containsNode:node]) {
                isInAllPaths = NO;
                break;
            }
        }
        
        // Если узел есть во всех путях, добавляем его в новый путь
        if (isInAllPaths) {
            [intersectedPath addNode:[node copy]];
        }
    }
    
    // Очищаем выделение
    [[_editViewController.graphicView activeLayer] clearSelection];
    
    // Добавляем новый путь на активный слой
    [[_editViewController.graphicView activeLayer] addPath:intersectedPath];
    
    NSLog(@"Intersect button pressed.");
}

- (void)excludeSelectedPaths {
    if (!canExtrude || !selectionValid) {
        return;
    }
    
    // Создаем новый путь для исключения
    GSPath *excludedPath = [GSPath new];
    
    // Исходим из того, что первый путь из выбранных - это основной путь
    GSPath *mainPath = [sortedSelection[0] parent];
    
    // Добавляем все узлы основного пути в новый путь
    for (GSNode *node in [mainPath nodes]) {
        [excludedPath addNode:[node copy]];
    }
    
    // Исключаем узлы остальных выбранных путей
    for (NSInteger i = 1; i < [sortedSelection count]; i++) {
        GSPath *path = [sortedSelection[i] parent];
        
        for (GSNode *node in [path nodes]) {
            [excludedPath removeNode:node];
        }
    }
    
    // Очищаем выделение
    [[_editViewController.graphicView activeLayer] clearSelection];
    
    // Добавляем новый путь на активный слой
    [[_editViewController.graphicView activeLayer] addPath:excludedPath];
    
    NSLog(@"Exclude button pressed.");
}

@end
