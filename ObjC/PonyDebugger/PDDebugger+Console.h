//
//  PDDebugger+Console.h
//  PonyDebugger
//
//  Created by Olivier Halligon on 18/12/12.
//
//

#import <PonyDebugger/PonyDebugger.h>

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Opt-In Recursive Logging Customization

@interface NSObject(PonyDebuggerRecursiveLog)
// implement this method in your classes or in categories to customize the formatting of those classes
-(void)ponyDebugger:(PDDebugger*)console logWithName:(NSString*)name collapsed:(BOOL)collapsed;
@end

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Console Log Level

typedef NS_ENUM(uint16_t, PDConsoleLogLevel) {
    PDConsoleLogLevelTip,
    PDConsoleLogLevelLog,
    PDConsoleLogLevelWarning,
    PDConsoleLogLevelError,
    PDConsoleLogLevelDebug
};

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface PDDebugger (Console)

#pragma mark Public Methods

-(void)clearConsole;
-(void)setEchoRemoteConsoleLocally:(BOOL)echo;

#pragma mark Standard Logs

-(void)logLevel:(PDConsoleLogLevel)level message:(NSString *)message;
-(void)logLevel:(PDConsoleLogLevel)level message:(NSString *)message file:(NSString*)file line:(int)line;
-(void)logLevel:(PDConsoleLogLevel)level format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

#pragma mark Grouping Logs

// These calls "startGroupMessage:file:line:collapsed:" then the codeInGroup() block, then "endGroupMessage", so that's easier to call, indent and read
-(void)logGroupMessage:(NSString*)message collapsed:(BOOL)collapsed execute:(dispatch_block_t)codeInGroup;
-(void)logGroupMessage:(NSString*)message file:(NSString*)file line:(int)line collapsed:(BOOL)collapsed execute:(dispatch_block_t)codeInGroup;
// These are the separate start/end calls, that needs to be balanced manually, in rare cases the start/end calls can't be in the same method (async calls, …)
-(void)startGroupMessage:(NSString*)message file:(NSString*)file line:(int)line collapsed:(BOOL)collapsed;
-(void)endGroupMessage;

#pragma mark Logging object trees

/* Render nicely NSDictionary, NSArray, NSError and other objects as a tree hierarchy */
// Implement "ponyDebugger:logWithName:collapsed:" in your own classes to support logging your objets as nice collapsable trees
-(void)logObject:(id)object name:(NSString*)name; /* collapsed:NO by default */
-(void)logObject:(id)object name:(NSString*)name collapsed:(BOOL)collapsed;

@end

