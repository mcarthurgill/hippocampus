class Link < ActiveRecord::Base

  attr_accessible :best_image, :best_title, :description, :favicon, :host, :images, :images_with_size, :response_status, :root_url, :scheme, :title, :url

  serialize :images, Array
  serialize :images_with_size, Array

  

  def self.refresh_cache_for_url url_string
    page = MetaInspector.new(url_string)
    self.create_with_page(page)
  end

  def self.create_with_page page
    if page && page.response.status == 200 && page.best_title
      link = Link.find_or_initialize_by_url(page.url)
      link.title = page.title
      link.scheme = page.scheme
      link.root_url = page.root_url
      link.response_status = page.response.status
      link.images = page.images.to_json if page.images.count > 0
      link.images_with_size = page.images.with_size if page.images.count > 0
      link.host = page.host
      link.favicon = page.images.favicon
      link.description = page.description
      link.best_title = page.best_title
      link.best_image = page.best_image
      link.save!
      return link
    end
  end

end
