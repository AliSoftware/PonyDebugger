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


////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Statics

NSString* const kPDConsoleLogTypeLog = @"log";
NSString* const kPDConsoleLogTypeStartGroup = @"startGroup";
NSString* const kPDConsoleLogTypeStartGroupCollapsed = @"startGroupCollapsed";
NSString* const kPDConsoleLogTypeEndGroup = @"endGroup";


@interface PDConsoleDomainController () <PDConsoleCommandDelegate>

@end


@implementation PDConsoleDomainController

@dynamic domain;
@synthesize echoInLocalConsole = _echoInLocalConsole;

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Statics

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
    static int indentationLevel = 0;
    
    PDConsoleConsoleMessage* message = [[PDConsoleConsoleMessage alloc] init];
    message.source = @"console-api";
    message.level = @[@"tip",@"log",@"warning",@"error",@"debug"][level];
    message.type = type;
    message.text = text;
    if (line > 0)
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
        if ([type isEqualToString:kPDConsoleLogTypeEndGroup])
            --indentationLevel;
        
        if (message.text)
        {
            NSString* indent = [@"" stringByPaddingToLength:(3*indentationLevel) withString:@" | " startingAtIndex:0];
            if (message.line && ([message.line intValue]>0))
            {
                NSLog(@"[%@:%@] %@%@", [message.level uppercaseString], message.line, indent, message.text);
            } else {
                NSLog(@"[%@] %@%@", [message.level uppercaseString], indent, message.text);
            }
        }
        
        if (([type isEqualToString:kPDConsoleLogTypeStartGroup]) || ([type isEqualToString:kPDConsoleLogTypeStartGroupCollapsed]))
            ++indentationLevel;
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


-(void)clearConsole
{
    //[self logMessage:@"== Clear ==" withLevel:(PDConsoleLogLevelLog) type:(PDConsoleLogTypeClear) line:-1];
    [self.domain messagesCleared];
}


@end


