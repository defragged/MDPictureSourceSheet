MDPictureSourceSheet
====================
by [Mark Danks](https://github.com/defragged), [@defragged](http://twitter.com/defragged)

What is it?
-----------
MDPictureSourceSheet is an iOS class for quickly getting an image from the user, from whatever image sources are available. If you're using a device where both a camera and photo library are available (such as an iPhone, iPad, or newer iPod Touch), the user can pick from either. If only one is available, that source is presented immediately.

Additionally, you can optionally present a button to remove an existing image.

Where To Find It
----------------
The latest version of MDPictureSourceSheet can be found on [GitHub](https://github.com/defragged/MDPictureSourceSheet).

How to Use
----------
1. Add `MDPictureSourceSheet.h` and `MDPictureSourceSheet.m` to your Xcode project.
2. (Only required if your project does not use ARC) Add the `-f-objc-arc` compiler flag to `MDPictureSourceSheet.m` in your target's Compile Sources step.
3. Import `MDPictureSource.h` in the view controller you wish to present the source sheet from.
4. Implement the `MDPictureSourceDelegate`, `UIImagePickerControllerDelegate` and `UINavigationControllerDelegate` methods in that view controller.
5. Initialise an `MDPictureSourceSheet`, set the delegates and configure it.
6. When you're ready to present the sheet, call `presentPictureSourceSheet`.

For further guidance, there's example iPhone and iPad implementations in the `Example` folder. Be aware that no camera is available in the iPad simulator, so only the picker will be displayed, rather than the source selector.

How to Help
-----------
This is the first component I've released, so I'm open to suggestions and criticism. Feel free to submit an [issue on GitHub](https://github.com/defragged/MDPictureSourceSheet/issues) if you find a bug or have an idea for improvement. You can also submit a [pull request](https://github.com/defragged/MDPictureSourceSheet/pulls) if you have code to contribute.

If you've used MDPictureSourceSheet in your own projects, I'd love to hear about it. My email address is on my [GitHub profile page](https://github.com/defragged).

License
-------

MDPictureSourceSheet is made available under the MIT License. The full license text is available in LICENSE.