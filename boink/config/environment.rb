# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Boink::Application.initialize!

require 'gphoto4ruby'
`killall PTPCamera`

# Grab camera instance.
begin
  CAMERA = GPhoto2::Camera.new
  # Shoot a photo because the first one always seems to take a long time.
  CAMERA.capture.save.delete
# HACK: DelayedJob instances will try to initialize a CAMERA instance as well.
rescue GPhoto2::Exception 
  # Ignore all subsequent grabs.
end