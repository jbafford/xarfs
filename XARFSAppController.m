/*
	xarfs
	Copyright (c) 2008 - 2009, John Bafford
	http://bafford.com/software/xarfs/
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright
	  notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright
	  notice, this list of conditions and the following disclaimer in the
	  documentation and/or other materials provided with the distribution.
	* Neither the name of the <organization> nor the
	  names of its contributors may be used to endorse or promote products
	  derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY
	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "XARFSAppController.h"
#import "XARFSController.h"
#import "xarfs.h"
#import <OSXFUSE/GMUserFileSystem.h>

@implementation XARFSAppController

#pragma mark -

-(BOOL)mountXARFile:(NSString*)filename
{
	XARFSController *xarfsController = [XARFSController controllerFromXARFile:filename];
	
	if([xarfsController mount])
	{
		[mounts setValue:xarfsController forKey:filename];
		
		NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(didMount:) name:kGMUserFileSystemDidMount object:nil];
		[center addObserver:self selector:@selector(didUnmount:) name:kGMUserFileSystemDidUnmount object:nil];
		
		return YES;
	}
	else
	{
		return NO;
	}
}

-(BOOL)unmountFile:(NSString *)filename
{
	XARFSController *xarfsController = [mounts objectForKey:filename];
	
	if(xarfsController)
	{
		[xarfsController unmount];
		[mounts setValue:nil forKey:filename];
	}
	
	return NO;
}

-(void)unmountAll
{
	for(NSString *mount in mounts)
		[self unmountFile:mount];
}

#pragma mark Cocoa Delegates

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	mounts = [[NSMutableDictionary dictionaryWithCapacity: 1] retain];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	NSLog(@"openFile %@\n", filename);
	
	//It seems MacFUSE only allows one mount per application.
	if([mounts count] > 1)
		return NO;
	else
		return [self mountXARFile:filename];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self unmountAll];
		
	return NSTerminateNow;
}

@end

@implementation XARFSAppController (Notifications)

- (void)didMount:(NSNotification *)notification
{
	NSLog(@"didMount: %@", notification);
	
	NSDictionary* userInfo = [notification userInfo];
	NSString* mountPath = [userInfo objectForKey:@"mountPath"];
	NSString* parentPath = [mountPath stringByDeletingLastPathComponent];
	[[NSWorkspace sharedWorkspace] selectFile:mountPath inFileViewerRootedAtPath:parentPath];
}

- (void)didUnmount:(NSNotification*)notification
{
	NSLog(@"didUnmount: %@", notification);
	
	[[NSApplication sharedApplication] terminate:nil];
}

@end

