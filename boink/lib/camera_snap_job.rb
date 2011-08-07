require 'json'

##
# Takes a picture
# @param photoset Photoset instance that this picture will belong to.
# @param idx Index of photo
class CameraSnapJob < Struct.new(:photoset, :idx)
  IMG_WIDTH = 600

  def before(job)
    Rails.logger.debug "AHAO beginning task for photo #{idx} at #{Time.now}, or #{Time.now.to_i}."
  end
  
  def perform
    image_folder = photoset.get_folder_path
    image_name = "boink_#{idx}.jpg"

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
