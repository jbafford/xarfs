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

#import "XARDirectoryStructure.h"
#import <libgen.h>

@implementation XARDirectoryStructure

- (XARDirectoryItem*) getItemAtPath: (NSString*) path
{
	return [contents_ objectForKey: path];
}

- (void) buildContentsTreeFromXAR: (xar_t)xar
{
	NSMutableDictionary *contents = [NSMutableDictionary dictionaryWithCapacity: 1];
	
	//Make a fake item for /
	[contents setValue: [XARDirectoryItem createFakeRoot] forKey: @"/"];
	
	xar_iter_t i = xar_iter_new();
	if(i)
	{
		xar_file_t f;
		char *path;
		char *parentPath;
		NSString *nssParentPath;
		
		for(f = xar_file_first(xar, i); f; f = xar_file_next(i))
		{
			XARDirectoryItem *xarItem = [XARDirectoryItem fromXARFile: f];
			
			path = [xarItem getPath];
			parentPath = dirname(path);
			if(0 == strcmp(parentPath, "."))
			{
				parentPath = "/";
				nssParentPath = @"/";
			}
			else
				nssParentPath = [NSString stringWithFormat: @"/%s", parentPath];
			
			//Add this item to our global list of files
			[contents setValue: xarItem forKey: [NSString stringWithFormat: @"/%s", path]];
			
			//Add this item to its parent
			XARDirectoryItem *parent = [contents objectForKey: nssParentPath];
			[parent addContents:xarItem];
		}
		
		xar_iter_free(i);
	}
	
	contents_ = [contents retain];
}

#pragma mark Init and Dealloc

- (id)init
{
	return [self initWithXAR:nil];
}

- (id)initWithXAR: (xar_t) xar
{
	if((self = [super init]))
	{
		[self buildContentsTreeFromXAR: xar];
	}
	
	return self;
}

- (void)dealloc
{
	if(contents_)
		[contents_ release];
	
	[super dealloc];
}

+ (XARDirectoryStructure*) createFromXAR: (xar_t) xar
{
	return [[[XARDirectoryStructure alloc] initWithXAR:xar] autorelease];
}


@end
