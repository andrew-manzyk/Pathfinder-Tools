//
//  Pathfinder_Tools.m
//  Pathfinder Tools
//
//  Created by Andrew Manzyk on 04/10/2023.
//  Copyright © 2023 Andrew Manzyk. All rights reserved.
//

#import "Pathfinder_Tools.h"

@implementation Pathfinder_Tools

- (NSImage *)imageFromResource:(NSString *)resourceName ofType:(NSString *)fileType {
    // Assuming icons are in a folder named "icons" within the bundle
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:resourceName ofType:fileType inDirectory:@"icons"];
    
    if (resourcePath) {
        NSURL *resourceURL = [NSURL fileURLWithPath:resourcePath];
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:resourceURL];
        return image;
    } else {
        NSLog(@"Could not find resource: %@", resourceName);
        return nil;
    }
}

- (void)addMenuItemsForEvent:(NSEvent *)theEvent toMenu:(NSMenu *)theMenu {
    NSMenuItem *mergeItem = [[NSMenuItem alloc] initWithTitle:@"Merge" action:@selector(mergeSelectedPaths) keyEquivalent:@""];
    NSMenuItem *subtractItem = [[NSMenuItem alloc] initWithTitle:@"Subtract" action:@selector(subtractSelectedPaths) keyEquivalent:@""];
    NSMenuItem *intersectItem = [[NSMenuItem alloc] initWithTitle:@"Intersect" action:@selector(intersectSelectedPaths) keyEquivalent:@""];
    NSMenuItem *excludeItem = [[NSMenuItem alloc] initWithTitle:@"Exclude" action:@selector(excludeSelectedPaths) keyEquivalent:@""];

    // Загрузка и присвоение иконок кнопкам
    NSImage *mergeIcon = [self imageFromResource:@"Merge" ofType:@"svg"];
    NSImage *subtractIcon = [self imageFromResource:@"Subtract" ofType:@"svg"];
    NSImage *intersectIcon = [self imageFromResource:@"Intersect" ofType:@"svg"];
    NSImage *excludeIcon = [self imageFromResource:@"Exclude" ofType:@"svg"];

    mergeItem.image = mergeIcon;
    subtractItem.image = subtractIcon;
    intersectItem.image = intersectIcon;
    excludeItem.image = excludeIcon;

    [theMenu addItem:mergeItem];
    [theMenu addItem:subtractItem];
    [theMenu addItem:intersectItem];
    [theMenu addItem:excludeItem];
}

- (void)mergeSelectedPaths {
    if (!selectionValid) {
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
    if (!selectionValid) {
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
    if (!selectionValid) {
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
    if (!selectionValid) {
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
