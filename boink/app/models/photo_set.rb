require 'json'

class PhotoSet < ActiveRecord::Base
  # Query for a JPEG image reference in the model.
  def get_image_path(index)
    path_obj = JSON.parse(self.paths)
    return path_obj[index.to_s]
  end

  # Return the absolute filesystem path to the folder containing images for this set.
  # No trailing slash.
  def get_folder_path
    return "#{Rails.public_path}/images/sets/#{self.id}"
  end
  
  # Returns a URL-relative path to the set folder.
  # Note no trailing slash.
  def get_url_folder_path
    return "/images/sets/#{self.id}"
  end
end
