require 'json'

class PhotoSet < ActiveRecord::Base
  def get_image_path(index)
    path_obj = JSON.parse(self.paths)
    return path_obj[index.to_s]
  end

  # Return the path to the folder containing images for this set.
  def get_folder_path
    return "#{Rails.public_path}/images/sets/#{self.id}"
  end
end
