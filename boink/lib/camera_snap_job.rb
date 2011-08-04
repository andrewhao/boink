require 'json'
class CameraSnapJob < Struct.new(:photoset, :idx)
  IMG_WIDTH = 600

  def before(job)
    Rails.logger.debug "AHAO beginning task for photo #{idx} at #{Time.now}, or #{Time.now.to_i}."
  end
  
  def perform
    image_path = "#{photoset.get_folder_path}/boink_#{idx}.jpg"
    
    # Kill PTPCamera process because that eats up USB access on OS X.
    begin
      sh "killall PTPCamera"    
    rescue Exception => e
    end
    
    sh "gphoto2 --capture-image-and-download --filename #{image_path} --force-overwrite"
    sh "sips --resampleWidth #{IMG_WIDTH} #{image_path}"
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