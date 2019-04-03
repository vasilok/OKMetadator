# OKMetadator
Inject spherical metadata to image and video.

Check out the sample project to learn how to use OKMetadator.

To work with panorama photo ,you should use OKImageSphericalMetadator.
The simplest way is:
- make360ImageAtURL:outputURL:completion:
- make180ImageAtURL:outputURL:completion:
- makePanoWithHorizontalFOV:verticalFOV:atURL:outputURL:completion:

To work with panorama video, you  should use OKVideoSphericalMetadator.
The simplest way is:
- make360VideoAtURL:andWriteToURL:completion:
- make180VideoAtURL:andWriteToURL:completion:
