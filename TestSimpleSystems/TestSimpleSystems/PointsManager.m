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
                  SomePoint *point = [[SomePoint alloc] init];
#warning что с id
#warning вынести парсинг словаря в SomePoint class
                  point.title = [pointDict objectForKey:@"title"];
                  point.lat = [[pointDict objectForKey:@"lat"] doubleValue];
                  point.lng = [[pointDict objectForKey:@"lng"] doubleValue];
                  
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

-(NSArray <SomePoint*>*)getAllPoints
{
    return [NSArray arrayWithArray:allPoints];
}

@end
