require 'debugger'
require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = Hash.new(0)
    @query_string_params = (req.query_string.nil?) ? {} : parse_www_encoded_form(req.query_string)
    @req_body_params = (req.body.nil?) ? {} : parse_www_encoded_form(req.body) 
    @params = @query_string_params.merge(@req_body_params).merge(route_params) 
  end


  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted ||= []
    keys.each do |key|
      @permitted << key
    end
  end

  def require(key)
    raise AttributeNotFoundError unless @params.has_key?(key)
  end

  def permitted?(key)
    @permitted.include?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    decoded = URI.decode_www_form(www_encoded_form)
    params = Hash.new(0)
    decoded.each do |pair|
      keys = parse_key(pair[0])
      val = pair[1]
    
      until keys.empty? 
        if keys.count == 1
          params[keys.pop] = val
        else
          nested_params = Hash.new
          nested_params[keys.pop] = val
          val = nested_params 
        end
      end
    end
    params
  end


  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
