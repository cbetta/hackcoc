Rails.application.routes.default_url_options[:host] = begin
  if Rails.env.development?
    'localhost:5000'
  else
    'hackcodeofconduct.org'
  end
end
