class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_attached_file :image, styles: { thumb: '50x50#' }
  validates_attachment_content_type :image, :content_type => /\Aimage/
  validates_attachment_file_name :image, :matches => [/png\Z/, /jpe?g\Z/]
  
  def display_name
    (return name) unless name.blank?
    email
  end
  
  # Assigns the image specified by the url to the user's paperclip managed image attrtibute
  # paperclip requires that the extension and mime type match
  # this code will rewrite the temp file to have an extension if one is missing
  # @param [String] url - the full URL of the image to be assigned as the user's image
  def image_from_url(url)
    unless url.blank?
      begin      
        extname = File.extname(url)
        basename = File.basename(url, extname)
        file = Tempfile.new([basename, extname])
        file.binmode
        open(URI.parse(url)) do |data|
          file.write data.read
        end
        file.rewind
        if extname.blank?
          mime = `file --mime -br #{file.path}`.strip
          mime = mime.gsub(/^.*: */,"")
          mime = mime.gsub(/;.*$/,"")
          mime = mime.gsub(/,.*$/,"")
          extname = "."+mime.split("/")[1]
          File.rename(file.path, file.path+extname)
          file = File.new(file.path+extname)
        end
      rescue Exception => e
        logger.info "EXCEPTION IMPORTING PHOTO"
        logger.info "for user: #{self.inspect}"
        logger.info "error: #{e.message}"
      end
      begin      
        self.image = file
      rescue Exception => e
        logger.info "EXCEPTION STORING PHOTO"
        logger.info "for user: #{self.inspect}"
        logger.info "error: #{e.message}"
      end
    end
  end


end
