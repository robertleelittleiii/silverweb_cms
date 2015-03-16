
  module ImageTools
require 'RMagick'
include Magick


  def self.test
    return   "hello world"
  end
  
  def self.border_on_image(picture,width,offset,color, border)
    
    draw = Magick::Draw.new
    draw.stroke(color)
    draw.stroke_width(width)
      
    0.upto(border - 1) do |x|
      draw.line(x+offset, 0+offset, x+offset, picture.rows-offset-1)
      
 #     draw.stroke("blue")
      draw.line(picture.columns-x-1-offset, 0+offset, picture.columns-x-1-offset, picture.rows-offset-1)
      
#      draw.stroke("green")
      draw.line(0+offset, x+offset, picture.columns-offset-1, x+offset)
      
#      draw.stroke("red")
      draw.line(0+offset, picture.rows-x-1-offset, picture.columns-offset-1, picture.rows-x-1-offset)
    end
      
    draw.draw(picture)
    
    return picture
  end
  
  def self.thumnail_from_pdf(file_path)
    
    pdf = Magick::ImageList.new(file_path)
    pdf[0].write("test.png")
    
    # pdf = Magick::ImageList.new(file)
   # puts(pdf.inspect)
   # return pdf
   return picture
  end
  
  
  
  end