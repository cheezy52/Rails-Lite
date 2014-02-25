require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @req = req
    @params = parse_www_encoded_form(req.query_string)
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    @params = {}
    keyval_arrays = []

    keyval_arrays += URI.decode_www_form(www_encoded_form) unless www_encoded_form.nil?
    keyval_arrays += URI.decode_www_form(@req.body) unless @req.body.nil?

    keyval_arrays.each do |array|
      parsed_key = parse_key(array[0])
      nested_param = nest_hashes(parsed_key, array[1])

      state = @params
      address_params(state, nested_param)
    end

    p @params
    @params
  end

  def address_params(state, nested_param)
    #only one key, this is just how we access it
    nested_param.each do |key, val|

      #already in params, need to go deeper
      if state[key]
        state = state[key]
        #val = "the rest of the deeper hash"
        address_params(state, val)

      #new entry, add to hash
      else
        state[key] = val
      end
    end
  end

  def nest_hashes(parsed_key, val)
    if parsed_key.count == 1
      { parsed_key[0] => val }
    else
      { parsed_key[0] => nest_hashes(parsed_key[1..-1], val) }
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.dup.split(/\]\[|\[|\]/)
  end
end
