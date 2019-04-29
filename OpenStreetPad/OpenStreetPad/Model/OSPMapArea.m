//
//  OSPMapArea.m
//  OpenStreetPad
//
//  Created by Thomas Davie on 13/08/2011.
//  Copyright 2011 Thomas Davie All rights reserved.
//

#import "OSPMapArea.h"

#define OSPTileSize 256.0

inline OSPMapArea OSPMapAreaMake(OSPCoordinate2D centre, float zoomLevel)
{
    return (OSPMapArea){.centre = centre, .zoomLevel = zoomLevel};
}

inline OSPCoordinateRect OSPRectForMapAreaInRect(OSPMapArea area, CGRect bounds)
{
    double width = CGRectGetWidth(bounds);
    double height = CGRectGetHeight(bounds);
    return OSPCoordinateRectMake(area.centre.x - width * 0.5, area.centre.y - height * 0.5, width, height);
}
