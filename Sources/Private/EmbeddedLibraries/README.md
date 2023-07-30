## ZipFoundation

This directory includes the source code of libraries that are embedded within lottie-ios.

This includes:
 - ZipFoundation (https://github.com/weichsel/ZIPFoundation)
 - EpoxyCore (https://github.com/airbnb/epoxy-ios)

Lottie is distributed via multiple package managers (SPM, Cocoapods, Carthage, and NPM),
each with different packaging and compilation requirements. 

Due to limitations of these package managers, we can't depend on / import 
a separates modules / libraries. Instead, we include the source
directly within the Lottie library and compile everything as a single unit.

### Update instructions

From time to time we may need to update to a more recent version of one of these libraries.
When doing this, follow these steps:

 1. Download the latest release of the library and replace the source code in 
    the corresponding directory with the updated code.
    
 2. Update the URL in the directory's README.md to indicate what release is being used.
 
 3. Change all of the `public` symbols defined in the module to instead be `internal`
    to prevent Lottie from exposing any APIs from other libraries.
