# encoding: utf-8
require "image_tools"
class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support:
  include CarrierWave::RMagick
  # include CarrierWave::ImageScience
  include ImageTools

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # process :resize_to_fit => [1000, 1000]

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end


  def cropper(crop_width, crop_height)
    manipulate! do |img|
      width = img.columns
      height= img.rows
      if width == crop_width and height==crop_height then
        img
      else
        img.crop(width / 2,height / 2,crop_width,crop_height)
      end
    end
  end

  def set_dpi
    manipulate! do |img|
      img.resample(72.0, 72.0)
    end
  end

  def outliner
    manipulate! do |img|
      ImageTools::border_on_image(img,1,10,"white",1)
    end
  end

  def old_resize_to_fill(width, height, gravity = 'Center', color = "white")
    manipulate! do |img|

      cols, rows = img[:dimensions]
      img.combine_options do |cmd|
        if width != cols || height != rows
          scale = [width/cols.to_f, height/rows.to_f].max
          cols = (scale * (cols + 0.5)).round
          rows = (scale * (rows + 0.5)).round
          cmd.resize "#{cols}x#{rows}"
        end
        cmd.gravity gravity
        cmd.background "rgba(255,255,255,0.0)"
        cmd.extent "#{width}x#{height}" if cols != width || rows != height
      end
      ilist = Magick::ImageList.new
      rows < cols ? dim = rows : dim = cols
      ilist.new_image(dim, dim) { self.background_color = "#{color}" }
      ilist.from_blob(img.to_blob)
      img = ilist.flatten_images
      img = yield(img) if block_given?
      img
    end
  end

  def my_resize_to_fill(width, height, background="white", gravity=::Magick::CenterGravity)
    manipulate! do |img|
      #  img.resize_to_fit!(width, he ight)
      cols=img.columns
      rows=img.rows

      puts("cols: #{cols}, rows: #{rows} ")
      if width != cols || height != rows
        scale = [width/cols.to_f, height/rows.to_f].max
        cols = (scale * (cols + 0.5)).round
        rows = (scale * (rows + 0.5)).round
        img.resize!(cols, rows)
      end

      new_img = ::Magick::Image.new(cols, rows) { self.background_color = background == :transparent ? 'rgba(255,255,255,0)' : background.to_s }
      if background == :transparent
        filled = new_img.matte_floodfill(1, 1)
      else
        filled = new_img.color_floodfill(1, 1, ::Magick::Pixel.from_color(background))
      end
      destroy_image(new_img)
      filled.composite!(img, gravity, ::Magick::OverCompositeOp)
      destroy_image(img)
      filled = yield(filled) if block_given?
      filled
    end
  end


  #  def my_resize_to_fill(height, width)
  #    manipulate! do |img|
  #      ImageTools::my_resize_to_fill(img,height, width)
  #    end
  #  end

  version :preview, :if=>:not_pdf?  do
    process :resize_to_limit => [150, 150]
  end

  version :thumb, :if=>:not_pdf?    do
    process :resize_to_limit => [50, 50]
  end

  version :small, :if=>:not_pdf?     do
    process :resize_to_limit =>[100,100]
  end

  version :medium, :if=>:not_pdf?    do
    process :resize_to_limit =>[200,200]
  end

  version :large, :if=>:not_pdf?     do
    process :resize_to_limit =>[400,400]
  end


  #version :small_h do
  #  process :resize_to_fill =>[100,65]
  #end

  #version :tell_your_story do
  # process :resize_to_fill =>[160,300]
  #end

  # version :collection_list do
  #   process :resize_to_fill =>[90,140]
  # end

  # version :store_list do
  #    process :resize_to_limit => [171,237]
  # end

  # version :store_list_mm do
  #   process :resize_to_fill => [115,180]
  # end

  # version :medium do
  #   process :resize_to_limit => [150, 150]
  # end

  # version :large do
  #   process :resize_to_limit => [300, 300]
  # end

  # version :view do
  #   process :resize_to_fill => [ 320, 441]
  #  process :outliner
  #  end


  #  version :view_h do
  #    process :resize_to_fill => [691,472]
  #    #  process :outliner
  #  end

  #  version :primary do
  #    process  :resize_to_fill =>[171,237]
  #    #  process :resize_to_limit => [270, 410]
  #    #  process :cropper=>[250,410]
  #    #  process :outliner
  #  end

  version :slider, :if=>:not_pdf?   do
    process :resize_to_fill => [634, 423]
    #  process :outliner
  end

  #  version :product_slider do
  #    process :resize_to_fill => [651, 340]
  #  end

  #  version :advertisement do
  #    process :resize_to_limit => [140, 140]
  #  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end


  def pdf?(file)
    File.extname(current_path).upcase == ".PDF"
  end
  
  def not_pdf?(file)
    File.extname(current_path).upcase != ".PDF"
  end


  def cover
    manipulate! do |frame, index|
      frame if index.zero? # take only the first page of the file
    end
  end

  version :pdf_preview , :if => :pdf? do
      process :cover
      process :resize_to_fit => [150, 150]
      process :convert => :jpg

      def full_filename (for_file = model.source.file)
        super.chomp(File.extname(super)) + '.jpg'
      end
    
  end
  
  version :pdf_thumb, :if => :pdf? do
    process :cover
    process resize_to_fit: [100, 100]
    process :convert => :jpg
    
       def full_filename (for_file = model.source.file)
        super.chomp(File.extname(super)) + '.jpg'
      end
end

     
     load Rails.root.join('config', 'initializers', 'image_uploader.rb') rescue ""


  def validate_integrity
  end
end
