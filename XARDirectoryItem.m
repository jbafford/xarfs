/*
	xarfs
	Copyright (c) 2008 - 2013, John Bafford
	http://bafford.com/software/xarfs/
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met: 

	1. Redistributions of source code must retain the above copyright notice, this
	   list of conditions and the following disclaimer. 
	2. Redistributions in binary form must reproduce the above copyright notice,
	   this list of conditions and the following disclaimer in the documentation
	   and/or other materials provided with the distribution. 

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
	ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "XARDirectoryItem.h"

NSString* makeXARTypeFromStr(const char *xarType)
{
	if(0 == strcmp(xarType, "file"))
		return NSFileTypeRegular;
	if(0 == strcmp(xarType, "directory"))
		return NSFileTypeDirectory;
	if(0 == strcmp(xarType, "fifo"))
		return  NSFileTypeUnknown;
	if(0 == strcmp(xarType, "character special"))
		return NSFileTypeCharacterSpecial;
	if(0 == strcmp(xarType, "block special"))
		return NSFileTypeBlockSpecial;
	if(0 == strcmp(xarType, "socket"))
		return NSFileTypeSocket;
	
	return NSFileTypeUnknown;
}

NSDate* makeNSDateFromXARDate(const char *xarDate)
{
	//xar seems to always encode the time according to GMT
	//From: 2008-03-10T20:03:01Z
	struct tm t;
	
	//This is what xar does
	memset(&t, 0, sizeof(t));
	strptime(xarDate, "%FT%T", &t);
	
	return [NSDate dateWithTimeIntervalSince1970: timegm(&t)];
}

@interface XARDirectoryItem() {
	BOOL _isFakeRoot;
	char *_fPath; //cached result of xar_get_path; we must release
}
@end

@implementation XARDirectoryItem

- (char*)getPath
{
	return _fPath;
}

- (NSString*) fileType
{
	return fType_;
}

- (UInt64) fileSize
{
	return fileSize_;
}

- (void) addContents: (XARDirectoryItem *) dirItem
{
	[contents_ setValue: dirItem forKey: dirItem->fileName_];
}

- (NSArray*) getContentNames
{
	if(!contentNames_)
	{
		NSMutableArray *contents = [[NSMutableArray arrayWithCapacity: [contents_ count]] retain];
		
		for(XARDirectoryItem *item in contents_)
		{
			[contents addObject: item];
		}
		
		contentNames_ = contents;
	}
	
	//NSLog(@"getContentNames: %@", contentNames_);
	
	return contentNames_;
}

/*
	Returns a dictionary of NSFileManager File Attribute Keys
*/
- (NSDictionary*) getFileAttributes
{
	if(!fileAttributes_)
	{
		NSMutableDictionary *attrs = [[NSMutableDictionary dictionaryWithCapacity: 1] retain];
		
		[attrs setValue:fType_ forKey: NSFileType];
		
		if(fType_ == NSFileTypeRegular)
			[attrs setValue: [NSNumber numberWithLongLong: fileSize_] forKey: NSFileSize];
		
		if(fileModificationDate_)
			[attrs setValue: makeNSDateFromXARDate(fileModificationDate_) forKey: NSFileModificationDate];
		
		if(fMode_)
		{
			int mode = strtol(fMode_, NULL, 8);
			
			[attrs setValue:[NSNumber numberWithLong: mode] forKey:NSFilePosixPermissions];
		}
		
		fileAttributes_ = attrs;
	}
	
	return fileAttributes_;
}

- (xar_file_t) getXARFile
{
	return xarFile_;
}

#pragma mark Init and Dealloc

- (id)init
{
	return [self initWithXARFile:nil];
}

- (void)basicInit
{
	xarFile_ = nil;
	
	fType_ = NSFileTypeUnknown;
	
	contents_ = nil;
	contentNames_ = nil;
	fileAttributes_ = nil;
}

- (id)initAsFakeRoot
{
	if((self = [super init]))
	{
		[self basicInit];
		
		_isFakeRoot = YES;
		
		fName_ = "/";
		fileName_ = @"/";
		_fPath = "/";
		fType_ = NSFileTypeDirectory;
		
		contents_ = [[NSMutableDictionary dictionaryWithCapacity: 1] retain];
	}
	
	return self;
}

- (id)initWithXARFile: (xar_file_t) xarFile
{
	if((self = [super init]))
	{
		const char *str;
		int res;
		
		[self basicInit];
		
		xarFile_ = xarFile;
		
		_fPath = xar_get_path(xarFile);
		
		res = xar_prop_get(xarFile, "name", &fName_);
		fileName_ = [[NSString stringWithUTF8String: fName_] retain];
		
		res = xar_prop_get(xarFile, "type", &str); //"file, directory, fifo, character special, block special, socket"
		fType_ = makeXARTypeFromStr(str);
		
		res = xar_prop_get(xarFile, "mode", &fMode_);
		
		res = xar_prop_get(xarFile, "data/size", &str);
		if(0 == res)
			fileSize_ = strtoll(str, NULL, 10);
		else
			fileSize_ = 0;
		
		res = xar_prop_get(xarFile, "mtime", &fileModificationDate_);
		
		//res = xar_prop_get(xarFile, "atime", &fUID);
		//res = xar_prop_get(xarFile, "ctime", &fUID);
		//res = xar_prop_get(xarFile, "uid", &fUID);
		//res = xar_prop_get(xarFile, "gid", &fGID);
		//res = xar_prop_get(xarFile, "user", &fUser);
		//res = xar_prop_get(xarFile, "group", &fGroup);
		
		if(fType_ == NSFileTypeDirectory)
		{
			contents_ = [[NSMutableDictionary dictionaryWithCapacity: 1] retain];
		}
	}
	
	return self;
}

- (void)dealloc
{
	if(!_isFakeRoot)
		free(_fPath);
	
	if(contents_)
		[contents_ release];
	
	[super dealloc];
}

+ (XARDirectoryItem*)createFromXARFile:(xar_file_t)xarFile
{
	return [[[XARDirectoryItem alloc] initWithXARFile:xarFile] autorelease];
}

+ (XARDirectoryItem*)createFakeRoot;
{
	return [[[XARDirectoryItem alloc] initAsFakeRoot] autorelease];
}

@end
