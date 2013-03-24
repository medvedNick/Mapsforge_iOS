//
//  OSPRendererGL.h
//  OpenStreetPad
//
//  Created by Nikita Medvedev on 6/7/12.
//  Copyright (c) 2012 Thomas Davie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OSPMapCSSStyleSheet.h"
#import "OSPMapArea.h"

@interface OSPRendererGL : NSObject

@property (readwrite, nonatomic, retain) OSPMapCSSStyleSheet *stylesheet;
@property (nonatomic) OSPMapArea mapArea;
@property (nonatomic) int objectsNumber;
@property (nonatomic, retain) NSString *resource;

- (id) initWithFile:(NSString*)path;

- (UIImage*) imageForTileX:(int)x Y:(int)y zoom:(int)zoom;
- (UIImage *) renderImageAtZoom:(int)zoom;

@end
