module ApplicationHelper
  def link_if text, url
    return nil if text.blank? && url.blank?
    return text if url.blank?
    return link_to url, url if text.blank?
    return link_to text, url
  end
end
