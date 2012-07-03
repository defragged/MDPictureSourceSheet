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

#import "MDPictureSourceSheet.h"

@interface MDPictureSourceSheet ()

@property (strong, nonatomic) UIActionSheet *sheet;

@property (assign, nonatomic) BOOL cameraAvailable;
@property (assign, nonatomic) BOOL libraryAvailable;
@property (assign, nonatomic) BOOL videoCaptureAvailable;

@end

@implementation MDPictureSourceSheet

@synthesize sheet = _sheet;
@synthesize cameraAvailable = _cameraAvailable;
@synthesize libraryAvailable = _libraryAvailable;
@synthesize videoCaptureAvailable = _videoCaptureAvailable;

@synthesize pictureSourceDelegate = _pictureSourceDelegate;
@synthesize pickerDelegate = _pickerDelegate;

@synthesize title = _title;
@synthesize existingImage = _existingImage;

@dynamic visible;

#pragma mark - Presenting

-(void)presentPictureSourceSheet{
	// Determine what's available
	self.cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	self.libraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
	self.videoCaptureAvailable = self.cameraAvailable && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]containsObject:(NSString*)kUTTypeMovie];
	
	NSString *destructiveButtonTitle = nil;
	if(self.existingImage){
		// If there's already an image set, give the option to delete it.
		destructiveButtonTitle = NSLocalizedStringWithDefaultValue(@"RemoveImageButtonLabel",
																   @"PictureSourceSheet",
																   [NSBundle mainBundle],
																   @"Remove Image",
																   @"Title for button to delete an image");
	}
	
	NSString *cameraButtonText = NSLocalizedStringWithDefaultValue(@"FromCameraButtonLabel",
																   @"PictureSourceSheet",
																   [NSBundle mainBundle],
																   @"Take a Picture",
																   @"Title for button user can use to take a picture");
	
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
	
	// Only one possible option available: Don't bother with the ActionSheet
	if(!self.existingImage){
		if(self.cameraAvailable && !self.libraryAvailable){
			// Only the camera is available: Show the camera controls
			[self choosePictureFromCamera];
			return;
			
		}else if(self.libraryAvailable && !self.cameraAvailable){
			// Only the library is available (iPod Touch, Simulator etc): Show the library
			[self choosePictureFromLibrary];
			return;
		}
	}
	
	if(self.cameraAvailable && self.libraryAvailable){
		// Both camera and library are available: Let the user select one.
		self.sheet = [[UIActionSheet alloc]initWithTitle:self.title
												delegate:self
									   cancelButtonTitle:cancelButtonText
								  destructiveButtonTitle:destructiveButtonTitle
									   otherButtonTitles:cameraButtonText, libraryButtonText, nil];
		
	}else if(self.cameraAvailable){
		// Only camera (and deletion) is available, show that ActionSheet
		self.sheet = [[UIActionSheet alloc]initWithTitle:self.title
												delegate:self
									   cancelButtonTitle:cancelButtonText
								  destructiveButtonTitle:destructiveButtonTitle
									   otherButtonTitles:cameraButtonText, nil];
	
	}else if(self.libraryAvailable){
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

#pragma mark - Choosing Images

-(void)choosePictureFromLibrary{
	
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self.pickerDelegate;
	[self.pictureSourceDelegate sheet:self shouldPresentPicker:imagePickerController];
}

-(void)choosePictureFromCamera{
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
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
		
	}else if(self.cameraAvailable && self.libraryAvailable){
		
		// Both sources available, check which one was selected.
		if(buttonIndex == actionSheet.firstOtherButtonIndex){
			[self choosePictureFromCamera];
			
		}else if(buttonIndex == actionSheet.firstOtherButtonIndex + 1){
			[self choosePictureFromLibrary];
		}
		
	}else if(self.cameraAvailable){
		// Cancel/Remove not selected, only one other choice:
		[self choosePictureFromCamera];
		
	}else{
		[self choosePictureFromLibrary];
	}
}

@end
