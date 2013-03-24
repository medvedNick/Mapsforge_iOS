#import "IndexCache.h"
#import "IndexCacheEntryKey.h"
#import "SubFileParameter.h"
#import "LRUCache.h"
#import "Deserializer.h"

/**
 * Number of index entries that one index block consists of.
 */
int const INDEX_ENTRIES_PER_BLOCK = 128;
//Logger * const LOG = [Logger getLogger:[[IndexCache class] name]];

/**
 * Maximum size in bytes of one index block.
 */
int const SIZE_OF_INDEX_BLOCK = 128/*INDEX_ENTRIES_PER_BLOCK*/ * 5/*BYTES_PER_INDEX_ENTRY*/;

@implementation IndexCache


/**
 * @param randomAccessFile
 * the map file from which the index should be read and cached.
 * @param capacity
 * the maximum number of entries in the cache.
 * @throws IllegalArgumentException
 * if the capacity is negative.
 */
- (id) init:(NSData *)_randomAccessFile capacity:(int)capacity {
  if (self = [super init]) {
    randomAccessFile = _randomAccessFile;
    map = [[NSMutableDictionary alloc] initWithCapacity:capacity];//autorelease];
  }
  return self;
}


/**
 * Destroy the cache at the end of its lifetime.
 */
- (void) destroy {
    [map removeAllObjects];
}


/**
 * Returns the index entry of a block in the given map file. If the required index entry is not cached, it will be
 * read from the map file index and put in the cache.
 * 
 * @param subFileParameter
 * the parameters of the map file for which the index entry is needed.
 * @param blockNumber
 * the number of the block in the map file.
 * @return the index entry or -1 if the block number is invalid.
 */
- (long) getIndexEntry:(SubFileParameter *)subFileParameter blockNumber:(long)blockNumber {

  @try {
    if (blockNumber >= subFileParameter->numberOfBlocks) {
      return -1;
    }
    long long indexBlockNumber = blockNumber / INDEX_ENTRIES_PER_BLOCK;
//    IndexCacheEntryKey * indexCacheEntryKey = [[IndexCacheEntryKey alloc] init:subFileParameter indexBlockNumber:indexBlockNumber];//autorelease];
//    Byte * indexBlock;// = [map get:indexCacheEntryKey]; TODO: should be cached
      NSData *data = nil;// [map objectForKey:indexCacheEntryKey];
    if (/*indexBlock*/data == nil) {
      long long indexBlockPosition = subFileParameter->indexStartAddress + indexBlockNumber * SIZE_OF_INDEX_BLOCK;
      long long remainingIndexSize = (long long)(subFileParameter->indexEndAddress - indexBlockPosition);
      long long indexBlockSize = MIN(SIZE_OF_INDEX_BLOCK,remainingIndexSize);
//      indexBlock = (Byte*)malloc(sizeof(Byte)*indexBlockSize);
//        NSData *d = [NSData dataWithContentsOfFile:randomAccessFile options:NSDataReadingMappedIfSafe error:nil];
//      data = [d subdataWithRange:NSMakeRange(indexBlockPosition, indexBlockSize)];
//        if (data == nil)
//        {
//            NSLog(@"WTF?!");
//        }
        data = [randomAccessFile subdataWithRange:NSMakeRange(indexBlockPosition, indexBlockSize)];
//      [randomAccessFile seek:indexBlockPosition];
//      if ([randomAccessFile read:indexBlock param1:0 param2:indexBlockSize] != indexBlockSize) {
//          NSLog(@"Warning in getIndexEntry: reading the current index block has failed");
//        return -1;
//      }
//      [map put:indexCacheEntryKey param1:indexBlock];
//        if (data != nil) [map setObject:data forKey:indexCacheEntryKey];
    }
    long long indexEntryInBlock = blockNumber % INDEX_ENTRIES_PER_BLOCK;
    long long addressInIndexBlock = (long long)(indexEntryInBlock * BYTES_PER_INDEX_ENTRY);
//      NSLog(@"offset: %lld", addressInIndexBlock);
    return [Deserializer getFiveBytesLong:(Byte*)data.bytes offset:addressInIndexBlock];
  }
  @catch (NSException * e) {
      NSLog(@"Exception in getIndexEntry: %@, %@", e.name, e.reason);
    return -1;
  }
}

//- (void) dealloc {
//  [map release];
//  [randomAccessFile release];
//  [super dealloc];
//}

@end
