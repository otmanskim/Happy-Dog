//
//  HDSoundRecording.h
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDSoundRecording : NSObject

@property (nonatomic, strong) NSString *recordingName;
@property (nonatomic, strong) NSString *fileType;

- (instancetype)initWithName:(NSString *)name andFileType:(NSString *)fileType;

@end
