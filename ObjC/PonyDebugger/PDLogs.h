//
//  PDDebugger+Console.h
//  PonyConsole
//
//  Created by Olivier Halligon on 17/12/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import <PonyDebugger/PDDebugger.h>
#import <PonyDebugger/PDConsoleDomainController.h>

/* Log Standard Messages */
#define PDLogLevel(_level,_fmt,...)  [[PDDebugger console] logLevel:(_level) message:[NSString stringWithFormat:(_fmt), ##__VA_ARGS__] file:(@ __FILE__) line:__LINE__];
#define PDLog(_fmt,...)              PDLogLevel(PDConsoleLogLevelLog,     _fmt, ##__VA_ARGS__) /* Standard Log : plain text */
#define PDLogWarning(_fmt,...)       PDLogLevel(PDConsoleLogLevelWarning, _fmt, ##__VA_ARGS__) /* Warning Log : yellow icon */
#define PDLogFatal(_fmt,...)         PDLogLevel(PDConsoleLogLevelError,   _fmt, ##__VA_ARGS__) /* Fatal Log : red icon + stack trace */
#define PDLogInfo(_fmt,...)          PDLogLevel(PDConsoleLogLevelDebug,   _fmt, ##__VA_ARGS__) /* Info Log : blue icon, always visible */

/* Log NSArray, NSDictionary & NSErrors as nice recursive trees */
#define PDLogObject(_name,_object)   [[PDDebugger console] logObject:(_object) name:(_name) collapsed:YES]

/* Log trees/groups, to organize logs into hierarchical info */
#define PDLogGroup(_groupText,_collapse,_code)  [[PDDebugger console] logGroupMessage:(_groupText) file:(@ __FILE__) line:__LINE__ collapsed:_collapse execute:(_code)]
#define PDLogGroupStart(_groupText,_collapse)   [[PDDebugger console] startGroupMessage:(_groupText) file:(@ __FILE__) line:__LINE__ collapsed:_collapse]
#define PDLogGroupEnd()                         [[PDDebugger console] endGroupMessage]
