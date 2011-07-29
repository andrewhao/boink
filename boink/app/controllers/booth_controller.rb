require 'json'

class BoothController < ApplicationController
  PHOTO_COUNT = 4 # number of photos that will be taken
  PHOTO_PREDELAY = 0 # delay before first photo is taken
  PHOTO_DELAY = 10 # delay between photos being taken
  
  def show
  end
  
  def time_now
    @response = {}
    @response[:timestamps] = []
    start_time = (PHOTO_PREDELAY + Time.now.to_i) * 1000
    PHOTO_COUNT.times do |i|
      @response[:timestamps] << start_time + (PHOTO_DELAY * i * 1000)
    end
    render :json => @response
  end
  
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

  def photoset
    request = JSON.parse params
    photo_set = PhotoSet.find request[:set_id].to_i
    photo_set.paths
  end
end
