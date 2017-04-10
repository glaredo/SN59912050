//
//  DeviceUserMap.m
//  Alike
//
//  Created by Rajesh Mehta on 5/29/16.
//  Copyright © 2016 Alike. All rights reserved.
//

#import "DeviceUserMap.h"

@implementation DeviceUserMap

+(DeviceUserMap *)deviceMapWith:(NSString *)userId deviceId:(NSString *)deviceId {
    DeviceUserMap* map = [[DeviceUserMap alloc] init];
    map.userId = userId;
    map.deviceId = deviceId;
    
    return map;
}

@end
