//
//  DBManager.h
//  TestTaskiOD
//
//  Created by Sergei Makarov on 24.04.15.
//  Copyright (c) 2015 Sergei Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
/*cv.put("artworkUrl60", artworkUrl60);
 cv.put("artworkPath", artworkPath);
 cv.put("artistName", artistName);
 cv.put("collectionName", collectionName);
 cv.put("trackName", trackName);*/

-(BOOL) insert:(NSString*)key artworkUrl60:(NSString*)artworkUrl60 artworkPath:(NSString*)artworkPath artistName:(NSString*)artistName collectionName:(NSString*)collectionName trackName:(NSString*)trackName;
-(NSArray*) getAll;

@end
