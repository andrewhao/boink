require 'json'
require 'fileutils'

class BoothController < ApplicationController
  
  PHOTO_COUNT = 4 # number of photos that will be taken
  CAMERA_INIT_LAG = 0 # delay between calling gphoto2 and the actual camera shutter snap.
                      # this value will have to be jiggered, YMMV.
  PHOTO_COUNTDOWN = 3.5 # 3, 2, 1...
  BROWSER_TIME_FUDGE = 0 # Extra fudge factor because we can't always trust the Webkit render engine to fire correctly.
  
  def show
  end
  
  def slideshow
    @psets = PhotoSet.find :all
    @psets.each_with_index do |pset, i|
      # do stuff.
    end
  end
  
  # Move all generated photos to a temp directory.
  # Do this when you're done with a session.
  def collect
    p = PhotoSet.find :all
    dst_dir = "/Users/andrew/workspace/tmp"
    p.each do |pset|
      begin
        FileUtils.cp(pset.generated_photo_path, "#{dst_dir}/gen_#{pset.id}.jpg")
      rescue
        Rails.logger.error "No file #{pset.generated_photo_path}"
      end
    end
  end

  # Indicates the client is ready to begin taking photos.
  # Supply a "new_set" = true to create a new photo set on the backend.
  # Supply "set_id" param to add a photo to an existing set.
  def snap
    @response = {}
    start_time = Time.now.to_i + PHOTO_COUNTDOWN - CAMERA_INIT_LAG + BROWSER_TIME_FUDGE
    @pset = params[:new_set] ? PhotoSet.create : PhotoSet.find(params[:set_id])
    Rails.logger.debug ("AHAO with params[newset] = #{params[:new_set]} and set_id of #{params[:set_id]} and pset of #{@pset}")
    @response[:set_id] = @pset.id

    Delayed::Job.enqueue(CameraSnapJob.new(@pset, false)) #{:run_at => Time.at(start_time)});

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
