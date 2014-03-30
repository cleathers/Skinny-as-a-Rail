require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req.cookies.map do |cookie|
      if cookie.name == '_rails_lite_app'
        @cookie = JSON.parse(cookie.value)
      end
    end
    @cookie = !!@cookie ? @cookie : Hash.new(0)
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    p " STORE SESSION CALLED "
    new_cookie = WEBrick::Cookie.new('_rails_lite_app', @cookie.to_json)
    res.cookies << new_cookie 
  end
end
