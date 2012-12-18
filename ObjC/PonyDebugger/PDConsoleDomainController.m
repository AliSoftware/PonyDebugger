//
//  PDConsoleDomainController.h
//  PonyDebugger
//
//  Created by Olivier Halligon on 17 Dec 2012.
//
//  MIT License
//

#import "PDConsoleDomainController.h"
#import "PDConsoleTypes.h"
#import <UIKit/UIKit.h>


@interface PDConsoleDomainController () <PDConsoleCommandDelegate>

@end


@implementation PDConsoleDomainController

@dynamic domain;
@synthesize echoInLocalConsole = _echoInLocalConsole;

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Statics

static NSString* const kPDConsoleLogTypeLog = @"log";
static NSString* const kPDConsoleLogTypeStartGroup = @"startGroup";
static NSString* const kPDConsoleLogTypeStartGroupCollapsed = @"startGroupCollapsed";
static NSString* const kPDConsoleLogTypeEndGroup = @"endGroup";

+ (PDConsoleDomainController *)defaultInstance;
{
    static PDConsoleDomainController *defaultInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[PDConsoleDomainController alloc] init];
    });
    
    return defaultInstance;
}

+ (Class)domainClass;
{
    return [PDConsoleDomain class];
}


////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods

-(void)logLevel:(PDConsoleLogLevel)level message:(NSString*)text type:(NSString*)type file:(NSString*)file line:(int)line
{
    PDConsoleConsoleMessage* message = [[PDConsoleConsoleMessage alloc] init];
    message.source = @"console-api";
    message.level = @[@"tip",@"log",@"warning",@"error",@"debug"][level];
    message.type = type;
    message.text = text;
    if (line < 0)
    {
        message.line = @(line);
    }
    
    if (level == PDConsoleLogLevelError)
    {
        /* Errors display full stack trace */
        NSArray* callframes = [NSThread callStackSymbols];
        NSMutableArray* stack = [NSMutableArray arrayWithCapacity:callframes.count];
        for(NSString* callframe in callframes)
        {
            PDConsoleCallFrame* cf = [[PDConsoleCallFrame alloc] init];
            
            NSString *libName = nil, *functionName = nil;
            NSScanner* scanner = [NSScanner scannerWithString:callframe];
            [scanner scanInteger:NULL]; // frame number
            [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&libName]; // Library Name
            [scanner scanHexInt:NULL]; // Function address
            [scanner scanUpToString:@" + " intoString:&functionName]; // Function Name
            
            cf.functionName = functionName;
            cf.url = [file hasPrefix:@"/"] ? [NSString stringWithFormat:@"file://%@",file] : file ?: [NSString stringWithFormat:@"(%@)",libName];
            cf.lineNumber = @(line);
            [stack addObject:cf];
            
            // Invalidate file & line for next iterations (next call frames) to avoid confusion
            line = 0;
            file = nil;
        }
        message.stackTrace = stack;
    }
    else
    {
        // Other logs don't display stack trace but still display file and line number
        PDConsoleCallFrame* topCallFrame = [[PDConsoleCallFrame alloc] init];
        topCallFrame.url = [file hasPrefix:@"/"] ? [NSString stringWithFormat:@"file://%@",file] : file ?: nil;
        topCallFrame.lineNumber = @(line);
        message.stackTrace = @[topCallFrame];
    }
    
    [self.domain messageAddedWithMessage:message];
    
    if (self.echoInLocalConsole)
    {
        if (message.line)
        {
            NSLog(@"[%@:%@] %@", [message.level uppercaseString], message.line, message.text);
        } else {
            NSLog(@"[%@] %@", [message.level uppercaseString], message.text);
        }
    }
}





////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public API


-(void)clearConsole
{
    //[self logMessage:@"== Clear ==" withLevel:(PDConsoleLogLevelLog) type:(PDConsoleLogTypeClear) line:-1];
    [self.domain messagesCleared];
}


-(void)logLevel:(PDConsoleLogLevel)level message:(NSString *)message file:(NSString*)file line:(int)line
{
    [self logLevel:level message:message type:kPDConsoleLogTypeLog file:file line:line];
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
    
    [self logLevel:level message:message type:kPDConsoleLogTypeLog file:nil line:-1];
}


#pragma mark Grouping Logs

-(void)logGroupMessage:(NSString*)message collapsed:(BOOL)collapsed execute:(dispatch_block_t)codeInGroup
{
    [self logGroupMessage:message file:nil line:-1 collapsed:collapsed execute:codeInGroup];
}
-(void)logGroupMessage:(NSString*)message file:(NSString*)file line:(int)line collapsed:(BOOL)collapsed execute:(dispatch_block_t)codeInGroup
{
    NSString* type = collapsed ? kPDConsoleLogTypeStartGroupCollapsed : kPDConsoleLogTypeStartGroup;
    [self logLevel:PDConsoleLogLevelLog message:message type:type file:file line:line];
    if (codeInGroup) codeInGroup();
    [self logLevel:PDConsoleLogLevelLog message:nil type:kPDConsoleLogTypeEndGroup file:file line:line];
}
-(void)startGroupMessage:(NSString*)message file:(NSString*)file line:(int)line collapsed:(BOOL)collapsed
{
    NSString* type = collapsed ? kPDConsoleLogTypeStartGroupCollapsed : kPDConsoleLogTypeStartGroup;
    [self logLevel:PDConsoleLogLevelLog message:message type:type file:file line:line];
}
-(void)endGroupMessage
{
    [self logLevel:PDConsoleLogLevelLog message:nil type:kPDConsoleLogTypeEndGroup file:nil line:-1];
}


#pragma mark - Object Logging

-(void)logObject:(id)object name:(NSString*)name
{
    [self logObject:object name:name collapsed:NO];
}

/* Handle nicely NSDictionary, NSArray, NSError objects */
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
    else if ([object isKindOfClass:[NSError class]])
    {
        /* NSError */
        NSError* error = (NSError*)object;
        NSString* errorDescription = [NSString stringWithFormat:@"<NSError %@ (%d): \"%@\">",
                                      error.domain, error.code, error.localizedDescription];
        if (name)
        {
            errorDescription = [NSString stringWithFormat:@"%@ = %@", name, errorDescription];
        }
        NSString* domainString = [NSString stringWithFormat:@"[%@]",error.domain];
        
        if (!error.userInfo)
        {
            // Flat log
            [self logLevel:PDConsoleLogLevelLog message:errorDescription file:domainString line:error.code];
        }
        else
        {
            // Hierarchical Log with UserInfo keys
            [self logGroupMessage:errorDescription file:domainString line:error.code collapsed:collapsed execute:^{
                // Enumerate NSError's userInfo dictionary
                [error.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [self logObject:obj name:key collapsed:collapsed];
                }];
            }];
        }
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

-(void)logViewHierarchy:(UIView*)rootView
{
    if (rootView.subviews.count == 0)
    {
        [self logLevel:PDConsoleLogLevelLog message:[rootView description]];
    }
    else
    {
        // Contains child views
        [self logGroupMessage:[rootView description] collapsed:YES execute:^{
            for(UIView* v in rootView.subviews)
            {
                [self logViewHierarchy:v];
            }
        }];
    }
}

@end

