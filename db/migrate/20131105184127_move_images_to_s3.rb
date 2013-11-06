class MoveImagesToS3 < ActiveRecord::Migration
  def up
      Image.find_each do |image|
        image_path = URI.parse(image.url.to_s).path.gsub('//', '/')
        image.update_attribute("remote_url_url", "http://kokavo.com#{image_path}")
      end
  end

  def down
  end
end
