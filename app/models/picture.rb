class Picture < ActiveRecord::Base

  
  belongs_to :menues, :polymorphic => true
  belongs_to :product, :polymorphic => true
  belongs_to :settings
  belongs_to :advertisement, :polymorphic => true
  
  mount_uploader :image, ImageUploader

  #after_initialize :init

    scope :visible,-> { where(:active_flag=>true).order('position desc')}

  
  # set the active_flag to be true by default for all images.
  #def init
  #  self.active_flag = true if self.active_flag.nil?
  #end
  
  
   
   
  # Will set the default name to be the file name before the record is created in active record.
  
  def default_name
    self.file_name ||= File.basename(image.filename.to_s, '.*').titleize if image
  end
  
  # returns the file type of the object, retuning the .xxx extension.
   def file_type
     File.extname(image.file.path) if image
   end
   
     # returns the name of the file titlelized
    
   def file_name
     begin
     File.basename(image.file.path, '.*').titleize if image
     rescue
     end
    # File.basename(image.filename, '.*').titleize
   end
   
   # returns the name of the file titlelized
   def file_path
    image.path
  end
  
  def self.reorder(id,position)
    puts(id, position)
    ActiveRecord::Base.connection.execute ("UPDATE `pictures` SET `position` = '"+position.to_s+"' WHERE `pictures`.`id` ="+id.to_s+" LIMIT 1 ;")
  end
  
end
