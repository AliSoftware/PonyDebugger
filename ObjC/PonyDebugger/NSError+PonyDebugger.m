//
//  NSError+PonyDebugger.m
//  PonyDebugger
//
//  Created by Olivier Halligon on 18/12/12.
//
//

#import "PDConsoleDomainController.h"


@interface NSError (PonyDebuggerRecursiveLog) @end

@implementation NSError(PonyDebuggerRecursiveLog)

-(void)ponyDebugger:(PDDebugger*)console logWithName:(NSString*)name collapsed:(BOOL)collapsed
{
    NSString* errorDescription = [NSString stringWithFormat:@"<NSError %@ (%d): \"%@\">",
                                  self.domain, self.code, self.localizedDescription];
    if (name)
    {
        errorDescription = [NSString stringWithFormat:@"%@ = %@", name, errorDescription];
    }
    NSString* domainString = [NSString stringWithFormat:@"[%@]",self.domain];
    
    if (!self.userInfo)
    {
        // Flat log
        [console logLevel:PDConsoleLogLevelLog message:errorDescription file:domainString line:self.code];
    }
    else
    {
        // Hierarchical Log with UserInfo keys
        [console logGroupMessage:errorDescription file:domainString line:self.code collapsed:collapsed execute:^{
            // Enumerate NSError's userInfo dictionary
            [self.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [console logObject:obj name:key collapsed:collapsed];
            }];
        }];
    }
}

@end
