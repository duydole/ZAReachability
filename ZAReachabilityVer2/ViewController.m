//
//  ViewController.m
//  ZAReachability
//
//  Created by Duy on 7/29/19.
//  Copyright © 2019 zalo. All rights reserved.
//

#import "ViewController.h"
#import <Network/Network.h>
#import "ZAReachability.h"

@interface ViewController () <NetworkChangeObservationProtocol>

@property (weak, nonatomic) IBOutlet UILabel *networkStatusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    ZANetworkStatus initStatus = [ZAReachability.sharedInstance currentNetworkStatus];
    switch (initStatus) {
        case ZANetworkStatusReachableViaWifi:
            NSLog(@"Reachable wifi");
            _networkStatusLabel.text = @"Reached Wifi";
            break;
        case ZANetworkStatusReachableViaCellular:
            NSLog(@"Reachable via Cellular");
            _networkStatusLabel.text = @"Reached Cellular";
            break;
        case ZANetworkStatusReachableViaOthers:
            NSLog(@"Reachable via Others");
            _networkStatusLabel.text = @"Reached internet (not determined)";
            
            break;
        case ZANetworkStatusUnReachable:
            NSLog(@"Unreachable");
            _networkStatusLabel.text = @"No internet";
            break;
        default:
            break;
    }
    
    [ZAReachability.sharedInstance addObserver:self];
}

- (void) statusDidChange:(ZANetworkStatus)status {
    switch (status) {
        case ZANetworkStatusReachableViaWifi:
            NSLog(@"Reachable wifi");
            _networkStatusLabel.text = @"Reached Wifi";
            break;
        case ZANetworkStatusReachableViaCellular:
            NSLog(@"Reachable via Cellular");
            _networkStatusLabel.text = @"Reached Cellular";
            break;
        case ZANetworkStatusReachableViaOthers:
            NSLog(@"Reachable via Others");
            _networkStatusLabel.text = @"Reached internet (not determined)";

            break;
        case ZANetworkStatusUnReachable:
            NSLog(@"Unreachable");
            _networkStatusLabel.text = @"No internet";
            break;
        default:
            break;
    }
}

@end
