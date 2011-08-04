class CameraSnapJob < Struct.new(:photoset, :idx)
  IMG_WIDTH = 600

  def before(job)
    Rails.logger.debug "AHAO beginning task at #{Time.now}, or #{Time.now.to_i}"  
  end
  
  def perform
    filename = "#{photoset.get_folder_path}/boink_#{idx}.jpg"
    sh "gphoto2 --capture-image-and-download --filename #{filename} --force-overwrite"
    sh "sips --resampleWidth #{IMG_WIDTH} #{filename}"  
  end
  
  def after(job)
    Rails.logger.debug "AHAO CameraSnapJob finished at #{Time.now.to_i}"
  end
  
  def success(job)
    Rails.logger.debug "AHAO Dude. CameraSnapJob success!"
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