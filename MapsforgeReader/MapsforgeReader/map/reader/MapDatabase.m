#import "MapDatabase.h"
#import "QueryParameters.h"
#import "QueryCalculations.h"
#import "MapDatabaseCallback.h"
#import "FileOpenResult.h"
#import "ReadBuffer.h"

/**
 * Bitmask to extract the block offset from an index entry.
 */
long long const BITMASK_INDEX_OFFSET = 0x7FFFFFFFFFL;

/**
 * Bitmask to extract the water information from an index entry.
 */
long long const BITMASK_INDEX_WATER = 0x8000000000L;

/**
 * Debug message prefix for the block signature.
 */
NSString * const DEBUG_SIGNATURE_BLOCK = @"block signature: ";

/**
 * Debug message prefix for the POI signature.
 */
NSString * const DEBUG_SIGNATURE_POI = @"POI signature: ";

/**
 * Debug message prefix for the way signature.
 */
NSString * const DEBUG_SIGNATURE_WAY = @"way signature: ";

/**
 * Amount of cache blocks that the index cache should store.
 */
int const INDEX_CACHE_SIZE = 64;

/**
 * Error message for an invalid first way offset.
 */
NSString * const INVALID_FIRST_WAY_OFFSET = @"invalid first way offset: ";
//Logger * const LOG = [Logger getLogger:[[MapDatabase class] name]];

/**
 * Maximum way nodes sequence length which is considered as valid.
 */
int const MAXIMUM_WAY_NODES_SEQUENCE_LENGTH = 8192;

/**
 * Maximum number of map objects in the zoom table which is considered as valid.
 */
int const MAXIMUM_ZOOM_TABLE_OBJECTS = 65536;

/**
 * Bitmask for the optional POI feature "elevation".
 */
int const POI_FEATURE_ELEVATION = 0x20;

/**
 * Bitmask for the optional POI feature "house number".
 */
int const POI_FEATURE_HOUSE_NUMBER = 0x40;

/**
 * Bitmask for the optional POI feature "name".
 */
int const POI_FEATURE_NAME = 0x80;

/**
 * Bitmask for the POI layer.
 */
int const POI_LAYER_BITMASK = 0xf0;

/**
 * Bit shift for calculating the POI layer.
 */
int const POI_LAYER_SHIFT = 4;

/**
 * Bitmask for the number of POI tags.
 */
int const POI_NUMBER_OF_TAGS_BITMASK = 0x0f;
NSString * const READ_ONLY_MODE = @"r";

/**
 * Length of the debug signature at the beginning of each block.
 */
char const SIGNATURE_LENGTH_BLOCK = 32;

/**
 * Length of the debug signature at the beginning of each POI.
 */
char const SIGNATURE_LENGTH_POI = 32;

/**
 * Length of the debug signature at the beginning of each way.
 */
char const SIGNATURE_LENGTH_WAY = 32;

/**
 * The key of the elevation OpenStreetMap tag.
 */
NSString * const TAG_KEY_ELE = @"ele";

/**
 * The key of the house number OpenStreetMap tag.
 */
NSString * const TAG_KEY_HOUSE_NUMBER = @"addr:housenumber";

/**
 * The key of the name OpenStreetMap tag.
 */
NSString * const TAG_KEY_NAME = @"name";

/**
 * The key of the reference OpenStreetMap tag.
 */
NSString * const TAG_KEY_REF = @"ref";

/**
 * Bitmask for the optional way data blocks byte.
 */
int const WAY_FEATURE_DATA_BLOCKS_BYTE = 0x08;

/**
 * Bitmask for the optional way double delta encoding.
 */
int const WAY_FEATURE_DOUBLE_DELTA_ENCODING = 0x04;

/**
 * Bitmask for the optional way feature "house number".
 */
int const WAY_FEATURE_HOUSE_NUMBER = 0x40;

/**
 * Bitmask for the optional way feature "label position".
 */
int const WAY_FEATURE_LABEL_POSITION = 0x10;

/**
 * Bitmask for the optional way feature "name".
 */
int const WAY_FEATURE_NAME = 0x80;

/**
 * Bitmask for the optional way feature "reference".
 */
int const WAY_FEATURE_REF = 0x20;

/**
 * Bitmask for the way layer.
 */
int const WAY_LAYER_BITMASK = 0xf0;

/**
 * Bit shift for calculating the way layer.
 */
int const WAY_LAYER_SHIFT = 4;

/**
 * Bitmask for the number of way tags.
 */
int const WAY_NUMBER_OF_TAGS_BITMASK = 0x0f;

//extern int const MAXIMUM_BUFFER_SIZE;

@interface MapDatabase ()
- (void)createWayCoordinates:(int***)wayCoordinates
      andProcessWayDataBlock:(BOOL)doubleDeltaEncoding
                   andLength:(int**)length;
- (int)createAndReadZoomTable:(int***)zoomTable
         withSubFileParameter:(SubFileParameter *)subFileParameter;
- (void)free2DArray:(int**)array withNumberOfRows:(int)rows;
@end

@implementation MapDatabase

@synthesize mapFileInfo;


/**
 * Closes the map file and destroys all internal caches. This method has no effect if no map file is currently
 * opened.
 */
- (void) closeFile {

  @try {
    mapFileHeader = nil;
    if (databaseIndexCache != nil) {
      [databaseIndexCache destroy];
      databaseIndexCache = nil;
    }
    if (inputFile != nil) {
//      [inputFile close];
      inputFile = nil;
    }
    readBuffer = nil;
  }
  @catch (NSException * e) {
	  NSLog(@"Exception in MapDatabase, -closeFile: %@, %@", e.name, e.reason);
  }
}


/**
 * Starts a database query with the given parameters.
 * 
 * @param tile
 * the tile to read.
 * @param mapDatabaseCallback
 * the callback which handles the extracted map elements.
 */
- (void) executeQuery:(Tile *)tile mapDatabaseCallback:(id<MapDatabaseCallback>)mapDatabaseCallback {

  @try {
    [self prepareExecution];
//    readBuffer = [[ReadBuffer alloc] initWithInputFile:inputFile];
    QueryParameters * queryParameters = [[QueryParameters alloc] init];//autorelease];
    queryParameters->queryZoomLevel = [mapFileHeader getQueryZoomLevel:tile->zoomLevel];
    SubFileParameter * subFileParameter = [mapFileHeader getSubFileParameter:queryParameters->queryZoomLevel];
    if (subFileParameter == nil) {
		NSLog(@"no sub-file for zoom level: %d", queryParameters->queryZoomLevel);
      return;
    }
    [QueryCalculations calculateBaseTiles:queryParameters tile:tile subFileParameter:subFileParameter];
    [QueryCalculations calculateBlocks:queryParameters subFileParameter:subFileParameter];
    [self processBlocks:mapDatabaseCallback queryParameters:queryParameters subFileParameter:subFileParameter];
  }
  @catch (NSException * e) {
	  NSLog(@"Exception in -executeQuery in MapDataBase.m: %@, %@", e.name, e.reason);
  }
}


/**
 * @return the metadata for the current map file.
 * @throws IllegalStateException
 * if no map is currently opened.
 */
- (MapFileInfo *) mapFileInfo {
  if (mapFileHeader == nil) {
	  [NSException raise:@"IllegalStateException" format:@"no map file is currently opened"];
  }
  return [mapFileHeader mapFileInfo];
}


/**
 * @return true if a map file is currently opened, false otherwise.
 */
- (BOOL) hasOpenFile {
  return inputFile != nil;
}


/**
 * Opens the given map file, reads its header data and validates them.
 * 
 * @param mapFile
 * the map file.
 * @return a FileOpenResult containing an error message in case of a failure.
 * @throws IllegalArgumentException
 * if the given map file is null.
 */
- (BOOL) openFile:(NSString *)mapFile {

  @try {
    if (mapFile == nil) {
	  [NSException raise:@"IllegalStateException" format:@"mapFile must not be null"];
    }
    [self closeFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:mapFile]) {
        return NO;//[[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"file does not exist: %d", mapFile]];//autorelease];
    }
//     else if (![mapFile file]) {
//      return [[[FileOpenResult alloc] init:[@"not a file: " stringByAppendingString:mapFile]];//autorelease];
//    }
//     else if ([mapFile canRead]) {
//      return [[[FileOpenResult alloc] init:[@"cannot read file: " stringByAppendingString:mapFile]];//autorelease];
//    }
    inputFile = mapFile; //[[[RandomAccessFile alloc] init:mapFile param1:READ_ONLY_MODE];//autorelease];
    inputData = [[NSData alloc] initWithContentsOfFile:inputFile options:NSDataReadingMappedAlways error:nil];
    fileSize = /*((NSData*)[NSData dataWithContentsOfFile:inputFile options:NSMappedRead error:nil])*/inputData.length;
    readBuffer = [[ReadBuffer alloc] initWithInputFile:inputData];//autorelease];
    mapFileHeader = [[MapFileHeader alloc] init];//autorelease];
    FileOpenResult * fileOpenResult = [mapFileHeader readHeader:readBuffer fileSize:fileSize];
    if (![fileOpenResult success]) {
      [self closeFile];
        return NO;//fileOpenResult;
    }
      return YES;//[FileOpenResult SUCCESS];
  }
  @catch (NSException * e) {
    [self closeFile];
      return NO;//[[FileOpenResult alloc] initWithErrorMessage:[NSString stringWithFormat:@"Exception while opening file: %@, %@",e.name, e.reason]];//autorelease];
  }
}

- (void) decodeWayNodesDoubleDelta:(int *)waySegment length:(int)length{
  int wayNodeLatitude = tileLatitude + [readBuffer readSignedInt];
  int wayNodeLongitude = tileLongitude + [readBuffer readSignedInt];
//  [waySegment replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:wayNodeLongitude]];
//  [waySegment replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:wayNodeLatitude]];
  waySegment[1] = wayNodeLatitude;
  waySegment[0] = wayNodeLongitude;
  int previousSingleDeltaLatitude = 0;
  int previousSingleDeltaLongitude = 0;

  for (int wayNodesIndex = 2; wayNodesIndex < length; wayNodesIndex += 2) {
    int doubleDeltaLatitude = [readBuffer readSignedInt];
    int doubleDeltaLongitude = [readBuffer readSignedInt];
    int singleDeltaLatitude = doubleDeltaLatitude + previousSingleDeltaLatitude;
    int singleDeltaLongitude = doubleDeltaLongitude + previousSingleDeltaLongitude;
    wayNodeLatitude = wayNodeLatitude + singleDeltaLatitude;
    wayNodeLongitude = wayNodeLongitude + singleDeltaLongitude;
    waySegment[wayNodesIndex + 1] = wayNodeLatitude;
    waySegment[wayNodesIndex] = wayNodeLongitude;
//    [waySegment replaceObjectAtIndex:wayNodesIndex withObject:[NSNumber numberWithLong:wayNodeLongitude]];
//    [waySegment replaceObjectAtIndex:wayNodesIndex+1 withObject:[NSNumber numberWithLong:wayNodeLatitude]];
    previousSingleDeltaLatitude = singleDeltaLatitude;
    previousSingleDeltaLongitude = singleDeltaLongitude;
  }

}

- (void) decodeWayNodesSingleDelta:(int *)waySegment length:(int)length {
  int wayNodeLatitude = tileLatitude + [readBuffer readSignedInt];
  int wayNodeLongitude = tileLongitude + [readBuffer readSignedInt];
  waySegment[1] = wayNodeLatitude;
  waySegment[0] = wayNodeLongitude;
//  [waySegment replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:wayNodeLongitude]];
//  [waySegment replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:wayNodeLatitude]];

  for (int wayNodesIndex = 2; wayNodesIndex < length; wayNodesIndex += 2) {
    wayNodeLatitude = wayNodeLatitude + [readBuffer readSignedInt];
    wayNodeLongitude = wayNodeLongitude + [readBuffer readSignedInt];
    waySegment[wayNodesIndex + 1] = wayNodeLatitude;
    waySegment[wayNodesIndex] = wayNodeLongitude;
//    [waySegment replaceObjectAtIndex:wayNodesIndex withObject:[NSNumber numberWithLong:wayNodeLongitude]];
//    [waySegment replaceObjectAtIndex:wayNodesIndex+1 withObject:[NSNumber numberWithLong:wayNodeLatitude]];
  }

}


/**
 * Logs the debug signatures of the current way and block.
 */
- (void) logDebugSignatures {
  if ([mapFileHeader mapFileInfo]->debugFile) {
      NSLog(@"warning in -logDenugSignatures in MapDatabase.m");
  }
}

- (void) prepareExecution {
  if (databaseIndexCache == nil) {
    databaseIndexCache = [[IndexCache alloc] init:inputData capacity:INDEX_CACHE_SIZE];//autorelease];
  }
}


/**
 * Processes a single block and executes the callback functions on all map elements.
 * 
 * @param queryParameters
 * the parameters of the current query.
 * @param subFileParameter
 * the parameters of the current map file.
 * @param mapDatabaseCallback
 * the callback which handles the extracted map elements.
 */
- (void) processBlock:(QueryParameters *)queryParameters subFileParameter:(SubFileParameter *)subFileParameter mapDatabaseCallback:(id<MapDatabaseCallback>)mapDatabaseCallback {
  if (![self processBlockSignature]) {
    return;
  }
    int** zoomTable;
    int numRowsInZoomTable = [self createAndReadZoomTable:&zoomTable withSubFileParameter:subFileParameter];
  if (numRowsInZoomTable == 0) {
      [self free2DArray:zoomTable withNumberOfRows:numRowsInZoomTable];
    return;
  }
  int zoomTableRow = queryParameters->queryZoomLevel - subFileParameter->zoomLevelMin;
  int poisOnQueryZoomLevel = zoomTable[zoomTableRow][0];
  int waysOnQueryZoomLevel = zoomTable[zoomTableRow][1];
    [self free2DArray:zoomTable withNumberOfRows:numRowsInZoomTable];
    int firstWayOffset = [readBuffer readUnsignedInt];
  if (firstWayOffset < 0) {
      NSLog(@"warning in -processBlock in MapDatabase.m: invalid firstWayOffset: %d", firstWayOffset);
    if ([mapFileHeader mapFileInfo]->debugFile) {
      NSLog(@"warning in -processBlock in MapDatabase.m: debugSignatureBlock: %@", signatureBlock);
    }
    return;
  }
  firstWayOffset += [readBuffer getBufferPosition];
  if (firstWayOffset > [readBuffer getBufferSize]) {
    NSLog(@"warning in -processBlock in MapDatabase.m: invalid firstWayOffset: %d", firstWayOffset);
    if ([mapFileHeader mapFileInfo]->debugFile) {
      NSLog(@"warning in -processBlock in MapDatabase.m: debugSignatureBlock: %@", signatureBlock);
    }
    return;
  }
  if (![self processPOIs:mapDatabaseCallback numberOfPois:poisOnQueryZoomLevel]) {
    return;
  }
  if ([readBuffer getBufferPosition] > firstWayOffset) {
    NSLog(@"invalid buffer positoin: %d", [readBuffer getBufferPosition]);
    if ([mapFileHeader mapFileInfo]->debugFile) {
      NSLog(@"warning in -processBlock in MapDatabase.m: debugSignatureBlock: %@", signatureBlock);
    }
    return;
  }
  [readBuffer setBufferPosition:firstWayOffset];
  if (![self processWays:queryParameters mapDatabaseCallback:mapDatabaseCallback numberOfWays:waysOnQueryZoomLevel]) {
    return;
  }
}

- (void) processBlocks:(id<MapDatabaseCallback>)mapDatabaseCallback queryParameters:(QueryParameters *)queryParameters subFileParameter:(SubFileParameter *)subFileParameter {
  BOOL queryIsWater = YES;
  BOOL queryReadWaterInfo = NO;

  for (long long row = queryParameters->fromBlockY; row <= queryParameters->toBlockY; ++row) {

    for (long long column = queryParameters->fromBlockX; column <= queryParameters->toBlockX; ++column) {
      long long blockNumber = row * subFileParameter->blocksWidth + column;
      long long currentBlockIndexEntry = [databaseIndexCache getIndexEntry:subFileParameter blockNumber:blockNumber];
      if (queryIsWater) {
        queryIsWater &= (currentBlockIndexEntry & BITMASK_INDEX_WATER) != 0;
        queryReadWaterInfo = YES;
      }
      long long currentBlockPointer = currentBlockIndexEntry & BITMASK_INDEX_OFFSET;
      if (currentBlockPointer < 1 || currentBlockPointer > subFileParameter->subFileSize) {
        NSLog(@"invalid current block pointer: %lld", currentBlockPointer);
        NSLog(@"subFileSize: %lld", subFileParameter->subFileSize);
        return;
      }
      long long nextBlockPointer;
      if (blockNumber + 1 == subFileParameter->numberOfBlocks) {
        nextBlockPointer = subFileParameter->subFileSize;
      }
       else {
        nextBlockPointer = [databaseIndexCache getIndexEntry:subFileParameter blockNumber:blockNumber + 1] & BITMASK_INDEX_OFFSET;
        if (nextBlockPointer < 1 || nextBlockPointer > subFileParameter->subFileSize) {
          NSLog(@"invalid next block pointer: %lld", nextBlockPointer);
          NSLog(@"subFileSize: %lld", subFileParameter->subFileSize);
          return;
        }
      }
      int currentBlockSize = (int)(nextBlockPointer - currentBlockPointer);
      if (currentBlockSize < 0) {
        NSLog(@"current block size must not be negative: %d", currentBlockSize);
        return;
      }
       else if (currentBlockSize == 0) {
        continue;
      }
       else if (currentBlockSize > /*MAXIMUM_BUFFER_SIZE*/2500000) {
         NSLog(@"current block size too large: %d", currentBlockSize);
        continue;
      }
       else if (currentBlockPointer + currentBlockSize > fileSize) {
         NSLog(@"current block largher than file size: %d", currentBlockSize);
        return;
      }
      [readBuffer seekTo:subFileParameter->startAddress + currentBlockPointer];
//      [inputFile seek:subFileParameter->startAddress + currentBlockPointer]; //TODO: it's MutableData
      if (![readBuffer readFromFile:currentBlockSize]) {
         NSLog(@"reading current block has failed: %d", currentBlockSize);
        return;
      }
      double tileLatitudeDeg = [MercatorProjection tileYToLatitude:subFileParameter->boundaryTileTop + row zoomLevel:subFileParameter->baseZoomLevel];
      double tileLongitudeDeg = [MercatorProjection tileXToLongitude:subFileParameter->boundaryTileLeft + column zoomLevel:subFileParameter->baseZoomLevel];
      tileLatitude = (int)(tileLatitudeDeg * 1000000);
      tileLongitude = (int)(tileLongitudeDeg * 1000000);

      @try {
        [self processBlock:queryParameters subFileParameter:subFileParameter mapDatabaseCallback:mapDatabaseCallback];
      }
      @catch (NSException * e) {
        NSLog(@"ArrayIndexOutOfBounds exception in -processBlocks in MapDataBase.m: %@, %@", e.name, e.reason);
        @throw e;
      }
    }

  }

  if (queryIsWater && queryReadWaterInfo) {
    [mapDatabaseCallback renderWaterBackground];
  }
}


/**
 * Processes the block signature, if present.
 * 
 * @return true if the block signature could be processed successfully, false otherwise.
 */
- (BOOL) processBlockSignature {
  if ([mapFileHeader mapFileInfo]->debugFile) {
    signatureBlock = [readBuffer readUTF8EncodedString:SIGNATURE_LENGTH_BLOCK];
      //TODO: check for correct beginning of signature, may be useful
//    if (![signatureBlock startsWith:@"###TileStart"]) {
//      NSLog(@"invalid block signature: %@", signatureBlock);
//      return NO;
//    }
  }
  return YES;
}


/**
 * Processes the given number of POIs.
 * 
 * @param mapDatabaseCallback
 * the callback which handles the extracted POIs.
 * @param numberOfPois
 * how many POIs should be processed.
 * @return true if the POIs could be processed successfully, false otherwise.
 */
- (BOOL) processPOIs:(id<MapDatabaseCallback>)mapDatabaseCallback numberOfPois:(int)numberOfPois {
    //  NSMutableArray * tags = [[NSMutableArray alloc] init];//autorelease];
    NSArray * poiTags = [mapFileHeader mapFileInfo]->poiTags;
    
    for (int elementCounter = numberOfPois; elementCounter != 0; --elementCounter) {
        if ([mapFileHeader mapFileInfo]->debugFile) {
            // get and check the POI signature
            signatureWay = [readBuffer readUTF8EncodedString:SIGNATURE_LENGTH_POI];
            
            if (![signatureWay hasPrefix:@"***POIStart"]) {
                NSLog(@"invalid POI signature: : %@", signatureWay);
                return NO;
            }
        }
        
        double latitide = tileLatitude+[readBuffer readSignedInt];
        double longitude = tileLongitude+[readBuffer readSignedInt];
        
        //NSLog(@"%f,%f",latitide,longitude);
        
        // get the special byte which encodes multiple flags
        Byte specialByte = [readBuffer readByte];
        // bit 1-4 represent the layer
        Byte layer = (Byte)((specialByte & POI_LAYER_BITMASK) >> POI_LAYER_SHIFT);
        // bit 5-8 represent the number of tag IDs
        Byte numberOfTags = (Byte)(specialByte & POI_NUMBER_OF_TAGS_BITMASK);
        
        NSMutableDictionary *tagsDict = [[NSMutableDictionary alloc] init];
        
        // get the tag IDs (VBE-U)
        for (Byte tagIndex = numberOfTags; tagIndex != 0; --tagIndex) {
            int tagId = [readBuffer readUnsignedInt];
            if (tagId < 0 || tagId >= poiTags.count) {
                NSLog(@"invalid POI tag ID: %d", tagId);
                [self logDebugSignatures];
                return NO;
            }
            
            //      [tags addObject:[wayTags objectAtIndex:tagId]];
            MFTag *currTag = [poiTags objectAtIndex:tagId];
            [tagsDict setObject:currTag->value forKey:currTag->key];
        }
        
        // get the feature bitmask (1 byte)
        Byte featureByte = [readBuffer readByte];
        // bit 1-3 enable optional features
        BOOL featureName = (featureByte & POI_FEATURE_NAME) != 0;
        
        // check if the POI has a name
        if (featureName) {
            [tagsDict setObject:[readBuffer readUTF8EncodedString] forKey:TAG_KEY_NAME];
        }
        
        static int nodeId = 666;
        [mapDatabaseCallback addNode:nodeId++ latitude:latitide longitude:longitude tags:tagsDict];
        
    }
    
    return YES;
}

- (void)createWayCoordinates:(int***)wayCoordinates
      andProcessWayDataBlock:(BOOL)doubleDeltaEncoding
                   andLength:(int**)length {
    int numberOfWayCoordinateBlocks = [readBuffer readUnsignedInt];
    if (numberOfWayCoordinateBlocks < 1 || numberOfWayCoordinateBlocks > SHRT_MAX) {
        NSLog(@"invalid number of way coordinate blocks: %d", numberOfWayCoordinateBlocks);
        [self logDebugSignatures];
        *wayCoordinates = nil;
        return;
    }
    
    *wayCoordinates = (int**)malloc(numberOfWayCoordinateBlocks * sizeof(int*));
    
    *length = (int*)malloc((numberOfWayCoordinateBlocks + 1) * sizeof(int));
    (*length)[0] = 1;//numberOfWayCoordinateBlocks;
    //  NSMutableArray *wayCoordinates = [NSMutableArray arrayWithCapacity:numberOfWayCoordinateBlocks];
    //    for (int i = 0; i < numberOfWayCoordinateBlocks; ++i)
    //    {
    //        [wayCoordinates addObject:[NSNull null]];
    //    }
    int numRowsInWayCoordinates = 0;
    for (int coordinateBlock = 0; coordinateBlock < numberOfWayCoordinateBlocks; ++coordinateBlock) {
        int numberOfWayNodes = [readBuffer readUnsignedInt];
        if (numberOfWayNodes < 2 || numberOfWayNodes > MAXIMUM_WAY_NODES_SEQUENCE_LENGTH) {
            NSLog(@"invalid number of way nodes: %d", numberOfWayNodes);
            [self logDebugSignatures];
            [self free2DArray:*wayCoordinates withNumberOfRows:numRowsInWayCoordinates];
            *wayCoordinates = nil;
            free(*length);
            length = nil;
            return;
        }
        
        int wayNodesSequenceLength = numberOfWayNodes * 2;
        int * waySegment = (int*)malloc(wayNodesSequenceLength * sizeof(int));
        //      NSMutableArray *waySegment = [NSMutableArray arrayWithCapacity:wayNodesSequenceLength];
        //      for (int i = 0; i < wayNodesSequenceLength; ++i)
        //      {
        //          [waySegment addObject:[NSNull null]];
        //      }
        if (doubleDeltaEncoding) {
            [self decodeWayNodesDoubleDelta:waySegment length:wayNodesSequenceLength];
        } else {
            [self decodeWayNodesSingleDelta:waySegment length:wayNodesSequenceLength];
        }
        
        if (coordinateBlock == 0) {
            (*length)[coordinateBlock+1] = wayNodesSequenceLength;
            (*wayCoordinates)[coordinateBlock] = waySegment;
            numRowsInWayCoordinates++;
        } else {
            free(waySegment);
        }
        //    [wayCoordinates replaceObjectAtIndex:coordinateBlock withObject:waySegment];
    }
}


/**
 * Processes the given number of ways.
 * 
 * @param queryParameters
 * the parameters of the current query.
 * @param mapDatabaseCallback
 * the callback which handles the extracted ways.
 * @param numberOfWays
 * how many ways should be processed.
 * @return true if the ways could be processed successfully, false otherwise.
 */
- (BOOL) processWays:(QueryParameters *)queryParameters mapDatabaseCallback:(id<MapDatabaseCallback>)mapDatabaseCallback numberOfWays:(int)numberOfWays {
//  NSMutableArray * tags = [[NSMutableArray alloc] init];//autorelease];
  NSArray * wayTags = [mapFileHeader mapFileInfo]->wayTags;

  for (int elementCounter = numberOfWays; elementCounter != 0; --elementCounter) {
    if ([mapFileHeader mapFileInfo]->debugFile) {
      signatureWay = [readBuffer readUTF8EncodedString:SIGNATURE_LENGTH_WAY];
//		TODO:        
//      if (![signatureWay startsWith:@"---WayStart"]) {
//        NSLog(@"warning in -processWays in MapDatabase.m: invalid way signature: %@", signatureWay);
//        NSLog(@"warning in -processWays in MapDatabase.m: debug signature block: %@", signatureBlock);
//        return NO;
//      }
    }
    int wayDataSize = [readBuffer readUnsignedInt];
    if (wayDataSize < 0) {
      NSLog(@"warning in -processWays in MapDatabase.m: invalid way data size: %d", wayDataSize);
      if ([mapFileHeader mapFileInfo]->debugFile) {
        NSLog(@"warning in -processWays in MapDatabase.m: debug signature block: %@", signatureBlock);
      }
      return NO;
    }
    if (queryParameters->useTileBitmask) {
      int tileBitmask = [readBuffer readShort];
      if ((queryParameters->queryTileBitmask & tileBitmask) == 0) {
        [readBuffer skipBytes:wayDataSize - 2];
        continue;
      }
    }
     else {
      [readBuffer skipBytes:2];
    }
    Byte specialByte = [readBuffer readByte];
    Byte layer = (Byte)((specialByte & WAY_LAYER_BITMASK) >> WAY_LAYER_SHIFT);
    Byte numberOfTags = (Byte)(specialByte & WAY_NUMBER_OF_TAGS_BITMASK);
//    [tags removeAllObjects];
    NSMutableDictionary *tagsDict = [[NSMutableDictionary alloc] init];

    for (Byte tagIndex = numberOfTags; tagIndex != 0; --tagIndex) {
      int tagId = [readBuffer readUnsignedInt];
      if (tagId < 0 || tagId >= wayTags.count) {
        NSLog(@"warning in -processWays in MapDatabase.m: invalid way tag ID: %d", tagId);
        [self logDebugSignatures];
        return NO;
      }
//      [tags addObject:[wayTags objectAtIndex:tagId]];
      MFTag *currTag = [wayTags objectAtIndex:tagId];
      [tagsDict setObject:currTag->value forKey:currTag->key];
    }

    Byte featureByte = [readBuffer readByte];
    BOOL featureName = (featureByte & WAY_FEATURE_NAME) != 0;
    BOOL featureHouseNumber = (featureByte & WAY_FEATURE_HOUSE_NUMBER) != 0;
    BOOL featureRef = (featureByte & WAY_FEATURE_REF) != 0;
    BOOL featureLabelPosition = (featureByte & WAY_FEATURE_LABEL_POSITION) != 0;
    BOOL featureWayDataBlocksByte = (featureByte & WAY_FEATURE_DATA_BLOCKS_BYTE) != 0;
    BOOL featureWayDoubleDeltaEncoding = (featureByte & WAY_FEATURE_DOUBLE_DELTA_ENCODING) != 0;
    if (featureName) {
      [tagsDict setObject:[readBuffer readUTF8EncodedString] forKey:TAG_KEY_NAME];
//      [tags addObject:[[MFTag alloc] init:TAG_KEY_NAME value:[readBuffer readUTF8EncodedString]]];//autorelease]];
    }
    if (featureHouseNumber) {
      [tagsDict setObject:[readBuffer readUTF8EncodedString] forKey:TAG_KEY_HOUSE_NUMBER];
//      [tags addObject:[[MFTag alloc] init:TAG_KEY_HOUSE_NUMBER value:[readBuffer readUTF8EncodedString]]];//autorelease]];
    }
    if (featureRef) {
      [tagsDict setObject:[readBuffer readUTF8EncodedString] forKey:TAG_KEY_REF];
//      [tags addObject:[[MFTag alloc] init:TAG_KEY_REF value:[readBuffer readUTF8EncodedString]]];//autorelease]];
    }
    
    int wayDataBlocks = [self readOptionalWayDataBlocksByte:featureWayDataBlocksByte];
    if (wayDataBlocks < 1) {
      NSLog(@"warning in -processWays in MapDatabase.m: invalid number of way data blocks: %d", wayDataBlocks);
      [self logDebugSignatures];
      return NO;
    }
      float * labelPosition = [self readOptionalLabelPosition:featureLabelPosition];
//    NSMutableDictionary *tagsDict = [[NSMutableDictionary alloc] initWithCapacity:tags.count];
//    for (MFTag *tag in tags)
//    {
//        [tagsDict setObject:tag->value forKey:tag->key];
//    }
      
    static int wayId = 666;
    int *wayLength;

    for (int wayDataBlock = 0; wayDataBlock < wayDataBlocks; ++wayDataBlock) {
      //int ** wayNodes = [self processWayDataBlock:featureWayDoubleDeltaEncoding andLength:&wayLength];
        int **wayNodes;
        [self createWayCoordinates:&wayNodes
            andProcessWayDataBlock:featureWayDoubleDeltaEncoding
                         andLength:&wayLength];
      if (wayNodes == nil) {
          free(labelPosition);
        return NO;
      }
        if (wayDataBlock == 0) {
            [mapDatabaseCallback addWay:wayId++ nodes:wayNodes length:wayLength labelPosition:labelPosition tags:tagsDict layer:layer];
        } else {
            [self free2DArray:wayNodes withNumberOfRows:*wayLength];
            free(wayLength);
        }
//    [mapDatabaseCallback renderWay:layer labelPosition:labelPosition tags:tags wayNodes:wayNodes];
    }
//    [tagsDict release];
  }

  return YES;
}

- (float *) readOptionalLabelPosition:(BOOL)featureLabelPosition {
  float * labelPosition = nil;
  if (featureLabelPosition) {
    labelPosition = (float*)malloc(2*sizeof(float));
    labelPosition[1] = tileLatitude + [readBuffer readSignedInt];
    labelPosition[0] = tileLongitude + [readBuffer readSignedInt];
  }
  return labelPosition;
}

- (int) readOptionalWayDataBlocksByte:(BOOL)featureWayDataBlocksByte {
  if (featureWayDataBlocksByte) {
    return [readBuffer readUnsignedInt];
  }
  return 1;
}

- (int)createAndReadZoomTable:(int***)zoomTable withSubFileParameter:(SubFileParameter *)subFileParameter {
  int rows = subFileParameter->zoomLevelMax - subFileParameter->zoomLevelMin + 1;
  *zoomTable = (int**)malloc(rows*sizeof(int*));
  int cumulatedNumberOfPois = 0;
  int cumulatedNumberOfWays = 0;

  for (int row = 0; row < rows; ++row) {
    (*zoomTable)[row] = (int*)malloc(2*sizeof(int));
    cumulatedNumberOfPois += [readBuffer readUnsignedInt];
    cumulatedNumberOfWays += [readBuffer readUnsignedInt];
    if (cumulatedNumberOfPois < 0 || cumulatedNumberOfPois > MAXIMUM_ZOOM_TABLE_OBJECTS) {
      NSLog(@"warning in -createAndReadZoomTable:withSubFileParameter: in MapDatabase.m: invalid cumulated number of POIs in row: %d %d", row, cumulatedNumberOfPois);
      if ([mapFileHeader mapFileInfo]->debugFile) {
        NSLog(@"warning in -processWays in MapDatabase.m: debug signature block: %@", signatureBlock);
      }
        [self free2DArray:*zoomTable withNumberOfRows:row + 1];
      return 0;
    }
     else if (cumulatedNumberOfWays < 0 || cumulatedNumberOfWays > MAXIMUM_ZOOM_TABLE_OBJECTS) {
       NSLog(@"warning in -createAndReadZoomTable:withSubFileParameter: in MapDatabase.m: invalid invalid cumulated number of ways in row: %d %d", row, cumulatedNumberOfWays);
      if ([mapFileHeader mapFileInfo]->debugFile) {
        NSLog(@"warning in -processWays in MapDatabase.m: debug signature block: %@", signatureBlock);
      }
         [self free2DArray:*zoomTable withNumberOfRows:row + 1];
      return 0;
    }
    (*zoomTable)[row][0] = cumulatedNumberOfPois;
    (*zoomTable)[row][1] = cumulatedNumberOfWays;
  }

  return rows;
}

- (void)free2DArray:(int**)array withNumberOfRows:(int)rows {
    for (int i = 0; i < rows; i++) {
        free(array[i]);
    }
    free(array);
}

//- (void) dealloc {
//  [databaseIndexCache release];
//  [inputFile release];
//  [mapFileHeader release];
//  [readBuffer release];
//  [signatureBlock release];
//  [signaturePoi release];
//  [signatureWay release];
//  [super dealloc];
//}

@end
