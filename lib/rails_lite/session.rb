require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @req = req
    @cookies = find_cookie(req.cookies) || {}
  end

  def [](key)
    @cookies[key]
  end

  def []=(key, val)
    @cookies[key] = val
  end

  def find_cookie(cookies)
    cookies.each do |cookie|
      return JSON.parse(cookie.value) if cookie.name == "_rails_lite_app"
    end
    nil
  end


  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new("_rails_lite_app", @cookies.to_json)
  end
end
