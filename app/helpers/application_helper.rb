module ApplicationHelper
  def link_if text, url
    return nil if text.blank? && url.blank?
    return truncate(text, length: 20) if url.blank?
    return link_to simple_url(url), url, rel: 'external' if text.blank?
    return link_to truncate(text, length: 18), url, rel: 'external'
  end

  def simple_url url
    uri = Domainatrix.parse(url)
    text = "#{uri.domain}.#{uri.public_suffix}#{uri.path unless uri.path == '/'}"
    truncate(text,  length: 20)
  end
end
