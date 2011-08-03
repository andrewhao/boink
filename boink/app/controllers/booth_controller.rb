require 'json'

class BoothController < ApplicationController
  PHOTO_COUNT = 4 # number of photos that will be taken
  PHOTO_PREDELAY = 5 # delay before first photo is taken
  PHOTO_DELAY = 10 # delay between photos being taken
  
  def show
  end

  # Indicates the client is ready to begin taking photos.
  # Returns a set of timestamps the camera will click at.
  def start_snap
    @response = {}
    @response[:set_id] = 0
    @response[:timestamps] = []
    start_time = (Time.now.to_i + PHOTO_PREDELAY) * 1000
    PHOTO_COUNT.times do |i|
      @response[:timestamps] << start_time + (PHOTO_DELAY * 1000 * i)
    end
    # call call_rake to call script to take photos from here, passing in starting timestamp
    # and delta so that the camera can start doing work
    render :json => @response
  end

  # Return the images available in the requested photoset.
  #--
  # FIXME Currently returning hardcoded mock data.
  def photoset
#    photo_set = PhotoSet.find params[:set_id].to_i
#    photo_set.paths

    # MOCK/andrewhao
    @response = {}
    @response[:images] = [
      {:index => 0, :url => '/images/photos/1.jpg'},
#      {:index => 1, :url => '/images/photos/2.jpg'},
#      {:index => 2, :url => '/images/photos/3.jpg'},
#      {:index => 3, :url => '/images/photos/4.jpg'},
    ]
    render :json => @response

  end
end
