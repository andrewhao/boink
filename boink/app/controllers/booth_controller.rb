require 'json'

class BoothController < ApplicationController
  
  PHOTO_COUNT = 4 # number of photos that will be taken
  PHOTO_DELAY = 10 # delay between photos being taken
  CAMERA_INIT_LAG = 5 # delay between calling gphoto2 and the actual camera shutter snap. this value will have to be jiggered, YMMV.
  
  def show
  end

  # Indicates the client is ready to begin taking photos.
  # Returns a set of timestamps the camera will click at.
  def start_snap
    @response = {}
    @response[:timestamps] = []
    start_time = (Time.now.to_i + CAMERA_INIT_LAG) * 1000
    PHOTO_COUNT.times do |i|
      @response[:timestamps] << start_time + (PHOTO_DELAY * 1000 * i)
    end

    @pset = PhotoSet.create    
    @response[:set_id] = @pset.id

    # Enqueue each job for the future @ the scheduled interval.
    @response[:timestamps].each_with_index do |ts, idx|
      ts = (ts/1000) - CAMERA_INIT_LAG;
      Rails.logger.debug "AHAO I am planning to capture photo #{idx} at: #{ts}"
      Rails.logger.debug "AHAO ...which is #{ts - Time.now.to_i } seconds in the future."
      Delayed::Job.enqueue(CameraSnapJob.new(@pset, idx), {:run_at => Time.at(ts)});
    end

    render :json => @response
  end

  # Return the images available in the requested photoset.
  def photoset
    @photoset = PhotoSet.find params[:set_id].to_i

    @response = {}
    @response[:images] = {}
    
    # Return the current list of images at this photoset.
    @photoset.get_paths.each do |idx, path|
      @response[:images][idx] = {:url => path}
    end

    render :json => @response
  end
end
