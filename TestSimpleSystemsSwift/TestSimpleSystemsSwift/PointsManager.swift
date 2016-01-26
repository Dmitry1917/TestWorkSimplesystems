//
//  PointsManager.swift
//  TestSimpleSystemsSwift
//
//  Created by DMITRY SINYOV on 26.01.16.
//  Copyright © 2016 DMITRY SINYOV. All rights reserved.
//

import UIKit

let NOTIFICATION_ALL_POINTS_LOADED = "NOTIFICATION_ALL_POINTS_LOADED"
let NOTIFICATION_ALL_POINTS_FAILED = "NOTIFICATION_ALL_POINTS_FAILED"

let NOTIFICATION_ADD_POINT_SUCCESS = "NOTIFICATION_ADD_POINT_SUCCESS"
let NOTIFICATION_ADD_POINT_FAILED = "NOTIFICATION_ADD_POINT_FAILED"

let NOTIFICATION_GET_FULL_POINT_SUCCESS = "NOTIFICATION_GET_FULL_POINT_SUCCESS"
let NOTIFICATION_GET_FULL_POINT_FAILED = "NOTIFICATION_GET_FULL_POINT_FAILED"

let NOTIFICATION_UPDATE_POINT_SUCCESS = "NOTIFICATION_UPDATE_POINT_SUCCESS"
let NOTIFICATION_UPDATE_POINT_FAILED = "NOTIFICATION_UPDATE_POINT_FAILED"

let NOTIFICATION_DELETE_POINT_SUCCESS = "NOTIFICATION_DELETE_POINT_SUCCESS"
let NOTIFICATION_DELETE_POINT_FAILED = "NOTIFICATION_DELETE_POINT_FAILED"

class PointsManager: NSObject {
    
    static let sharedInstance: PointsManager = {
        let instance = PointsManager()
        //тут можно проинициализировать
        return instance
    }()
    
    private var allPoints: Array<SomePoint> = []
    var urlOrIpServer = ""
    
    func setAdress(urlOrIp: String)
    {
        urlOrIpServer = urlOrIp
    }
    
    func loadAllPoints()
    {
        let urlString = String(format: "http://%@:3000/points", arguments: [urlOrIpServer])//"http://yandex.ru")
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                NSLog("get points response status: %ld", httpResponse.statusCode)
                if let httpData = data
                {
                    NSLog("get points response %@", String(data: httpData, encoding: NSUTF8StringEncoding)!)
                    
                    if httpResponse.statusCode == 200
                    {
                        do
                        {
                            let pointsDictArray: Array = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Array<NSDictionary>
                            
                            self.allPoints.removeAll()
                            
                            for pointDict in pointsDictArray
                            {
                                let point = SomePoint.pointFromDictionary(pointDict)
                                self.allPoints.append(point)
                            }
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ALL_POINTS_LOADED, object: nil)
                        }
                        catch let error as NSError
                        {
                            print("json error: \(error.localizedDescription)")
                        }
                    }
                    else
                    {
                        NSLog("get points error: %@", error!)
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ALL_POINTS_FAILED, object: nil)
                    }
                }
            }
        })
        
        dataTask.resume()
    }

}
/*
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
*/
