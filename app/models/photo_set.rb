require 'json'
require 'rmagick'
include Magick

class PhotoSet < ActiveRecord::Base
  IMAGE_HEIGHT = 800
  IMAGE_WIDTH = 1200
  IMAGE_PADDING = 80
  
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
  
  # Absolute path to overlay (logo) instance.
  def self.get_overlay_path
    return "#{Rails.public_path}/images/overlay.png"
  end
    
  # Location of generated, composited photo.
  def generated_photo_path
    return "#{self.get_folder_path}/gen.jpg"
  end
  
  # Takes the photos in this PhotoSet and composites them with RMagick
  # Creates an image called "gen.jpg" in the set folder.
  def composite_photos
    w = IMAGE_WIDTH * 2 + IMAGE_PADDING * 3
    h = IMAGE_HEIGHT * 2 + IMAGE_PADDING * 3
    comp = Image.new(w, h) { self.background_color = "white" }

    tl_photo = ImageList.new("#{get_folder_path}/boink_0.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    tr_photo = ImageList.new("#{get_folder_path}/boink_1.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    bl_photo = ImageList.new("#{get_folder_path}/boink_2.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    br_photo = ImageList.new("#{get_folder_path}/boink_3.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)

    overlay = ImageList.new(PhotoSet.get_overlay_path).resize_to_fill(w, h)

    comp = comp.composite(tl_photo, IMAGE_PADDING, IMAGE_PADDING, OverCompositeOp)
    comp = comp.composite(tr_photo, IMAGE_WIDTH + 2*IMAGE_PADDING, IMAGE_PADDING, OverCompositeOp)
    comp = comp.composite(bl_photo, IMAGE_PADDING, IMAGE_HEIGHT + 2*IMAGE_PADDING, OverCompositeOp)
    comp = comp.composite(br_photo, IMAGE_WIDTH + 2*IMAGE_PADDING, IMAGE_HEIGHT + 2*IMAGE_PADDING, OverCompositeOp)
    comp = comp.composite(overlay, ((comp.columns - overlay.columns)/2).round, ((comp.rows - overlay.rows)/2).round, OverCompositeOp)

    comp.write(self.get_folder_path + "/gen.jpg")
  end

  def print
    photo_path = get_folder_path + "/gen.jpg"
    sh "lpr #{photo_path}"
    printed = true
    save
  end
end
