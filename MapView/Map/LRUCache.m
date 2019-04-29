//
//  LruCache.m
//
//  Created by robin on 5/20/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "LruCache.h"

@implementation LruCache {
    NSMutableDictionary *_values;
    NSMutableOrderedSet *_keys;
}

- (id)initWithMaxSize:(NSInteger)maxSize
{
    if (maxSize <= 0) {
        [NSException raise:@"Illegal Argument" format:@"maxSize <= 0"];
    }
    
    self = [super init];
    if (self) {
        _maxSize = maxSize;
        _values = [[NSMutableDictionary alloc] init];
        _keys = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (id)init
{
    return [self initWithMaxSize:0];
}

- (NSInteger)sizeOf:(NSString *)key value:(id)value
{
    return 1;
}

- (id)create:(NSString *)key
{
    return nil;
}

- (void)entryRemoved:(BOOL)evicted key:(NSString *)key oldValue:(id)oldValue newValue:(id)newValue
{
    
}

- (id)get:(NSString *)key
{
    if (key == nil) {
        [NSException raise:@"Null Pointer" format:@"key == nil"];
    }
    
    NSString *cKey = [key copy];
    id dicValue;
    @synchronized (self) {
        dicValue = _values[cKey];
        if (dicValue != nil) {
            _hitCount++;
            [_keys removeObject:cKey];
            [_keys insertObject:cKey atIndex:0];
            return dicValue;
        }
        _missCount++;
    }
    
    id createdValue = [self create:cKey];
    if (createdValue == nil) {
        return nil;
    }
    
    @synchronized (self) {
        _createCount++;
        dicValue = _values[cKey];
        if (dicValue == nil) {
            [_values setObject:createdValue forKey:cKey];
            [_keys insertObject:cKey atIndex:0];
            _size += [self safeSizeOf:cKey value:createdValue];
        }
        [_keys removeObject:cKey];
        [_keys insertObject:cKey atIndex:0];
    }
    
    if (dicValue != nil) {
        [self entryRemoved:NO key:cKey oldValue:createdValue newValue:dicValue];
        return dicValue;
    } else {
        [self trimToSize:_maxSize];
        return createdValue;
    }
}

- (id)put:(NSString *)key value:(id)value
{
    if (key == nil || value == nil) {
        [NSException raise:@"Null Pointer" format:@"key == nil || value == nil"];
    }
    
    NSString *cKey = [key copy];
    id previous;
    @synchronized (self) {
        _putCount++;
        _size += [self safeSizeOf:cKey value:value];
        previous = _values[cKey];
        if (previous != nil) {
            _size -= [self safeSizeOf:cKey value:previous];
        }
        [_values setObject:value forKey:cKey];
        [_keys removeObject:cKey];
        [_keys insertObject:cKey atIndex:0];
    }
    
    if (previous != nil) {
        [self entryRemoved:NO key:cKey oldValue:previous newValue:value];
    }
    
    [self trimToSize:_maxSize];
    return previous;
}

- (void)trimToSize:(NSInteger)maxSize
{
    while (YES) {
        NSString *key;
        id value;
        @synchronized (self) {
            if (_size < 0 || ([_values count] == 0 && _size != 0)) {
                [NSException raise:@"Illegal State" format:@"inconsistent size."];
            }
            
            if (_size <= maxSize || [_values count] == 0) {
                break;
            }
            
            key = [_keys lastObject];
            value = _values[key];
            if (value == nil) {
                [NSException raise:@"Illegal State" format:@"inconsistent key-value set."];
            }
            
            [_keys removeObject:key];
            [_values removeObjectForKey:key];
            _size -= [self safeSizeOf:key value:value];
            _evictionCount++;
        }
        
        [self entryRemoved:YES key:key oldValue:value newValue:nil];
    }
}

- (id)remove:(NSString *)key
{
    if (key == nil) {
        [NSException raise:@"Null Pointer" format:@"key == nil"];
    }
    
    NSString *cKey = [key copy];
    id previous;
    @synchronized (self) {
        previous = _values[cKey];
        if (previous != nil) {
            _size -= [self safeSizeOf:cKey value:previous];
        }
    }
    
    if (previous != nil) {
        [self entryRemoved:NO key:cKey oldValue:previous newValue:nil];
    }
    
    return previous;
}

- (void)evictAll
{
    [self trimToSize:-1];
}

- (void)resize:(NSInteger)maxSize
{
    if (_maxSize <= 0) {
        [NSException raise:@"Illegal Argument" format:@"maxSize <= 0"];
    }
    
    @synchronized (self) {
        _maxSize = maxSize;
    }
    [self trimToSize:maxSize];
}

- (NSMutableDictionary *)snapshot
{
    return [NSMutableDictionary dictionaryWithDictionary:_values];
}

- (NSString *)description
{
    long accesses = _hitCount + _missCount;
    long hitPercent = accesses != 0 ? (100 * _hitCount / accesses) : 0;
    return [NSString stringWithFormat:@"LruCache[maxSize=%ld,size=%ld,items=%ld,hits=%ld,misses=%ld,hitRate=%ld%%]",
            (long)_maxSize, (long)_size, (long)[_values count], (long)_hitCount, (long)_missCount, hitPercent];
}

#pragma mark - private methods
- (NSInteger)safeSizeOf:(NSString *)key value:(id)value
{
    NSInteger result = [self sizeOf:key value:value];
    if (result < 0) {
        [NSException raise:@"Illegal State" format:@"negative size"];
    }
    return result;
}

@end