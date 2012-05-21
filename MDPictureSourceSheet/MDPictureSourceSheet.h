//
//  MDPictureSourceSheet.h
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

#import <UIKit/UIKit.h>

@class MDPictureSourceSheet;
@protocol MDPictureSourceSheetDelegate;

/**
 A class to create, display, and return appropriate image pickers depending
 on the capabilities of the device.
 
 For example, on a device that does not have a camera, the device's media library
 is displayed. On a device that only has a camera, the camera image picker is displayed.
 On devices that have both, a UIActionSheet is displayed to allow the user to select
 which one they wish to use. 
 */
@interface MDPictureSourceSheet : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate>

#pragma mark - Configuring the Sheet
/// @name Configuring the sheet

/// Responsible for showing the UIActionSheet and presenting UIImagePickerControllers.
@property (unsafe_unretained, nonatomic) NSObject<MDPictureSourceSheetDelegate> *pictureSourceDelegate;

/// Responsible for handling the images returned by the UIImagePickerController
@property (unsafe_unretained, nonatomic) NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate> *pickerDelegate;

/// The UIActionSheet's title.
@property (strong, nonatomic) NSString *title;

/**
 Whether or not an image already exists to be manipulated.
 
 This affects whether or not the delete button is displayed.
 */
@property (assign, nonatomic) BOOL existingImage;

#pragma mark - State
/// @name Getting State

/// Whether or not the presented UIActionSheet is visible.
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

#pragma mark - Presenting the Sheet
/// @name Presenting the Sheet

/**
 Call this method when this sheet is configured and the delegate is ready to present
 it.
 
 After calling this, the delegate should immediately receive either shouldPresentSheet:
 or sheet:shouldPresentPicker:
 */
-(void)presentPictureSourceSheet;

@end

#pragma mark - MDPictureSourceSheetDelegate

/**
 A delegate responsible for showing the UIActionSheet and presenting UIImagePickerControllers.
 */
@protocol MDPictureSourceSheetDelegate <NSObject>

/**
 Called when a UIActionSheet should be displayed.
 
 Usually to pick a source, or delete and image.
 
 @param sheet The UIActionSheet to display.
 */
-(void)shouldPresentSheet:(UIActionSheet*)sheet;

/**
 Called when a UIImagePickerController should be presented.
 
 @param sheet The sheet which requested the picker to be displayed.
 @param picker The picker that should be presented modally.
 */
-(void)sheet:(MDPictureSourceSheet*)sheet shouldPresentPicker:(UIImagePickerController*)picker;

/**
 Called when the delete button is tapped on an MDPictureSourceSheet.
 
 @param sheet The sheet whose delete button was tapped.
 */
-(void)deleteImageSelectedBySheet:(MDPictureSourceSheet*)sheet;

@optional

/**
 Called when a displayed UIActionSheet is dismissed
 
 @param sheet the MDPictureSourceSheet that was dismissed.
 */
-(void)dismissedSheet:(MDPictureSourceSheet*)sheet;

@end
