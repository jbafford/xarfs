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

#import "xarfs.h"

@implementation XARFS

#pragma mark GMUserFileSystem Delegate Operations

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error
{
	//NSLog(@"contentsOfDirectoryAtPath: %@\n", path);
	
	XARDirectoryItem *dir = [xarContents_ getItemAtPath: path];
	NSString *itemType;
	
	if(dir && ((itemType = [dir fileType]) == NSFileTypeDirectory))
	{
		if(error)
			*error = nil;
		
		return [dir getContentNames];
	}
	else
	{
		int err;
		
		if(!dir)
			err = ENOENT;
		else
			err = ENOTDIR;
		
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil];
		
		return nil;
	}
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path userData:(id)userData error:(NSError **)error
{
	XARDirectoryItem *item = [xarContents_ getItemAtPath: path];
	
	//NSLog(@"attributesOfItemAtPath: %@\n", path);
	
	if(item)
	{
		//NSLog(@"Attrs: %@", [item getFileAttributes]);
		
		return [item getFileAttributes];
	}
	else
	{
		//NSLog(@"attributesOfItemAtPath: no file: %@\n", path);
		
		if(error)
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
		
		return nil;
	}
}

- (NSData *)contentsAtPath:(NSString *)path
{
	XARDirectoryItem *item = [xarContents_ getItemAtPath: path];
	
	if(!item)
	{
		return nil;
	}
	else
	{
		char *buffer;
		int err;
		
		err = xar_extract_tobuffer(xar_, [item getXARFile], &buffer);
		
		return [NSData dataWithBytesNoCopy:buffer length:[item fileSize] freeWhenDone: YES];
	}
}

/*
- (UInt16)finderFlagsAtPath:(NSString *)path {
  return ([self nodeAtPath:path] ? kHasCustomIcon : 0);
}
*/

#pragma mark -

- (BOOL)valid
{
	return valid_;
}

#pragma mark Init and Dealloc

- (id)init
{
	return [self initWithXARFile:nil];
}

-(id)initWithXARFile:(NSString*)fileName
{
	if((self = [super init]))
	{
		const char *path = [fileName UTF8String];
		
		xar_ = xar_open(path, READ);
		
		if(xar_)
		{
			xarContents_ = [[XARDirectoryStructure createFromXAR:xar_] retain];
			valid_ = YES;
		}
		else
			valid_ = NO;
	}
	
	return self;
}

- (void)dealloc
{
	if(xar_)
		xar_close(xar_);
	
	[xarContents_ release];
	[super dealloc];
}

+ (id)createFromXARFile:(NSString*)fileName
{
	return [[[XARFS alloc] initWithXARFile:fileName] autorelease];
}

@end
