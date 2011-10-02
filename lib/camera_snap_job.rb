require 'json'

##
# Takes a picture
# @param photoset Photoset instance that this picture will belong to.
# @param has_printer Whether or not a print command should be sent when finished compositing.
class CameraSnapJob < Struct.new(:photoset, :has_printer)
  IMG_WIDTH = 600

  def before(job)
    Rails.logger.debug "AHAO beginning task for photo #{photoset.get_paths.size()} at #{Time.now}, or #{Time.now.to_i}."
  end
  
  def perform
    image_folder = photoset.get_folder_path
    image_name = "boink_#{photoset.get_paths.size()}.jpg"

    `mkdir -p #{image_folder}`
    CAMERA.capture.save({:to_folder => image_folder, :new_name => image_name}).delete
    #@@cam.dispose
    sh "sips --resampleWidth #{IMG_WIDTH} #{image_folder}/#{image_name}"
  end
  
  def after(job)
    Rails.logger.debug "AHAO CameraSnapJob finished at #{Time.now.to_i}"
  end
  
  def success(job)
    url_image_path = "#{photoset.get_url_folder_path}/boink_#{photoset.get_paths.size()}.jpg"
    Rails.logger.debug "AHAO CameraSnapJob finished at #{Time.now.to_i}"
    # Store the filename in the photoset object.
    photoset.set_image_path(photoset.get_paths.size(), url_image_path)
    Rails.logger.debug "AHAO Saved new image into PhotoSet path: #{photoset.get_paths}"
    if photoset.get_paths.size() == 4
      photoset.composite_photos
      photoset.print if has_printer
    end
  end
  
  def failure(job)
    Rails.logger.debug "What happened?!"
  end
  
end
