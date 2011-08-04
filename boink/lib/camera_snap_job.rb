class CameraSnapJob < Struct.new(:photoset, :idx)
  def perform
    Rails.logger.debug "AHAO running task at #{Time.now}"
    sh "gphoto2 --capture-image-and-download --filename #{photoset.get_folder_path}/boink_#{idx}.jpg --force-overwrite"
  end
end

# class LongJobs
#   def camera_snap(photoset, photo_idx)
#     sh "gphoto2 --capture-image-and-download --filename #{photoset.get_folder_path}/boink_#{photo_idx}.jpg --force-overwrite"
#   end
#   handle_asynchronously :camera_snap, :run_at => Proc.new { 5.seconds.from_now }
# end