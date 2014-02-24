module Modeless
  class Image
    extend CarrierWave::Mount
    attr_accessor :user_id, :url
    mount_uploader :url, ImageUploader

    def save
      self.store_url!
    end

    def self.name
      "Image"
    end
  end
end
