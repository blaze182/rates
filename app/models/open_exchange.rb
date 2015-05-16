class OpenExchange
  include Celluloid
  include Requestable

  def initialize
    @base_url = "http://localhost:8080/openexchange/"
    @url = @base_url
  end

  def get_rate src, dst #symbols here ok
    request
    (@response["rates"]["#{dst.to_s.upcase}"] / @response["rates"]["#{src.to_s.upcase}"]).round(4)
  end

  private

  def request
    unless response
      super
      @response = JSON.parse @response
    end
  end

end
