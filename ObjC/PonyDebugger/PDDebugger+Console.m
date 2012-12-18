//
//  PDDebugger+Console.m
//  PonyDebugger
//
//  Created by Olivier Halligon on 18/12/12.
//
//

#import "PDDebugger+Console.h"
#import "PDConsoleDomainController.h"


////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation PDDebugger (Console)

#pragma mark - Private Methods

- (PDConsoleDomainController*)consoleDomainController
{
    static PDConsoleDomainController* domainController = nil;
    if (!domainController)
    {
        domainController = (PDConsoleDomainController*) [[self domainForName:[PDConsoleDomainController domainName]] delegate];
    }
    return domainController;
}

#pragma mark - Public Methods

-(void)clearConsole
{
    [[self consoleDomainController] clearConsole];
}
-(void)setEchoRemoteConsoleLocally:(BOOL)echo
{
    [[self consoleDomainController] setEchoInLocalConsole:echo];
}

#pragma mark Standard Logs

-(void)logLevel:(PDConsoleLogLevel)level message:(NSString *)message file:(NSString*)file line:(int)line
{
    [[self consoleDomainController] logLevel:level message:message type:kPDConsoleLogTypeLog file:file line:line];
}
-(void)logLevel:(PDConsoleLogLevel)level message:(NSString *)message
{
    [self logLevel:level message:message file:nil line:0];
}

-(void)logLevel:(PDConsoleLogLevel)level format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [[self consoleDomainController] logLevel:level message:message type:kPDConsoleLogTypeLog file:nil line:0];
}


#pragma mark Grouping Logs

-(void)logGroupMessage:(NSString*)message collapsed:(BOOL)collapsed execute:(dispatch_block_t)codeInGroup
{
    [self logGroupMessage:message file:nil line:0 collapsed:collapsed execute:codeInGroup];
}
-(void)logGroupMessage:(NSString*)message file:(NSString*)file line:(int)line collapsed:(BOOL)collapsed execute:(dispatch_block_t)codeInGroup
{
    NSString* type = collapsed ? kPDConsoleLogTypeStartGroupCollapsed : kPDConsoleLogTypeStartGroup;
    [[self consoleDomainController] logLevel:PDConsoleLogLevelLog message:message type:type file:file line:line];
    if (codeInGroup) codeInGroup();
    [[self consoleDomainController] logLevel:PDConsoleLogLevelLog message:nil type:kPDConsoleLogTypeEndGroup file:file line:line];
}
-(void)startGroupMessage:(NSString*)message file:(NSString*)file line:(int)line collapsed:(BOOL)collapsed
{
    NSString* type = collapsed ? kPDConsoleLogTypeStartGroupCollapsed : kPDConsoleLogTypeStartGroup;
    [[self consoleDomainController] logLevel:PDConsoleLogLevelLog message:message type:type file:file line:line];
}
-(void)endGroupMessage
{
    [[self consoleDomainController] logLevel:PDConsoleLogLevelLog message:nil type:kPDConsoleLogTypeEndGroup file:nil line:0];
}


#pragma mark Logging object trees

-(void)logObject:(id)object name:(NSString*)name
{
    [self logObject:object name:name collapsed:NO];
}

/* Handle nicely NSDictionary, NSArray, and other tree-like objects */
-(void)logObject:(id)object name:(NSString*)name collapsed:(BOOL)collapsed
{
    if ([object respondsToSelector:@selector(enumerateObjectsUsingBlock:)])
    {
        /* NSArray */
        [self logGroupMessage:name collapsed:collapsed execute:^{
            [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self logObject:obj name:[NSString stringWithFormat:@"[%d]",idx] collapsed:collapsed];
            }];
        }];
    }
    else if ([object respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)])
    {
        /* NSDictionary */
        [self logGroupMessage:name collapsed:collapsed execute:^{
            [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self logObject:obj name:key collapsed:collapsed];
            }];
        }];
    }
    else if ([object respondsToSelector:@selector(ponyDebugger:logWithName:collapsed:)])
    {
        // Objects that support this informal protocol
        [object ponyDebugger:self logWithName:name collapsed:collapsed];
    }
    else
    {
        /* Other Objects */
        if (name)
        {
            [self logLevel:PDConsoleLogLevelLog format:@"%@ = %@", name, object];
        }
        else
        {
            [self logLevel:PDConsoleLogLevelLog message:object];
        }
    }
}


@end
