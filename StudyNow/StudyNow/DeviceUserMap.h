//
//  DeviceUserMap.h
//  Alike
//
//  Created by Rajesh Mehta on 5/29/16.
//  Copyright © 2016 Alike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUserMap : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *deviceId;

+(DeviceUserMap *)deviceMapWith:(NSString *)userId deviceId:(NSString *)deviceId;

@end
