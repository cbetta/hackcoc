module ApplicationHelper
  def link_if text, url
    return nil if text.blank? && url.blank?
    return text if url.blank?
    return link_to simple_url(url), url if text.blank?
    return link_to text, url
  end

  def simple_url url
    uri = Domainatrix.parse(url)
    "#{uri.domain}.#{uri.public_suffix}#{uri.path unless uri.path == '/'}"
  end
end
