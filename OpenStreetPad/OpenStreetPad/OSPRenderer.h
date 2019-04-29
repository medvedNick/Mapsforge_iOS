//
//  OSPRenderer.h
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 3/29/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OSPMapCSSStyleSheet.h"
#import "OSPMapArea.h"
#import "OSPTagDictionary.h"

@class MapDatabase;

@interface OSPRenderer : NSObject

@property (readwrite, nonatomic, retain/*strong*/) OSPMapCSSStyleSheet *stylesheet;
@property (nonatomic) OSPMapArea mapArea;
@property (nonatomic) long objectsNumber;
@property (nonatomic, retain) NSString *resource;

- (id) initWithFile:(NSString*)path;

- (UIImage*) imageForTileX:(int)x Y:(int)y zoom:(int)zoom;
- (UIImage *) renderImageAtZoom:(int)zoom;
- (MapDatabase*)getMapDatabase;

@end
