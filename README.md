Boink is an open-source photobooth made slick, simple and free.
===

Description
---
Boink is a Rails-based camera server that controls a camera over USB (most camera models [supported by gphoto2](http://www.gphoto.org/proj/libgphoto2/support.php)). It coordinates a frontend interface that can be controlled by your photobooth participants.

See an example here (coming soon).

In case anybody's wondering, we're running a [Rails 3](http://rubyonrails.org) instance, with a backend powered by [gphoto4ruby](http://rubyforge.org/projects/gphoto4ruby/), and a frontend powered by [jQuery](http://jquery.com) and [RaphaelJS](http://raphaeljs.com).

Setup
---
Currently, this software is developed on OS X, but YMMV on other OSes.

At the prompt:

`bundle install`

Custom branding
---
If you'd like, you should replace `overlay.png` with your own event branding. It's a PNG image with 3:2 aspect ratio. You should use 24-bit PNG images with alpha transparency. The image will be overlaid on top of the 2x2 photo matrix.

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

License
---
Boink is open-sourced under the [MIT](http://www.opensource.org/licenses/mit-license.php) and [GPL](http://www.gnu.org/copyleft/gpl.html) licenses.

Links
---
  - [libgphoto2](http://www.gphoto.org/proj/libgphoto2/): camera USB (PTP) interface lib.
