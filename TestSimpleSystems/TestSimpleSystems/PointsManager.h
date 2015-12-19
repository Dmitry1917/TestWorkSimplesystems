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

@class SomePoint;
@interface PointsManager : NSObject

+(PointsManager*)sharedInstance;

-(void)setAddress:(NSString*)urlOrIp;
-(void)loadAllPoints;
-(NSArray <SomePoint*>*)getAllPoints;


@end
