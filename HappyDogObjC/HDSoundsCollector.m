//
//  HDSoundsCollector.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDSoundsCollector.h"

@interface HDSoundsCollector()

@property (nonatomic, strong) NSMutableArray *sounds;

@end

@implementation HDSoundsCollector

+ (HDSoundsCollector *)sharedInstance {
    static dispatch_once_t predicate = 0;
    static HDSoundsCollector *sharedObject = nil;
    
    dispatch_once(&predicate, ^{
        sharedObject = [[HDSoundsCollector alloc] init];
        sharedObject.sounds = [[NSMutableArray alloc] init];
    });
    
    return sharedObject;
}

- (void)addSound:(HDSoundRecording *)sound {
    HDSoundsCollector *collector = [HDSoundsCollector sharedInstance];
    [collector.sounds addObject:sound];
}

- (void)removeSound:(HDSoundRecording *)sound {
    HDSoundsCollector *collector = [HDSoundsCollector sharedInstance];
    [collector.sounds removeObject:sound];
}

- (NSArray *)allSounds {
    HDSoundsCollector *collector = [HDSoundsCollector sharedInstance];
    return collector.sounds;
}

- (BOOL)soundWithNameExists:(NSString *)name {
    HDSoundsCollector *collector = [HDSoundsCollector sharedInstance];
    BOOL nameExists = NO;

    for(HDSoundRecording *sound in collector.sounds) {
        if([sound.recordingName isEqualToString:name]) {
            nameExists = YES;
            break;
        }
    }
    
    return nameExists;
}


@end
