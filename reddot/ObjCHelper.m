//
//  ObjCHelper.m
//  reddot
//
//  Created by Soongyu Kwon on 9/12/22.
//

#import "ObjCHelper.h"

#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation ObjCHelper

- (void)imageToCPBitmap:(UIImage *)img path:(NSString *)path {
    [img writeToCPBitmapFile:path flags:1];
}

@end
