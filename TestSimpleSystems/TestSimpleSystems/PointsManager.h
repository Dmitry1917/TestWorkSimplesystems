//
//  PointsManager.h
//  TestSimpleSystems
//
//  Created by Дмитрий on 19.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_ALL_POINTS_LOADED @"NOTIFICATION_ALL_POINTS_LOADED"
#define NOTIFICATION_ALL_POINTS_FAILED @"NOTIFICATION_ALL_POINTS_FAILED"

#define NOTIFICATION_ADD_POINT_SUCCESS @"NOTIFICATION_ADD_POINT_SUCCESS"
#define NOTIFICATION_ADD_POINT_FAILED @"NOTIFICATION_ADD_POINT_FAILED"

#define NOTIFICATION_GET_FULL_POINT_SUCCESS @"NOTIFICATION_GET_FULL_POINT_SUCCESS"
#define NOTIFICATION_GET_FULL_POINT_FAILED @"NOTIFICATION_GET_FULL_POINT_FAILED"

#define NOTIFICATION_UPDATE_POINT_SUCCESS @"NOTIFICATION_UPDATE_POINT_SUCCESS"
#define NOTIFICATION_UPDATE_POINT_FAILED @"NOTIFICATION_UPDATE_POINT_FAILED"

#define NOTIFICATION_DELETE_POINT_SUCCESS @"NOTIFICATION_DELETE_POINT_SUCCESS"
#define NOTIFICATION_DELETE_POINT_FAILED @"NOTIFICATION_DELETE_POINT_FAILED"

@class SomePoint;
@interface PointsManager : NSObject

+(PointsManager*)sharedInstance;

-(void)setAddress:(NSString*)urlOrIp;
-(void)loadAllPoints;
-(NSArray <SomePoint*>*)getAllPoints;

-(void)addPoint:(SomePoint*)point;
-(void)getFullPointWithID:(NSString*)pointID;
-(SomePoint*)getResultFullPointWithID:(NSString *)pointID;

-(void)updatePoint:(SomePoint*)point;
-(void)deletePointWithID:(NSString*)pointID;

@end
