MDPictureSourceSheet
====================

What is it?
-----------
MDPictureSourceSheet is an iOS class for quickly getting an image from the user, from whatever image sources are available. If you're using a device where both a camera and photo library are available (such as an iPhone, iPad, or newer iPod Touch), the user can pick from either. If only one is available, that source is presented immediately.

Additionally, you can optionally present a button to remove an existing image.

How to Use
----------
1. Add `MDPictureSourceSheet.h` and `MDPictureSourceSheet.m` to your Xcode project.
2. (Only required if your project does not use ARC) Add the `-f-objc-arc` compiler flag to `MDPictureSourceSheet.m` in your target's Compile Sources step.
3. Import `MDPictureSource.h` in the view controller you wish to present the source sheet from.
4. Implement the `MDPictureSourceDelegate`, `UIImagePickerControllerDelegate` and `UINavigationControllerDelegate` methods in that view controller.
5. Initialise an `MDPictureSourceSheet`, set the delegates and configure it.
6. When you're ready to present the sheet, call `presentPictureSourceSheet`.

For further guidance, there's example iPhone and iPad implementations in the `Example` folder. Be aware that no camera is available in the iPad simulator, so only the picker will be displayed, rather than the source selector.

License
-------

MDPictureSourceSheet is made available under the MIT License. The full license text is available in LICENSE.