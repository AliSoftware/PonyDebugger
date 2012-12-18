//
//  PDConsoleDomainController.h
//  PonyDebugger
//
//  Created by Olivier Halligon on 17 Dec 2012.
//
//  MIT License
//

#import <PonyDebugger/PonyDebugger.h>
#import <PonyDebugger/PDConsoleDomain.h>

typedef NS_ENUM(uint16_t, PDConsoleLogLevel) {
    PDConsoleLogLevelTip,
    PDConsoleLogLevelLog,
    PDConsoleLogLevelWarning,
    PDConsoleLogLevelError,
    PDConsoleLogLevelDebug
};

@class UIView;
@interface PDConsoleDomainController : PDDomainController

+ (PDConsoleDomainController *)defaultInstance;
@property (nonatomic, strong) PDConsoleDomain *domain;


////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public API

@property(nonatomic, assign) BOOL echoInLocalConsole; // NSLog the log messages in addition to send them to PonyDebugger?

-(void)clearConsole;
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


#pragma mark - Object Logging

-(void)logError:(NSError*)error;
-(void)logObject:(id)object name:(NSString*)name;
-(void)logViewHierarchy:(UIView*)rootView;


@end



