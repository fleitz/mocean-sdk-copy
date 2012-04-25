//
//  DelegateViewController.m
//  AdMobileSamples
//
//  Created by Constantine on 8/6/10.
//

#import "DelegateViewController.h"

@implementation DelegateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	_adView.updateTimeInterval = 30;
	_adView.delegate = self;
	_adView.contentAlignment = YES;
}

#pragma mark -
#pragma mark AdViewDelegate methodes

- (void)willReceiveAd:(id)sender {
	if (sender == _adView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"willReceiveAd" message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease]; 
            [alert show];
        });
	}
}

- (void)didReceiveAd:(id)sender {
	if (sender == _adView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveAd" message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease]; 
            [alert show]; 
        });
	}
}

- (void)didFailToReceiveAd:(id)sender withError:(NSError*)error {
	if (sender == _adView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"didFailToReceiveAd" message:[error description] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
	}
}


- (void)didReceiveThirdPartyRequest:(id)sender content:(NSDictionary*)content {
    if (sender == _adView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"didReceiveThirdPartyRequest" message:[content description] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
	}
}

- (void)adWillStartFullScreen:(id)sender {
	if (sender == _adView) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"adShouldStartFullScreen" message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
	}
}

- (void)adDidEndFullScreen:(id)sender {
	if (sender == _adView) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"adDidEndFullScreen" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
	}
}

- (BOOL)adShouldOpen:(id)sender withUrl:(NSURL*)url {
    if (sender == _adView) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"adShouldOpen withUrl:%@", [url absoluteString]] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
	}
    
    return YES;
}

- (void)ormmaProcess:(id)sender event:(NSString*)event parameters:(NSDictionary*)parameters {
    if (sender == _adView) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event message:[parameters description] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
	}
}

@end