//
//  HDSoundRecording.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDSoundRecording.h"

@implementation HDSoundRecording

- (instancetype)initWithName:(NSString *)name andFileType:(NSString *)fileType {
    self = [super init];
    
    if (self) {
        self.fileType = fileType;
        self.recordingName = name;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.recordingName = [aDecoder decodeObjectForKey:@"recordingName"];
        self.fileType = [aDecoder decodeObjectForKey:@"fileType"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.recordingName forKey:@"recordingName"];
    [aCoder encodeObject:self.fileType forKey:@"fileType"];
}



@end
