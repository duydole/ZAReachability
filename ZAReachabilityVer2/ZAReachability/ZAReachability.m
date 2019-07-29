//
//  ZAReachability.m
//  ZAReachability
//
//  Created by Duy on 7/29/19.
//  Copyright © 2019 zalo. All rights reserved.
//

#import "ZAReachability.h"
#import <UIKit/UIKit.h>

@interface ZAReachability()

@property (nonatomic) nw_path_monitor_t nwPathMonitor;
@property (nonatomic) Reachability *reachabilityMonitor;
@property (nonatomic) NSMutableArray *listObservers;
@property dispatch_queue_t zaReachabilitySerialQueue;
@property ZANetworkStatus currentNWPathStatus;

@end

@implementation ZAReachability

+ (id) sharedInstance {
    static ZAReachability *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup {
    _listObservers = [[NSMutableArray alloc] init];
    _zaReachabilitySerialQueue = dispatch_queue_create("duydl.zareachability.serial", DISPATCH_QUEUE_SERIAL);
    
    if (@available(iOS 12, *)) {
        
        _nwPathMonitor = nw_path_monitor_create();
        nw_path_monitor_set_queue(_nwPathMonitor, _zaReachabilitySerialQueue);
        nw_path_monitor_set_update_handler(_nwPathMonitor, ^(nw_path_t  _Nonnull path) {
            
            nw_path_status_t netPathStatus = nw_path_get_status(path);
            BOOL isWifi = nw_path_uses_interface_type(path, nw_interface_type_wifi);
            BOOL isCellular = nw_path_uses_interface_type(path, nw_interface_type_cellular);

            // check status:
            if (netPathStatus == nw_path_status_satisfied) {
                if (isWifi) {
                    self.currentNWPathStatus = ZANetworkStatusReachableViaWifi;
                } else if (isCellular) {
                    self.currentNWPathStatus = ZANetworkStatusReachableViaCellular;
                } else  {
                    self.currentNWPathStatus = ZANetworkStatusReachableViaOthers;
                }
            } else {
                self.currentNWPathStatus = ZANetworkStatusUnReachable;
            }
            
            for (id<NetworkChangeObservationProtocol> observer in self.listObservers) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [observer statusDidChange:self.currentNWPathStatus];
                });
            }
        });

        // start monitor:
        nw_path_monitor_start(_nwPathMonitor);
    } else {
        
        // < iOS 12
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        self.reachabilityMonitor = [Reachability reachabilityForInternetConnection];
        [self.reachabilityMonitor startNotifier];
    }
}

- (void) addObserver:(id<NetworkChangeObservationProtocol>)observer {
    if (observer) {
        dispatch_sync(_zaReachabilitySerialQueue, ^{
            [self.listObservers addObject:observer];
        });
    }
}

- (void) removeObserver:(id<NetworkChangeObservationProtocol>)observer {
    if (observer && _listObservers.count > 0) {
        dispatch_sync(_zaReachabilitySerialQueue, ^{
            [self.listObservers removeObject:observer];
        });
    }
}

- (void) reachabilityChanged: (NSNotification *)noti {
    Reachability* reachability = [noti object];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];     // status of network.
    
    if (netStatus == ReachableViaWiFi) {
        for (id<NetworkChangeObservationProtocol> observer in self.listObservers) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer statusDidChange:ZANetworkStatusReachableViaWifi];
            });
        }
    } else if (netStatus == ReachableViaWWAN) {
        for (id<NetworkChangeObservationProtocol> observer in self.listObservers) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer statusDidChange:ZANetworkStatusReachableViaCellular];
            });
        }
    } else {
        for (id<NetworkChangeObservationProtocol> observer in self.listObservers) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer statusDidChange:ZANetworkStatusUnReachable];
            });
        }
    }
}

- (ZANetworkStatus) currentNetworkStatus {
    if (@available(iOS 12, *)) {
        return _currentNWPathStatus;
    } else {
        NetworkStatus status = [_reachabilityMonitor currentReachabilityStatus];
        switch (status) {
            case ReachableViaWiFi:
                return ZANetworkStatusReachableViaWifi;
                break;
            case ReachableViaWWAN:
                return ZANetworkStatusReachableViaCellular;
                break;
            case NotReachable:
                return ZANetworkStatusUnReachable;
                break;
            default:
                break;
        }
    }
}

@end
