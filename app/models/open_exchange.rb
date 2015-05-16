class OpenExchange
  include Celluloid
  include Requestable

  def initialize
    @base_url = "https://openexchangerates.org/api/latest.json"
    @url = @base_url
  end

  def get_rate src, dst #symbols here ok
    request app_id: OPENEXCHANGE_KEY
    (@response["rates"]["#{dst.to_s.upcase}"] / @response["rates"]["#{src.to_s.upcase}"]).round(4)
  end

  private

  def request **params
    unless response
      super
      @response = JSON.parse @response
    end
  end

end
