//
//  NSError+PonyDebugger.m
//  PonyDebugger
//
//  Created by Olivier Halligon on 18/12/12.
//
//

#import "PDConsoleDomainController.h"
#import <UIKit/UIKit.h>

@interface UIView(PonyDebuggerRecursiveLog) @end

@implementation UIView(PonyDebuggerRecursiveLog)

-(void)ponyDebugger:(PDDebugger*)console logWithName:(NSString*)name collapsed:(BOOL)collapsed
{
    NSString* desc = name ? [NSString stringWithFormat:@"%@ = %@",name,self.description] : self.description;
    NSArray* subviews = self.subviews;
    if (!subviews.count)
    {
        [console logLevel:PDConsoleLogLevelLog message:desc];
    }
    else
    {
        [console logGroupMessage:desc collapsed:collapsed execute:^{
            // Iterate on each subviews
            [subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [obj ponyDebugger:console logWithName:nil collapsed:collapsed];
            }];
        }];
    }
}

@end
