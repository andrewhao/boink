# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Boink::Application.initialize!

require 'gphoto4ruby'
`killall PTPCamera`
begin
  CAMERA = GPhoto2::Camera.new
rescue GPhoto2::Exception #HACK: need to start delay job first so it can grab camera
end