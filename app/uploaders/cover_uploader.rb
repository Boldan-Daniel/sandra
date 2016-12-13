# encoding: utf-8

class CoverUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    url = "uploads/#{model.class.to_s.underscore}/#{mounted_as}/default/cover.jpg"
    url.prepend('/') unless url[0] == '/'
    url
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

end
