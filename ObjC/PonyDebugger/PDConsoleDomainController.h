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
#import <PonyDebugger/PDDebugger+Console.h>

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Statics

extern NSString* const kPDConsoleLogTypeLog;
extern NSString* const kPDConsoleLogTypeStartGroup;
extern NSString* const kPDConsoleLogTypeStartGroupCollapsed;
extern NSString* const kPDConsoleLogTypeEndGroup;



@class UIView;
@interface PDConsoleDomainController : PDDomainController

+ (PDConsoleDomainController *)defaultInstance;
@property (nonatomic, strong) PDConsoleDomain *domain;


////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

@property(nonatomic, assign) BOOL echoInLocalConsole; // NSLog the log messages in addition to send them to PonyDebugger?

-(void)clearConsole;
-(void)logLevel:(PDConsoleLogLevel)level message:(NSString*)text type:(NSString*)type file:(NSString*)file line:(int)line;

@end



