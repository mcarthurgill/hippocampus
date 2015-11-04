class Link < ActiveRecord::Base

  attr_accessible :best_image, :best_title, :description, :favicon, :host, :images, :images_with_size, :local_key, :object_type, :raw_url, :response_status, :root_url, :scheme, :title, :url

  serialize :images, Array
  serialize :images_with_size, Array


  before_save :default_values
  def default_values
    self.local_key ||= "link--#{self.raw_url.sha_encrypted}" if self.raw_url
  end

  

  def self.refresh_cache_for_url url_string
    begin
      page = MetaInspector.new(url_string)
      self.create_with_page(page, url_string)
    rescue Faraday::Error => e
    end
  end

  def self.create_with_page page, rurl = nil
    if page && page.response.status == 200 && page.best_title
      rurl = page.url if !rurl
      link = Link.find_or_initialize_by_raw_url(rurl)
      link.url = page.url
      link.title = page.title
      link.scheme = page.scheme
      link.root_url = page.root_url
      link.response_status = page.response.status
      link.images = JSON.parse(page.images.to_json) if page.images.count > 0
      # link.images_with_size = page.images.with_size if page.images.count > 0
      link.host = page.host
      link.favicon = page.images.favicon
      link.description = page.description
      link.best_title = page.best_title
      link.best_image = page.images.best if page.images.count > 0
      link.save!
      return link
    end
  end

end
