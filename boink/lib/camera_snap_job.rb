require 'json'
require 'gphoto4ruby'

class CameraSnapJob < Struct.new(:photoset, :idx)
  IMG_WIDTH = 600

  def before(job)
    Rails.logger.debug "AHAO beginning task for photo #{idx} at #{Time.now}, or #{Time.now.to_i}."
  end
  
  def perform
    image_folder = photoset.get_folder_path
    image_name = "boink_#{idx}.jpg"
    
    #sh "gphoto2 --capture-image-and-download --filename #{image_path} --force-overwrite"
    `mkdir -p #{image_folder}`
    CAMERA.capture.save({:to_folder => image_folder, :new_name => image_name}).delete
    #@@cam.dispose
    sh "sips --resampleWidth #{IMG_WIDTH} #{image_folder}/#{image_name}"
  end
  
  def after(job)
    Rails.logger.debug "AHAO CameraSnapJob finished at #{Time.now.to_i}"
  end
  
  def success(job)
    url_image_path = "#{photoset.get_url_folder_path}/boink_#{idx}.jpg"
    Rails.logger.debug "AHAO CameraSnapJob finished at #{Time.now.to_i}"
    # Store the filename in the photoset object.
    photoset.set_image_path(idx, url_image_path)
    Rails.logger.debug "AHAO Saved new image into PhotoSet path: #{photoset.get_paths}"
    if idx == 3
      photoset.composite_photos
      photoset.print
    end
  end
  
  def failure(job)
    Rails.logger.debug "What happened?!"
  end
  
end

# class LongJobs
#   def camera_snap(photoset, photo_idx)
#     sh "gphoto2 --capture-image-and-download --filename #{photoset.get_folder_path}/boink_#{photo_idx}.jpg --force-overwrite"
#   end
#   handle_asynchronously :camera_snap, :run_at => Proc.new { 5.seconds.from_now }
# end