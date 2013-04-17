/*
	xarfs
	Copyright (c) 2008 - 2013, John Bafford
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

#import <Cocoa/Cocoa.h>
#import <xar/xar.h>


@interface XARDirectoryItem : NSObject {
	xar_file_t xarFile_;
	
	const char *fName_;
	NSString *fileName_;
	NSString* fType_;
	UInt64 fileSize_;
	const char *fMode_;
	
	const char *fileModificationDate_;
	
	NSMutableDictionary *contents_;
	NSArray *contentNames_;
	NSDictionary *fileAttributes_;
}

- (char*)getPath;
- (NSString*) fileType;
- (UInt64) fileSize;
- (void) addContents: (XARDirectoryItem *) dirItem;
- (NSArray*) getContentNames;
- (NSDictionary*) getFileAttributes;
- (xar_file_t) getXARFile;

- (id)initWithXARFile: (xar_file_t) xarFile;
+ (XARDirectoryItem*) fromXARFile: (xar_file_t) xarFile;
+ (XARDirectoryItem*)createFakeRoot;

@end
