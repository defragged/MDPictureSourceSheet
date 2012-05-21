//
//  MDViewController.m
//  MDPictureSourceSheetExample
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

#import "MDViewController.h"

@interface MDViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *placeholderImageView;
@property (strong, nonatomic) MDPictureSourceSheet *sourceSheet;
@property (strong, nonatomic) UIPopoverController *pickerPopover;
@property (strong, nonatomic) IBOutlet UIButton *sheetButton;

@end

@implementation MDViewController

@synthesize imageView = _imageView;
@synthesize placeholderImageView = _placeholderImageView;
@synthesize sourceSheet = _sourceSheet;
@synthesize pickerPopover = _pickerPopover;
@synthesize sheetButton = _sheetButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setSheetButton:nil];
    [self setPlaceholderImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - Interaction
- (IBAction)sheetButtonPressed:(id)sender {

    // Initialise the sheet
    MDPictureSourceSheet *sourceSheet = [[MDPictureSourceSheet alloc]init];
    
    // Configure the source sheet before displaying:
    
    // This delegate should be the view controller responsible for presenting the sheet
    sourceSheet.pictureSourceDelegate = self;
    
    // The delegate which will receive the image. Usually the same.
    sourceSheet.pickerDelegate = self;
    
    // Should be YES if you want to show the "Remove" button
    sourceSheet.existingImage = self.imageView.image != nil;
    
    // Optionally set a title for the sheet
    sourceSheet.title = @"Optional Source Sheet Title";
    
    // Need to hold a reference to the sheet before displaying
    self.sourceSheet = sourceSheet;
    
    // Call this once the sheet is configured
    [self.sourceSheet presentPictureSourceSheet];
}

#pragma mark - MDPictureSourceSheetDelegate methods

-(void)shouldPresentSheet:(UIActionSheet*)sheet{
    // You may want to present it from a tab bar, or bar button as appropriate
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [sheet showFromRect:self.sheetButton.frame
                     inView:self.view
                   animated:YES];
    }else{
        [sheet showInView:self.view];
    }
    
}

-(void)sheet:(MDPictureSourceSheet*)sheet shouldPresentPicker:(UIImagePickerController*)picker{
    
    // You may customise the picker here before presenting it
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        self.pickerPopover = [[UIPopoverController alloc]initWithContentViewController:picker];
        self.pickerPopover.delegate = self;
        [self.pickerPopover presentPopoverFromRect:self.sheetButton.frame
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
        
    }else{
        [self presentModalViewController:picker
                                animated:YES];        
    }
}

-(void)deleteImageSelectedBySheet:(MDPictureSourceSheet*)sheet{
    self.imageView.image = nil;
    self.imageView.image = [UIImage imageNamed:@"NoImagePlaceholder"];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    if(!image){
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    self.imageView.image = image;
    
    self.placeholderImageView.hidden = self.imageView.image != nil;
    
    [self.pickerPopover dismissPopoverAnimated:YES];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIPopoverControllerDelegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    if(popoverController == self.pickerPopover){
        self.pickerPopover = nil;
    }
}

@end
