class CurrApi
  include Celluloid
  include Requestable

  ONE_INSTANCE_PER_CURRENCY = true

  def initialize
    @base_url = 'http://localhost:8080/currapi/'
    @url = @base_url
  end

  def get_rate src, dst #symbols here ok
    @response = nil
    @url = @base_url + "#{src.to_s.upcase}/#{dst.to_s.upcase}/"
    request
    @response = JSON.parse @response
    if (@response["success"] == true)
      @response["rate"]
    else
      'N/A'
    end
  end

end
