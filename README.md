Boink is an open-source photobooth made slick, simple and free.
===

Description
---
Boink is a Rails-based camera server that controls a camera over USB (most camera models [supported by gphoto2](http://www.gphoto.org/proj/libgphoto2/support.php)). It coordinates a frontend interface that can be controlled by your photobooth participants.

See an example here (coming soon).

Setup
---
Currently, this software is developed on OS X, but YMMV on other OSes.

At the prompt:

`bundle install`

Running the booth
---
At application root, run `rake jobs:work`. This starts up the job queue processor.
In another terminal, start the rails server: `rails s`

Open Boink from your Webkit (Chrome, Safari) browser: `http://localhost:3000/booth/show`. I prefer to use Chrome because I can full-screen the window.

Optional: share your Mac's Internet connection and run the frontend from your iPad. It's touch-tastic.

The images will print from the default printer. You can run the booth and printer asynchronously.

Should the interface ever get stuck, you may have to clear the jobs queue of dead camera snap jobs. You should clear the queue with a `rake jobs:clear` command.

Notes
---
On OS X, it's important to kill the PTP daemon each time the camera is plugged in, or the computer is restarted.

`killall PTPCamera`

Note that this is done automatically by Boink at startup.


Links
---
  - [libgphoto2](http://www.gphoto.org/proj/libgphoto2/): camera USB (PTP) interface lib.
