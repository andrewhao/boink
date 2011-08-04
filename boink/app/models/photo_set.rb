require 'json'

class PhotoSet < ActiveRecord::Base
  # Query for a JPEG image reference in the model.
  def get_image_path(index)
    return (self.paths) ? JSON.parse(self.paths)[index.to_s] : nil
  end
  
  # Return a deJSONified Ruby hash.
  def get_paths
    return (self.paths) ? JSON.parse(self.paths) : {}
  end
  
  def set_image_path(index, path)
    path_dict = (self.paths) ? JSON.parse(self.paths) : {}
    path_dict[index] = path;
    self.paths = JSON.generate(path_dict)
    self.save
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
