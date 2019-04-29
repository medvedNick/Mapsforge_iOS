//
//  LruCache.h
//
//  Created by robin on 5/20/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LruCache : NSObject

/**
 *  For caches that do not override sizeOf:, this is the maximum number of entries in the cache.
 *  For all other caches, this is the maximum sum of the sizes of the entries in this cache.
 */
- (id)initWithMaxSize:(NSInteger)maxSize;

/**
 * Returns the size of the entry for key and value in user-defined units.
 * The default implementation returns 1 so that size is the number of entries and max size is the maximum number of entries.
 */
- (NSInteger)sizeOf:(NSString *)key value:(id)value;

/**
 * Called after a cache miss to compute a value for the corresponding key.
 * Returns the computed value or null if no value can be computed. The default implementation returns null.
 */
- (id)create:(NSString *)key;

/**
 * Called for entries that have been evicted or removed. This method is invoked when a value is evicted to make space,
 * removed by a call to remove:, or replaced by a call to put:. The default implementation does nothing.
 *
 * evicted is true if the entry is being removed to make space, false if the removal was caused by a put: or remove:.
 * newValue is the new value for key, if it exists. If non-null, this removal was caused by a put:.
 * Otherwise it was caused by an eviction or a {@link #remove}.
 */
- (void)entryRemoved:(BOOL)evicted key:(NSString *)key oldValue:(id)oldValue newValue:(id)newValue;

/**
 * Sets the new maximum size of the cache.
 */
- (void)resize:(NSInteger)maxSize;

/**
 * Returns the value for key if it exists in the cache or can be created by create:.
 * If a value was returned, it is moved to the head of the queue.
 * This returns null if a value is not cached and cannot be created.
 */
- (id)get:(NSString *)key;

/**
 * Caches value for key and return the previous value mapped by key.
 * The value is moved to the head of the queue.
 */
- (id)put:(NSString *)key value:(id)value;

/**
 * Remove the eldest entries until the total of remaining entries is at or below the requested size.
 * maxSize is the maximum size of the cache before returning. May be -1 to evict even 0-sized elements.
 */
- (void)trimToSize:(NSInteger)maxSize;

/**
 * Removes the entry for key if it exists.
 * Return the previous value mapped by key.
 */
- (id)remove:(NSString *)key;

/**
 * Clear the cache, calling {@link #entryRemoved} on each removed entry.
 */
- (void)evictAll;

/**
 * For caches that do not override size:, this is the number of entries in the cache.
 * For all other caches, this returns the sum of the sizes of the entries in this cache.
 */
@property (readonly) NSInteger size;
@property (readonly) NSInteger maxSize;
@property (readonly) NSInteger hitCount;
@property (readonly) NSInteger missCount;
@property (readonly) NSInteger createCount;
@property (readonly) NSInteger putCount;
@property (readonly) NSInteger evictionCount;

@end