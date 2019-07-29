//
//  ZAReachability.h
//  ZAReachability
//
//  Created by Duy on 7/29/19.
//  Copyright © 2019 zalo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Network/Network.h>
#import "Reachability.h"

typedef NS_ENUM(NSUInteger, ZANetworkStatus) {
    ZANetworkStatusReachableViaWifi,
    ZANetworkStatusReachableViaCellular,
    ZANetworkStatusReachableViaOthers,
    ZANetworkStatusUnReachable
};

// implement this protocol to receive the notification when network status change.
@protocol NetworkChangeObservationProtocol <NSObject>

- (void) statusDidChange:(ZANetworkStatus)status;   // notify status change with ZANetworkStatus.

@end

NS_ASSUME_NONNULL_BEGIN

@interface ZAReachability : NSObject

+ (instancetype) sharedInstance;

// add a observer to observing the network status change through NetworkChangeObservationProtocol
- (void) addObserver:(id<NetworkChangeObservationProtocol>)observer;

// remove a Observer to stop observing network status change.
- (void) removeObserver:(id<NetworkChangeObservationProtocol>)observer;

// check current NetworkStatus.
- (ZANetworkStatus) currentNetworkStatus;

@end

NS_ASSUME_NONNULL_END
