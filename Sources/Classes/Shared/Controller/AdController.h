//
//  AdController.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/24/11.
//

#import <Foundation/Foundation.h>


#import "NotificationCenter.h"
#import "AdView_Private.h"
#import "AdDescriptor.h"
#import "AdView.h"
#import "AdModel.h"
#import "AdUpdater.h"
#import "LocationManager.h"


@interface AdController : NSObject <UIWebViewDelegate>{
	NSMutableArray*		_ads;
	NSMutableArray*		_adUpdateControllers;
	
    AdView*             _adView;
    
    BOOL                _isRequestRedirect;
    NSString*           _FirstRequestString;
    
}

+ (AdController*)sharedInstance;
+ (void)releaseSharedInstance;

@end
