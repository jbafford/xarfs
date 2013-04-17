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

#import "XARFSController.h"
#import "xarfs.h"
#import <OSXFuse/GMUserFileSystem.h>

@interface XARFSController()

@property (nonatomic, retain) XARFS *xarfs;
@end

@implementation XARFSController

- (BOOL) mount
{
	self.xarfs = [XARFS createFromXARFile:xarFileName];
	
	NSString *xarName = [xarFileName lastPathComponent];
	
	NSMutableArray* options = [NSMutableArray array];
	[options addObject:@"ro"];
	[options addObject: [NSString stringWithFormat: @"volname=%@", xarName]];
/*
	[options addObject:
		[NSString stringWithFormat:@"volicon=%@", 
			[[NSBundle mainBundle] pathForResource:@"ytfs" ofType:@"icns"]]];
*/
	
	NSString *mountPoint = [NSString stringWithFormat:@"/Volumes/xarfs_%@", xarName];
	
	fs_ = [[GMUserFileSystem alloc] initWithDelegate:self.xarfs isThreadSafe:YES];
	[fs_ mountAtPath:mountPoint withOptions:options];
	
	return YES;
}

-(void)unmount
{
	[fs_ unmount];
	[fs_ release];
	
	self.xarfs = nil;
}

#pragma mark -
#pragma mark Delegates

#pragma mark -

- (id)init
{
	return [self initWithXARFile:nil];
}

- (id)initWithXARFile: (NSString*)fileName
{
	if((self = [super init]))
	{
		xarFileName = [fileName retain];
	}
	
	return self;
}

- (void)dealloc
{
	[xarFileName release];
	
	[super dealloc];
}

+ (id)controllerFromXARFile:(NSString*) fileName
{
	return [[[self alloc] initWithXARFile:fileName] autorelease];
}

@end
