//
//  DBManager.m
//  TestTaskiOD
//
//  Created by Sergei Makarov on 24.04.15.
//  Copyright (c) 2015 Sergei Makarov. All rights reserved.
//

#import "DBManager.h"
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager
+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB
{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"song.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            /*cv.put("artworkUrl60", artworkUrl60);
             cv.put("artworkPath", artworkPath);
             cv.put("artistName", artistName);
             cv.put("collectionName", collectionName);
             cv.put("trackName", trackName);*/
            const char *sql_stmt =
            "create table if not exists songs (regno text primary key, artworkUrl60 text, artworkPath text, artistName text, collectionName text, trackName text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

-(BOOL) insert:(NSString*)key artworkUrl60:(NSString*)artworkUrl60
   artworkPath:(NSString*)artworkPath artistName:(NSString*)artistName
collectionName:(NSString*)collectionName trackName:(NSString*)trackName
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into songs (regno, artworkUrl60, artworkPath, artistName, collectionName, trackName) values (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                               key, artworkUrl60, artworkPath, artistName, collectionName, trackName];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}

-(NSArray*) getAll
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select * from songs"];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSMutableArray* result = [[NSMutableArray alloc] init];
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"artworkUrl60"];
                [dict setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"artworkPath"];
                [dict setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)] forKey:@"artistName"];
                [dict setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"collectionName"];
                [dict setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"trackName"];
                
                [result addObject:dict];
            }
            sqlite3_reset(statement);
            return result;
        }
    }
    return nil;
}
@end
