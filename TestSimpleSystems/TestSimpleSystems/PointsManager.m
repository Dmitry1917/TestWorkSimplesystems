//
//  PointsManager.m
//  TestSimpleSystems
//
//  Created by Дмитрий on 19.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import "PointsManager.h"

#import "SomePoint.h"

@implementation PointsManager
{
    NSMutableArray *allPoints;
    NSString *urlOrIpServer;
}

+(PointsManager*)sharedInstance
{
    static PointsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PointsManager alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        allPoints = [NSMutableArray array];
        urlOrIpServer = @"";
    }
    return self;
}

-(void)setAddress:(NSString*)urlOrIp
{
    urlOrIpServer = [NSString stringWithString:urlOrIp];
}

-(void)loadAllPoints
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:3000/points",
                           urlOrIpServer];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:5];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSLog(@"get points response status: %ld", (long)[(NSHTTPURLResponse*)response statusCode]);
          NSLog(@"get points response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
          if ([(NSHTTPURLResponse*)response statusCode] == 200)
          {
              NSError *err;
              NSArray *pointsDictArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
              
              [allPoints removeAllObjects];
              
              for (NSDictionary *pointDict in pointsDictArray)
              {
                  SomePoint *point = [SomePoint pointFromDictionary:pointDict];
                  [allPoints addObject:point];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALL_POINTS_LOADED object:self];
          }
          else
          {
              NSLog(@"get points error: %@\ndata: %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALL_POINTS_FAILED object:self];
          }
      }] resume];
}

-(void)addPoint:(SomePoint*)point
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:3000/points",
                           urlOrIpServer];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:5];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dictPoint = [NSDictionary dictionaryWithObjectsAndKeys:
                               point.title, @"title",
                               [NSString stringWithFormat:@"%f", point.lat], @"lat",
                               [NSString stringWithFormat:@"%f", point.lng], @"lng",
                               point.desc, @"desc",
                               nil];
    
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictPoint options:0 error:&error];
    [request setHTTPBody:postData];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSLog(@"add point response status: %ld", (long)[(NSHTTPURLResponse*)response statusCode]);
          NSLog(@"add point response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
          if ([(NSHTTPURLResponse*)response statusCode] == 200)
          {
              NSError *err = nil;
              NSDictionary *pointDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
              
              SomePoint *point = [SomePoint pointFromDictionary:pointDict];
              [allPoints addObject:point];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_POINT_SUCCESS object:self];
          }
          else
          {
              NSLog(@"add point error: %@\ndata: %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_POINT_FAILED object:self];
          }
      }] resume];
}

-(void)getFullPointWithID:(NSString*)pointID
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:3000/points/%@",
                           urlOrIpServer, pointID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:5];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSLog(@"get point response status: %ld", (long)[(NSHTTPURLResponse*)response statusCode]);
          NSLog(@"get point response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
          if ([(NSHTTPURLResponse*)response statusCode] == 200)
          {
              NSError *err = nil;
              NSDictionary *pointDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
              
              SomePoint *point = [SomePoint pointFromDictionary:pointDict];
              [self replaceOrAddOrDeletePointWith:point Delete:NO];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_FULL_POINT_SUCCESS object:self];
          }
          else
          {
              NSLog(@"get point error: %@\ndata: %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_FULL_POINT_FAILED object:self];
          }
      }] resume];
}

-(void)updatePoint:(SomePoint*)point
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:3000/points/%@",
                           urlOrIpServer, point.pointID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:5];
    
    [request setHTTPMethod: @"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dictPoint = [NSDictionary dictionaryWithObjectsAndKeys:
                               point.title, @"title",
                               [NSString stringWithFormat:@"%f", point.lat], @"lat",
                               [NSString stringWithFormat:@"%f", point.lng], @"lng",
                               point.desc, @"desc",
                               nil];
    
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictPoint options:0 error:&error];
    [request setHTTPBody:postData];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSLog(@"update point response status: %ld", (long)[(NSHTTPURLResponse*)response statusCode]);
          NSLog(@"update point response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
          if ([(NSHTTPURLResponse*)response statusCode] == 200)
          {
              NSError *err = nil;
              NSDictionary *pointDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
              
              SomePoint *point = [SomePoint pointFromDictionary:pointDict];
              [self replaceOrAddOrDeletePointWith:point Delete:NO];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_POINT_SUCCESS object:self];
          }
          else
          {
              NSLog(@"update point error: %@\ndata: %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_POINT_FAILED object:self];
          }
      }] resume];
}

-(void)deletePointWithID:(NSString*)pointID
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:3000/points/%@",
                           urlOrIpServer, pointID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:5];
    
    [request setHTTPMethod: @"DELETE"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSLog(@"delete point response status: %ld", (long)[(NSHTTPURLResponse*)response statusCode]);
          NSLog(@"delete point response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
          if ([(NSHTTPURLResponse*)response statusCode] == 200)
          {
              NSError *err = nil;
              NSDictionary *pointDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
              
              SomePoint *point = [SomePoint pointFromDictionary:pointDict];
              [self replaceOrAddOrDeletePointWith:point Delete:YES];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DELETE_POINT_SUCCESS object:self];
          }
          else
          {
              NSLog(@"update point error: %@\ndata: %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DELETE_POINT_FAILED object:self];
          }
      }] resume];
}

-(SomePoint*)getResultFullPointWithID:(NSString *)pointID
{
    for (SomePoint *point in allPoints)
    {
        if ([point.pointID isEqualToString:pointID])
        {
            return point;
        }
    }
    return nil;
}

-(void)replaceOrAddOrDeletePointWith:(SomePoint*)point Delete:(bool)delete
{
    SomePoint *foundedOldPoint = nil;
    for (SomePoint *oldPoint in allPoints)
    {
        if ([oldPoint.pointID isEqualToString:point.pointID])
        {
            foundedOldPoint = oldPoint;
            break;
        }
    }
    
    if (foundedOldPoint)
    {
        [allPoints removeObject:foundedOldPoint];
    }
    if (!delete) [allPoints addObject:point];
}

-(NSArray <SomePoint*>*)getAllPoints
{
    return [NSArray arrayWithArray:allPoints];
}

@end
