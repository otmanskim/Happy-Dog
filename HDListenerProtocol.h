//
//  HDListenerProtocol.h
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/19/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#ifndef HappyDogObjC_HDListenerProtocol_h
#define HappyDogObjC_HDListenerProtocol_h

@protocol HDListenerDelegate <NSObject>

- (void)barkDetected;
- (void)soundFinishedPlaying;
- (void)soundStartedPlaying;

@end

#endif
