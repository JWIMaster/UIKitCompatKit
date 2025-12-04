# UIKitCompatKit

If you are planning on setting up a hybrid build system for modern devices, then you will want to opt into the MODERN_BUILD flag. To do so, go to "OTHER_SWIFT_FLAGS" inside of Xcode's build settings, and paste "-DMODERN_BUILD". This will prevent the confliction errors that arise when building across multiple SDK versions. You will have to setup two build configs, one that defines the flag, and one that doesn't.
