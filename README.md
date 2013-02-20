![PonyDebugger Logo](https://github.com/square/PonyDebugger/raw/master/Documentation/Images/Logo.png)

PonyDebugger
============

PonyDebugger is a remote debugging toolset.  It is a client library and gateway
server combination that uses Chrome Developer Tools on your browser to debug
your application's network traffic and managed object contexts.

To use PonyDebugger, you must implement the client in your application and
connect it to the gateway server. There is currently an iOS client and the
gateway server.


PonyDebugger is licensed under the Apache Licence, Version 2.0
(http://www.apache.org/licenses/LICENSE-2.0.html).

Features
--------

### Network Traffic Debugging

PonyDebugger sends your application's network traffic through [ponyd](https://github.com/square/PonyDebugger/tree/master/ponyd), PonyDebugger's proxy server.  You use Inspector's Network tools to debug network traffic like how you would debug network traffic on a website in Google Chrome.

![PonyDebugger Network Debugging Screenshot](https://github.com/square/PonyDebugger/raw/master/Documentation/Images/NetworkDebugging.png)

PonyDebugger forwards network traffic, and does not sniff network traffic.  This means that traffic sent over a secure protocol (https) is debuggable.

Currently, the iOS client automatically proxies data that is sent via `NSURLConnection`.  This means that it will automatically work with AFNetworking, and other libraries that use `NSURLConnection` for network requests.

### Core Data Browser

The Core Data browsing feature allows you to register your applcation's `NSManagedObjectContext`s and browse all of its entities and managed objects.  You browse data from the IndexedDB section in the Resource tab in Chrome Developer Tools.

![PonyDebugger Core Data Browser Screenshot](https://github.com/square/PonyDebugger/raw/master/Documentation/Images/CoreDataBrowser.png)

These are read-only stores at the moment.  There are plans to implement data mutation in a future release.

### View Hierarchy Debugging

PonyDebugger displays your application's view hierarchy in the Elements tab of the Chrome Developer Tools. As you move through the XML tree, the corresponding views are highlighted in your app. You can edit the displayed attributes (i.e. frame, alpha, ...) straight from the Elements tab, and you can change which attributes to display by giving PonyDebugger an array of UIView key paths. Deleting a node in the elements panel will remove that node from the view hierarchy. Finally, when a view is highlighted, you can move it or resize it from the app using pan and pinch gestures.

![PonyDebugger View Hierarchy Debugging Screenshot](https://github.com/Flipboard/PonyDebugger/raw/master/Documentation/Images/ViewHierarchyDebugging.png)

An "inspect" mode can be entered by clicking on the magnifying glass in the lower left corner of the Developer Tools window. In this mode, tapping on a view in the iOS app will select the corresponding node in the elements panel. You can also hold and drag your finger around to see the different views highlighted. When you lift your finger, the highlighted view will be selected in the elements panel.

Currently only a subset of the actions possible from the elements panel have been implemented. There is significant room for continued work and improvement, but the current functionality should prove useful nonetheless.

### Remote Console Logging

Thanks to @AliSoftware's contribution, PonyDebugger can now also send debugging messages to the Chrome Inspector Console.

![PonyDebugger Network Debugging Screenshot](https://github.com/alisoftware/PonyDebugger/raw/master/Documentation/Images/Console.png)

You can filter your console messages by type (logs, warnings, errors) using the selector at the bottom of the Developer Tools window.

When logging messages or errors, you can organize your logs in a hierarchical way and log some "object trees" that are collapsable.
This is particularly useful to log dictionaries or large arrays because once you have inspected it, you can collapse it to its minimum size.

The methods in the iOS client take advantage of these features:

* When logging an NSDictionary or NSArray objet they are formatted using such collapsable trees
* NSError objects also display their userInfo dictionary as a subtree to make it more easy to read NSUnderlyingError keys and others.
For NSErrors, their domain and error code is reminded on the right of the console line (instead of the file name and line number).
* Dumping a recursive hierarchy of a given view is also possible using these methods
* When you send a log of type "Error", you can also see the stack trace (list of methods that have been called) to known exactly which method did call your method with the log.
* And much more possibilities!



Quick Start
-----------
Prerequisite: Xcode's Command Line Tools must be installed from the "Downloads" preference pane.

```sh

curl -sk https://cloud.github.com/downloads/square/PonyDebugger/bootstrap-ponyd.py | \
  python - --ponyd-symlink=/usr/local/bin/ponyd ~/Library/PonyDebugger
```

This will install `ponyd` script to `~/Library/PonyDebugger/bin/ponyd` and
attempt to symlink `/usr/local/bin/ponyd` to it. It will also download the
latest chrome dev tools source.

Then start the PonyDebugger gateway server

```sh
ponyd serve --listen-interface=127.0.0.1
```

In your browser, navigate to `http://localhost:9000`. You should see the
PonyGateway lobby. Now you need to integrate the client to your application.

For more detailed instructions, check out the gateway server
[README_ponyd](https://github.com/square/PonyDebugger/blob/master/README_ponyd.rst).

PonyDebugger iOS Client
=======================

The PonyDebugger iOS client lets you to debug your application's network requests and track your managed object contexts.

#### Technical

- Requires iOS 5.0 or above
- Uses ARC (Automatic Reference Counting).
- Uses SocketRocket as a WebSocket client.

Installing
----------

- Extract a tarball or zipball of the repository into your project directory.  If you prefer, you may also add the project
  as a submodule.  The iOS client uses [SocketRocket](https://github.com/square/SocketRocket) as a dependency, and it is included as a 
  submodule.
      
```
cd /path/to/YourApplication
mkdir Frameworks
git submodule add git://github.com/square/PonyDebugger.git Frameworks/PonyDebugger
git submodule update --init --recursive
```

- Add `PonyDebugger/PonyDebugger.xcodeproj` as a subproject.

![PonyDebugger Installing Subproject](https://github.com/square/PonyDebugger/raw/master/Documentation/Images/Installing_Subproject.png)

- In your Project Settings, add the PonyDebugger target as a Target Dependency in the Build Phases tab.

![PonyDebugger Installing Target Dependencies](https://github.com/square/PonyDebugger/raw/master/Documentation/Images/Installing_TargetDependencies.png)

- Link `libPonyDebugger.a`, `libSocketRocket.a`, and the Framework dependencies to your project.

![PonyDebugger Installing Link Libraries and Frameworks](https://github.com/square/PonyDebugger/raw/master/Documentation/Images/Installing_LinkLibraries.png)

- In your project's Build Settings, add `"$(CONFIGURATION_BUILD_DIR)/usr/local/include"`(with quotes) as a non-recursive Header Search Path.

![PonyDebugger Installing Header Search Path](https://github.com/square/PonyDebugger/raw/master/Documentation/Images/Installing_HeaderSearchPath.png)

- PonyDebugger and SocketRocket take advantage of Objective C's ability to add categories on an object, but this isn't enabled for static libraries by default. To enable this, add the `-ObjC` flag to the "Other Linker Flags" build setting.

![PonyDebugger Installing Other Linker Flags](https://github.com/square/PonyDebugger/raw/master/Documentation/Images/Installing_OtherLinkerFlags.png)

#### Framework Dependencies

Your .app must be linked against the following frameworks/dylibs in addition to `libPonyDebugger.a` and `libSocketRocket.a`.

- libicucore.dylib
- CFNetwork.framework
- CoreData.framework
- Security.framework
- Foundation.framework

Usage
-----

PonyDebugger's main entry points exist in the `PDDebugger` singleton.

``` objective-c
PDDebugger *debugger = [PDDebugger defaultInstance];
```

To open the connection to `ws://localhost:9000/device`:

``` objective-c
[debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
```

To manually close the connection:

``` objective-c
[debugger disconnect];
```

### Network Traffic Debugging

To enable network debugging:

``` objective-c
[debugger enableNetworkTrafficDebugging];
```

PonyDebugger inspects network data by injecting logic into `NSURLConnectionDelegate` classes. If you want PonyDebugger to automatically find these classes for you:

``` objective-c
[debugger forwardAllNetworkTraffic];
```

This will swizzle methods from private APIs, so you should ensure that this only gets invoked 
in debug builds.  To manually specify delegate classes:

``` objective-c
[debugger forwardNetworkTrafficFromDelegateClass:[MyClass class]];
```

These methods should be invoked before the connection is opened.

### Core Data Browser

PonyDebugger also allows you to browse your application's managed objects. First, enable Core Data debugging:

``` objective-c
[debugger enableCoreDataDebugging];
```

To register a managed object context:

``` objective-c
[debugger addManagedObjectContext:self.managedObjectContext withName:@"My MOC"];
```

### View Hierarchy Debugging

To enable view hierarchy debugging:

``` objective-c
[debugger enableViewHierarchyDebugging];
```

PonyDebugger will inject logic into `UIView` add/remove methods to monitor changes in the view hierarchy.

You can also set the attributes you want to see in the elements panel by passing an array of `UIView` key path strings

``` objective-c
[debugger setDisplayedViewAttributeKeyPaths:@[@"frame", @"hidden", @"alpha", @"opaque"]];
```

PonyDebugger uses KVO to monitor changes in the attributes of all views in the hierarchy, so the information in the elements panel stays fresh.

### Remote Console Logging

To enable PonyDebugger to send messages to the Chrome Developer Tools Console:

``` objective-c
[debugger enableRemoteConsole];
```

If you want your logs sent to the remote console to also be echoed in your Xcode console, turn on the corresponding property:

``` objective-c
[debugger setEchoRemoteConsoleLocally:YES];
```

Then to log messages into the remote console, you can use the methods defined in `<PonyDebugger/PDDebugger+Console.h>`:

``` objective-c
[debugger logLevel:PDConsoleLogLevelLog message:@"We are here"];
[debugger logLevel:PDConsoleLogLevelWarning message:@"Woops"];
```
You can also use the macros defined in `<PonyDebugger/PDLogs.h>` as a drop-in remplacement for the `NSLog` macro.
These macros are generally easier and shorter to call than the methods on the `defaultInstance`.
Besides, they insert the source file name and line number for you when appropriate:

``` objective-c
PDLog(@"Hello %@", name); // simple log
PDLogWarning(@"Huston we have a problem"); // warning log (yellow)
PDLogFatal(@"We should never go there!"); // error log (red) with stack track
PDLogObject(someDict, @"niceDictionary"); // collapsable log-tree

PDLogGroup(@"Refresh log details",YES,^{  // will create a "group" or "tree root"
	PDLog(@"Loading data..."); // will add this log as a child to the previous group
	[self loadData]; // if loadData itself generate some logs, those will be inside the group too
	PDLog(@"Updating model...");
	[self updateModel];
	PDLog(@"Done!");
}); // You will be able to hide or show the children as you please by expanding/collapsing the group in the console !
```

----

The repository contains a test application to demonstrate PonyDebugger's capabilities and usage.

### Known Issues / Improvements

 * `CoreData.framework` must be linked, even if you do not use the Core Data browsing functionality.
 * iOS 5.1 and below: In certain cases, -[NSURLConnectionDataDelegate connection:willSendRequest:redirectResponse:] will never get 
   called. PonyDebugger requires this call to know when the request was sent, and will warn you with a workaround 
   that the timestamp is inaccurate.

   To fix the timestamp, make sure that `Accept-Encoding` HTTP header in your `NSURLRequest` is not set (by default, iOS will set it to 
   `gzip, deflate`, which is usually adequate.

   AFNetworking users: if you subclass `AFHTTPClient`, call `[self setDefaultHeader:@"Accept-Encoding" value:nil];`.

Contributing
------------

Any contributors to the master PonyDebugger repository must sign the
[Individual Contributor License Agreement
(CLA)](https://spreadsheets.google.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1>).
It's a short form that covers our bases and makes sure you're eligible to
contribute.

When you have a change you'd like to see in the master repository, [send a pull
request](https://github.com/square/PonyDebugger/pulls). Before we merge your
request, we'll make sure you're in the list of people who have signed a CLA.

Some useful links:

- [Chrome Remote Debugging Documentation](https://developers.google.com/chrome-developer-tools/docs/protocol/tot/index)
- [WebKit Inspector Protocol Definition on GitHub](https://github.com/WebKit/webkit/blob/master/Source/WebCore/inspector/Inspector.json)

