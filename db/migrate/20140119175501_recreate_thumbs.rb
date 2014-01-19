class RecreateThumbs < ActiveRecord::Migration
  def up
    Image.find_each { |img| img.url.recreate_versions! }
  end

  def down
  end
end
