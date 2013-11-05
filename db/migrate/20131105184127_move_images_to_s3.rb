class MoveImagesToS3 < ActiveRecord::Migration
  def up
    if Rails.env == "production"
      Image.find_each do |image|
        image_path = URI.parse(image.url.to_s).path
        image.update_attribute("remote_url_url", "http://10.178.23.181#{image_path}")
      end
    end
  end

  def down
  end
end
