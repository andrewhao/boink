require 'json'

class PhotoSet < ActiveRecord::Base
  def get_image_path(index)
    path_obj = JSON.parse(self.paths)
    return path_obj[index.to_s]
  end
end
