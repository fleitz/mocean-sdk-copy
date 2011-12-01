//
//  AdInterstitialView.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/24/11.
//

#import "AdInterstitialView.h"
#import "AdView_Private.h"
#import "AdDescriptor.h"
#import "Reachability.h"

#import "NotificationCenter.h"

#import "AdWebView.h"

#define kCloseButtonText @"Close"

@interface AdInterstitialView ()

- (void)showCloseButton;
- (void)scheduledButtonAction;
- (void)buttonsAction:(id)sender;
- (void)closeInterstitial:(NSNotification*)notification;

@end


@implementation AdInterstitialView

@dynamic delegate, showCloseButtonTime, autocloseInterstitialTime, closeButton;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
        // Initialization code.
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
			   site:(NSInteger)site
			   zone:(NSInteger)zone {
	self = [super initWithFrame:frame site:site zone:zone];
    if (self) {
    }
    return self;
}


- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Private


- (void)setDefaultValues {
    [super setDefaultValues];
    
    ((AdModel*)_adModel).isDisplayed = NO;
}

- (void)registerObserver {
    // start interstitial ad only if internet available      
    [super registerObserver];
    [[NotificationCenter sharedInstance] addObserver:self selector:@selector(buttonsAction:) name:kInvalidParamsServerResponseNotification object:nil];
    [[NotificationCenter sharedInstance] addObserver:self selector:@selector(buttonsAction:) name:kEmptyServerResponseNotification object:nil];
    [[NotificationCenter sharedInstance] addObserver:self selector:@selector(buttonsAction:) name:kFailAdDisplayNotification object:nil];
    [[NotificationCenter sharedInstance] addObserver:self selector:@selector(buttonsAction:) name:kFailAdDownloadNotification object:nil];
    [[NotificationCenter sharedInstance] addObserver:self selector:@selector(closeInterstitial:) name:kInterstitialAdCloseNotification object:nil];
}

- (void)dislpayAd:(NSNotification*)notification {
	NSDictionary *info = [notification object];
	AdView* adView = [info objectForKey:@"adView"];
	UIView* subView = [info objectForKey:@"subView"];
    NSString* contentWidth = [info objectForKey:@"contentWidth"];
    NSString* contentHeight = [info objectForKey:@"contentHeight"];
	
	if (adView == self) {
        AdModel* model = [self adModel];
        UIView* currentAdView = model.currentAdView;
        if (subView != currentAdView) {            
            model.snapshot = currentAdView;
            [self adModel].snapshotRAWData = nil;
            
            model.currentAdView = subView;
            subView.hidden = NO;
            
            // update content size if possible
            if (contentHeight && contentWidth) {
                model.contentSize = CGSizeMake([contentWidth floatValue], [contentHeight floatValue]);
            } else {
                model.contentSize = CGSizeZero;
            }
            
            // switch animation
            if (model.animateMode && currentAdView && subView) {
                CGRect prevAdFrame = subView.frame;
                CGRect startAdFrame = CGRectMake(prevAdFrame.origin.x-prevAdFrame.size.width, prevAdFrame.origin.y, prevAdFrame.size.width, prevAdFrame.size.height);
                subView.frame = startAdFrame;
                
                [UIView animateWithDuration:0.2 animations:^{
                    subView.frame = prevAdFrame;
                    CGRect newFrameForOldImage = CGRectMake(prevAdFrame.origin.x+prevAdFrame.size.width, prevAdFrame.origin.y, prevAdFrame.size.width, prevAdFrame.size.height);
                    currentAdView.frame = newFrameForOldImage;
                } completion:^(BOOL finished) {
                    UIView* oldView = model.snapshot;
                    
                    if (oldView && oldView.superview) {
                        [oldView removeFromSuperview];
                        model.snapshot = nil;
                    }
                }];
            } else if (model.snapshot) {
                [model.snapshot removeFromSuperview];
                model.snapshot = nil;
            }
            
            // Close button code
            if (!self.closeButton && !self.adModel.useCustomClose) {
                [self prepareResources];
                
                self.closeButton.frame = CGRectMake(self.frame.size.width - self.closeButton.frame.size.width - 11, 11, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
                self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
                
                self.closeButton.hidden = YES;
                
                [self addSubview:self.closeButton];
                if (((AdModel*)_adModel).showCloseButtonTime > 0 && !((AdModel*)_adModel).isDisplayed) {
                    [NSTimer scheduledTimerWithTimeInterval:((AdModel*)_adModel).showCloseButtonTime
                                                     target:self 
                                                   selector:@selector(showCloseButton)
                                                   userInfo:nil 
                                                    repeats:NO];
                }
                else {
                    [self showCloseButton];
                }
                if (((AdModel*)_adModel).autocloseInterstitialTime > 0) {
                    [NSTimer scheduledTimerWithTimeInterval:((AdModel*)_adModel).autocloseInterstitialTime
                                                     target:self 
                                                   selector:@selector(scheduledButtonAction) 
                                                   userInfo:nil 
                                                    repeats:NO];
                }
            }
            
            if (!((AdModel*)_adModel).isDisplayed) {
                ((AdModel*)_adModel).startDisplayDate = [NSDate date];
                ((AdModel*)_adModel).isDisplayed = YES;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self postAdDisplaydNotification];
            });
            //[[NotificationCenter sharedInstance] postNotificationName:kAdDisplayedNotification object:self];
        }
	}
}

- (void)showCloseButton {
	self.closeButton.hidden = NO;
}

- (void)scheduledButtonAction {
	[self performSelectorOnMainThread:@selector(buttonsAction:) withObject:self waitUntilDone:YES];
}

- (void)buttonsAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClosedAd:usageTimeInterval:)]) {
        NSDate* _startDate = ((AdModel*)_adModel).startDisplayDate;
        NSTimeInterval timeInterval = -[_startDate timeIntervalSinceNow];
        [self.delegate didClosedAd:self usageTimeInterval:timeInterval];
    } else {
        if (self.superview && self.window) {
            if ([sender isKindOfClass:[NSNotification class]]) {
                NSNotification* notification = sender;
                if ([notification object] == self) {
                    [[NotificationCenter sharedInstance] postNotificationName:kInterstitialAdCloseNotification object:self];
                    self.hidden = YES;
                } else if ([[notification object] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* info = [notification object];
                    AdView* adView = [info objectForKey:@"adView"];
                    if (adView == self) {
                        [[NotificationCenter sharedInstance] postNotificationName:kInterstitialAdCloseNotification object:self];
                        self.hidden = YES;
                    }
                }
            } else {
                [[NotificationCenter sharedInstance] postNotificationName:kInterstitialAdCloseNotification object:self];
                self.hidden = YES;
            }
        }
    }
}


#pragma mark -
#pragma mark Callback


//- (void) didClosedInterstitialAd:(id)sender usageTimeInterval:(NSTimeInterval)usageTimeInterval;
- (void)closeInterstitial:(NSNotification*)notification {
    AdView* adView = [notification object];
	
	if (adView == self) {
        id <AdViewDelegate> delegate = [self adModel].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(didClosedAd:usageTimeInterval:)]) {
            NSDate* _startDate = ((AdModel*)_adModel).startDisplayDate;
            NSTimeInterval timeInterval = -[_startDate timeIntervalSinceNow];
            [delegate didClosedAd:self usageTimeInterval:timeInterval];
        }
    }
}


#pragma mark -
#pragma mark Propertys


// @property (assign) id <AdViewDelegate> delegate;
- (void)setDelegate:(id <AdViewDelegate>)delegate {
	((AdModel*)_adModel).delegate = delegate;
}

- (id <AdViewDelegate>)delegate {
	return ((AdModel*)_adModel).delegate;
}

//@property NSTimeInterval showCloseButtonTime;
- (void)setShowCloseButtonTime:(NSTimeInterval)timeInterval {
	((AdModel*)_adModel).showCloseButtonTime = timeInterval;
}

- (NSTimeInterval)showCloseButtonTime {
	return ((AdModel*)_adModel).showCloseButtonTime;
}

//@property NSTimeInterval autocloseInterstitialTime;
- (void)setAutocloseInterstitialTime:(NSTimeInterval)timeInterval {
	((AdModel*)_adModel).autocloseInterstitialTime = timeInterval;
}

- (NSTimeInterval)autocloseInterstitialTime {
	return ((AdModel*)_adModel).autocloseInterstitialTime;
}



@end
