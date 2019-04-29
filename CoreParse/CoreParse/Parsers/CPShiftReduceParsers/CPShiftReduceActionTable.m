//
//  CPShiftReduceActionTable.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceAction.h"
#import "CPShiftReduceActionTable.h"
#import "CPItem.h"
#import "CPGrammarSymbol.h"
#import "CPShiftReduceAction.h"

@implementation CPShiftReduceActionTable

- (id)initWithCapacity:(int64_t)initCapacity
{
    self = [super init];
    
    if (nil != self)
    {
        capacity = initCapacity;
        //table = malloc(capacity * sizeof(NSMutableDictionary *));
        table = [[NSMutableDictionary alloc] init];
        
        for (int buildingState = 0; buildingState < capacity; buildingState++)
        {
            NSNumber * tbs = [[NSNumber alloc] initWithInt:buildingState];
            [table setObject:[[NSMutableDictionary alloc] init] forKey:tbs];
        }
    }
    return self;
}

#define CPShiftReduceActionTableTableKey @"t"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    capacity = 0;
    
    if (nil != self)
    {
        NSArray *rows = [aDecoder decodeObjectForKey:CPShiftReduceActionTableTableKey];
        capacity = rows.count;
        table = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < capacity; i++)
        {
            [table setObject:rows[i] forKey:[[NSNumber alloc ] initWithInt:i]];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSArray arrayWithObjects:&table count:(int32_t)capacity] forKey:CPShiftReduceActionTableTableKey];
}


- (BOOL)setAction:(CPShiftReduceAction *)action forState:(NSUInteger)state name:(NSString *)token
{
    NSMutableDictionary *row = [table objectForKey:[[NSNumber alloc] initWithLong:state]];
    if (nil != [row objectForKey:token] && ![[row objectForKey:token] isEqual:action])
    {
        return NO;
    }
    [row setObject:action forKey:token];
    return YES;
}

- (CPShiftReduceAction *)actionForState:(NSUInteger)state token:(CPToken *)token
{
    NSMutableDictionary * tmp = [table objectForKey:[[NSNumber alloc] initWithLong:state]];
    return [tmp objectForKey:token.name];
}

- (NSSet *)acceptableTokenNamesForState:(NSUInteger)state
{
    NSMutableSet *toks = [NSMutableSet set];
    for (NSString *tok in [table objectForKey:[[NSNumber alloc] initWithLong:state]])
    {
        NSMutableDictionary * tmp = [table objectForKey:[[NSNumber alloc] initWithLong:state]];
        if (nil != [tmp objectForKey:tok])
        {
            [toks addObject:tok];
        }
    }
    return [toks copy];
    return nil;
}

- (NSString *)description
{
    if (capacity > 0)
    {
        NSMutableString *s = [NSMutableString string];
        NSMutableSet *keys = [NSMutableSet set];
        NSUInteger width = 3;
        for (int state = 0; state < capacity; state++)
        {
            [keys addObjectsFromArray:[[table objectForKey:[[NSNumber alloc] initWithInt:state]] allKeys]];
        }
        for (NSString *key in keys)
        {
            width = MAX(width, [key length]);
        }
        NSArray *orderedKeys = [keys allObjects];
        [s appendString:@"State | "];
        for (NSString *key in orderedKeys)
        {
            [s appendFormat:@"%@", key];
            NSUInteger numSpaces = 1 + width - [key length];
            for (NSUInteger numAdded = 0; numAdded < numSpaces; numAdded++)
            {
                [s appendString:@" "];
            }
        }
        [s appendString:@"\n"];
        
        NSUInteger idx = 0;
        for (int state = 0; state < capacity; state++)
        {
            NSDictionary *row = [table objectForKey:[[NSNumber alloc] initWithInt:state]];
            [s appendFormat:@"%5lu | ", (unsigned long)idx];
            for (NSString *key in orderedKeys)
            {
                CPShiftReduceAction *action = [row objectForKey:key];
                NSUInteger numSpaces;
                if (nil == action)
                {
                    numSpaces = 1 + width;
                }
                else
                {
                    [s appendFormat:@"%@", action];
                    numSpaces = 1 + width - [[action description] length];
                }
                for (NSUInteger numAdded = 0; numAdded < numSpaces; numAdded++)
                {
                    [s appendString:@" "];
                }
            }
            [s appendString:@"\n"];
            idx++;
        }
             
        return s;
    }
    
    return @"";
}

- (NSString *)descriptionWithGrammar:(CPGrammar *)g
{
    if (capacity > 0)
    {
        NSMutableString *s = [NSMutableString string];
        NSMutableSet *keys = [NSMutableSet set];
        NSUInteger width = 3;
        for (int state = 0; state < capacity; state++)
        {
            [keys addObjectsFromArray:[[table objectForKey:[[NSNumber alloc] initWithInt:state]] allKeys]];
        }
        for (NSString *key in keys)
        {
            width = MAX(width, [key length]);
        }
        NSArray *orderedKeys = [keys allObjects];
        [s appendString:@"State | "];
        for (NSString *key in orderedKeys)
        {
            [s appendFormat:@"%@", key];
            NSUInteger numSpaces = 1 + width - [key length];
            for (NSUInteger numAdded = 0; numAdded < numSpaces; numAdded++)
            {
                [s appendString:@" "];
            }
        }
        [s appendString:@"\n"];
        
        NSUInteger idx = 0;
        for (int state = 0; state < capacity; state++)
        {
            NSDictionary *row = [table objectForKey:[[NSNumber alloc] initWithInt:state]];
            [s appendFormat:@"%5lu | ", (unsigned long)idx];
            for (NSString *key in orderedKeys)
            {
                CPShiftReduceAction *action = [row objectForKey:key];
                NSUInteger numSpaces;
                if (nil == action)
                {
                    numSpaces = 1 + width;
                }
                else
                {
                    [s appendFormat:@"%@", [action descriptionWithGrammar:g]];
                    numSpaces = 1 + width - [[action descriptionWithGrammar:g] length];
                }
                for (NSUInteger numAdded = 0; numAdded < numSpaces; numAdded++)
                {
                    [s appendString:@" "];
                }
            }
            [s appendString:@"\n"];
            idx++;
        }
        
        return s;
    }
    
    return @"";
}

@end
