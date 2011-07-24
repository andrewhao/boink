Boink is photobooth software made simple.
===
Use it at wedding, parties, office gatherings.

Dependencies
---
  - Mac OSX 10.6
  - Webkit browser (Chrome)
  - gphoto2

    brew install gphoto2

  - A [gphoto2-compatible camera](http://www.gphoto.org/proj/libgphoto2/support.php).

Setup
---
OS X: Read http://blog.dcclark.net/2009/05/how-to-gphoto-primer.html

It's important to kill the PTP daemon each time the camera is plugged in, or the computer is restarted.

    killall PTPCamera


Links
---
  - [libgphoto2](http://www.gphoto.org/proj/libgphoto2/): camera USB (PTP) interface lib.
