//
//  HDSoundsCollector.h
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDSoundRecording.h"

@interface HDSoundsCollector : NSObject

+ (HDSoundsCollector *)sharedInstance;

- (void)addSound:(HDSoundRecording *)sound;
- (void)removeSound:(HDSoundRecording *)sound;
- (NSArray *)allSounds;

- (BOOL)soundWithNameExists:(NSString *)name;


@end
