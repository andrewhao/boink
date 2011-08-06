require 'json'
require 'rmagick'
include Magick

class PhotoSet < ActiveRecord::Base
  IMAGE_HEIGHT = 400
  IMAGE_WIDTH = 600
  IMAGE_PADDING = 20
  
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
  
  def self.get_overlay_path
    return "#{Rails.public_path}/images/overlay.png"
  end
  
  def composite_photos
    comp = Image.new(IMAGE_WIDTH * 2 + IMAGE_PADDING, IMAGE_HEIGHT * 2 + IMAGE_PADDING) { self.background_color = "white" }
    
    tl_photo = ImageList.new(get_folder_path + "boink_1.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    tr_photo = ImageList.new(get_folder_path + "boink_2.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    bl_photo = ImageList.new(get_folder_path + "boink_3.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    br_photo = ImageList.new(get_folder_path + "boink_4.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    
    overlay = ImageList.new(PhotoSet.get_overlay_path)
    
    comp = comp.composite(tl_photo, 0, 0, OverCompositeOp)
    comp = comp.composite(tr_photo, IMAGE_WIDTH + IMAGE_PADDING, 0, OverCompositeOp)
    comp = comp.composite(bl_photo, 0, IMAGE_HEIGHT + IMAGE_PADDING, OverCompositeOp)
    comp = comp.composite(br_photo, IMAGE_WIDTH + IMAGE_PADDING, IMAGE_HEIGHT + IMAGE_PADDING, OverCompositeOp)
    comp = comp.composite(overlay, ((comp.columns - overlay.columns)/2).round, ((comp.rows - overlay.rows)/2).round, OverCompositeOp)
    comp.write(tmp_path + "photos/gen.jpg")    
  end
  
  # Takes the photos in this PhotoSet and composites them with RMagick
  def self.composite_test
    tmp_path = "#{Rails.public_path}/images/"
    comp = Image.new(IMAGE_WIDTH * 2 + IMAGE_PADDING, IMAGE_HEIGHT * 2 + IMAGE_PADDING) { self.background_color = "white" }
    
    tl_photo = ImageList.new(tmp_path + "photos/1.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    tr_photo = ImageList.new(tmp_path + "photos/2.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    bl_photo = ImageList.new(tmp_path + "photos/3.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    br_photo = ImageList.new(tmp_path + "photos/4.jpg").resize_to_fill(IMAGE_WIDTH, IMAGE_HEIGHT)
    
    overlay = ImageList.new(tmp_path + "overlay.png")
    
    comp = comp.composite(tl_photo, 0, 0, OverCompositeOp)
    comp = comp.composite(tr_photo, IMAGE_WIDTH + IMAGE_PADDING, 0, OverCompositeOp)
    comp = comp.composite(bl_photo, 0, IMAGE_HEIGHT + IMAGE_PADDING, OverCompositeOp)
    comp = comp.composite(br_photo, IMAGE_WIDTH + IMAGE_PADDING, IMAGE_HEIGHT + IMAGE_PADDING, OverCompositeOp)
    comp = comp.composite(overlay, ((comp.columns - overlay.columns)/2).round, ((comp.rows - overlay.rows)/2).round, OverCompositeOp)
    comp.write(tmp_path + "photos/gen.jpg")
  end
end
