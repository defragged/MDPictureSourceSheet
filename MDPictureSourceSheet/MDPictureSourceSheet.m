//
//  MDPictureSourceSheet.m
//
//  Copyright (C) 2012 Mark Danks
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Requires MobileCoresServices.framework
#import <MobileCoreServices/UTCoreTypes.h>

#import "MDPictureSourceSheet.h"

@interface MDPictureSourceSheet ()

@property (strong, nonatomic) UIActionSheet *sheet;

@property (assign, nonatomic) BOOL cameraAvailable;
@property (assign, nonatomic) BOOL libraryAvailable;
@property (assign, nonatomic) BOOL videoCaptureAvailable;

@property (assign, nonatomic) BOOL capturingFromCamera;

@end

@implementation MDPictureSourceSheet

@synthesize sheet = _sheet;
@synthesize cameraAvailable = _cameraAvailable;
@synthesize libraryAvailable = _libraryAvailable;
@synthesize videoCaptureAvailable = _videoCaptureAvailable;

@synthesize capturingFromCamera = _capturingFromCamera;

@synthesize displayImages = _displayImages;
@synthesize displayMovies = _displayMovies;

@synthesize pictureSourceDelegate = _pictureSourceDelegate;
@synthesize pickerDelegate = _pickerDelegate;

@synthesize title = _title;
@synthesize existingImage = _existingImage;

@dynamic visible;

#pragma mark - Initialisers

-(id)init{
	self = [super init];
	
	if(self){
		// Set default values
		self.displayImages = YES;
	}
	
	return self;
}

#pragma mark - Presenting

-(void)presentPictureSourceSheet{
	// Determine what's available
	self.cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	self.libraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
	self.videoCaptureAvailable = self.cameraAvailable && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]containsObject:(NSString*)kUTTypeMovie];
	
	// Determine the strings to use
	
	NSString *destructiveButtonTitle = nil;
	if(self.existingImage){
		// If there's already an image set, give the option to delete it.
		destructiveButtonTitle = NSLocalizedStringWithDefaultValue(@"RemoveImageButtonLabel",
																   @"PictureSourceSheet",
																   [NSBundle mainBundle],
																   @"Remove Image",
																   @"Title for button to delete an image");
	}
	
	NSString *photoButtonText = NSLocalizedStringWithDefaultValue(@"PhotoOnlyButtonLabel",
																  @"PictureSourceSheet",
																  [NSBundle mainBundle],
																  @"Take a Photo",
																  @"Title for button user can use to take a picture");
	
	NSString *videoButtonText = NSLocalizedStringWithDefaultValue(@"PhotoAndVideoButtonLabel",
																  @"PictureSourceSheet",
																  [NSBundle mainBundle],
																  @"Record a Video",
																  @"Title for button user can use to record a video");
	
	NSString *photoAndVideoButtonText = NSLocalizedStringWithDefaultValue(@"PhotoAndVideoButtonLabel",
																   @"PictureSourceSheet",
																   [NSBundle mainBundle],
																   @"Take a Photo or Video",
																   @"Title for button user can use to either capture a video or take a picture");
	
	NSString *libraryButtonText = NSLocalizedStringWithDefaultValue(@"FromLibraryButtonLabel",
																	@"PictureSourceSheet",
																	[NSBundle mainBundle],
																	@"Select from Library",
																	@"Title for button user can press to select an image from their library instead");
	
	NSString *cancelButtonText = NSLocalizedStringWithDefaultValue(@"CancelButtonLabel",
																   @"PictureSourceSheet",
																   [NSBundle mainBundle],
																   @"Cancel",
																   @"Title for button to dismiss an action sheet without taking an action");
	
	// Determine the text to use on the "From Camera" button
	NSString *captureText = nil;
	if(self.displayImages && (self.displayMovies && self.videoCaptureAvailable)){
		// Capturing from both
		captureText = photoAndVideoButtonText;
	
	}else if(self.displayImages && !self.displayMovies){
		// Just displaying images
		captureText = photoButtonText;
	
	}else if(self.displayMovies && !self.displayImages){
		// Just displaying movies
		captureText = videoButtonText;
	}
	
	// Determine whether or not we will be trying to capture from the camera
	self.capturingFromCamera = NO;
	if(self.cameraAvailable){
		if(!self.displayImages && self.displayMovies && !self.videoCaptureAvailable){
			// Only capturing video, but video capture is not available
			self.capturingFromCamera = NO;
		
		}else{
			// Capturing still images, or video with video available: Allow camera.
			self.capturingFromCamera = YES;
		}
	}
	
	// Only one possible option available: Don't bother with the ActionSheet
	if(!self.existingImage){
		if(self.capturingFromCamera && !self.libraryAvailable){
			// Only the camera is available: Show the camera controls
			[self choosePictureFromCamera];
			return;
			
		}else if(self.libraryAvailable && !self.capturingFromCamera){
			// Only the library is available (iPod Touch, Simulator etc): Show the library
			[self choosePictureFromLibrary];
			return;
		}
	}
	
	if(self.capturingFromCamera && self.libraryAvailable){
		// Both camera and library are available: Let the user select one.
		self.sheet = [[UIActionSheet alloc]initWithTitle:self.title
												delegate:self
									   cancelButtonTitle:cancelButtonText
								  destructiveButtonTitle:destructiveButtonTitle
									   otherButtonTitles:captureText, libraryButtonText, nil];
		
	}else if(self.capturingFromCamera){
		// Only camera (and deletion) is available: Show that ActionSheet
		self.sheet = [[UIActionSheet alloc]initWithTitle:self.title
												delegate:self
									   cancelButtonTitle:cancelButtonText
								  destructiveButtonTitle:destructiveButtonTitle
									   otherButtonTitles:captureText, nil];
	
	}else if(self.libraryAvailable){
		// Only library (and deletion) is available: Show that ActionSheet
		self.sheet = [[UIActionSheet alloc]initWithTitle:self.title
												delegate:self
									   cancelButtonTitle:cancelButtonText
								  destructiveButtonTitle:destructiveButtonTitle
									   otherButtonTitles:libraryButtonText, nil];
	}
	
	[self.pictureSourceDelegate shouldPresentSheet:self.sheet];
}

#pragma mark - Getters/Setters

-(BOOL)isVisible{
	return self.sheet.isVisible;
}

/*
 Creates an array that can be passed to `UIImagePickerController`'s `mediaTypes`
 property based on the requested media types.
 */
-(NSArray*)mediaTypes{
	
	NSMutableArray *types = [[NSMutableArray alloc]initWithCapacity:2];
	
	if(self.displayImages){
		[types addObject:(NSString*)kUTTypeImage];
	}
	
	if(self.displayMovies){
		[types addObject:(NSString*)kUTTypeMovie];
	}
	
	return [NSArray arrayWithArray:types];
}

#pragma mark - Choosing Images

-(void)choosePictureFromLibrary{
	
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.mediaTypes = [self mediaTypes];
	imagePickerController.delegate = self.pickerDelegate;
	[self.pictureSourceDelegate sheet:self shouldPresentPicker:imagePickerController];
}

-(void)choosePictureFromCamera{
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePickerController.mediaTypes = [self mediaTypes];
	imagePickerController.delegate = self.pickerDelegate;
	[self.pictureSourceDelegate sheet:self shouldPresentPicker:imagePickerController];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == actionSheet.destructiveButtonIndex){
		// Remove button pressed: Remove the image
		[self.pictureSourceDelegate deleteImageSelectedBySheet:self];
	
	}else if(buttonIndex == actionSheet.cancelButtonIndex){
		if([self.pictureSourceDelegate respondsToSelector:@selector(dismissedSheet:)]){
			[self.pictureSourceDelegate dismissedSheet:self];
		}
		
	}else if(self.capturingFromCamera && self.libraryAvailable){
		
		// Both sources available, check which one was selected.
		if(buttonIndex == actionSheet.firstOtherButtonIndex){
			[self choosePictureFromCamera];
			
		}else if(buttonIndex == actionSheet.firstOtherButtonIndex + 1){
			[self choosePictureFromLibrary];
		}
		
	}else if(self.capturingFromCamera){
		// Cancel/Remove not selected, only one other choice:
		[self choosePictureFromCamera];
		
	}else{
		[self choosePictureFromLibrary];
	}
}

@end
