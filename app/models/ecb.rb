class Ecb
  include Celluloid
  include Requestable

  def initialize
    @base_url = 'http://localhost:8080/ecb/'
    @url = @base_url
  end

  def get_rate src, dst #symbols here ok
    request
    destination = Nokogiri::XML(@response).at_css("Cube[currency='#{dst.to_s.upcase}']")
                    .attributes['rate'].value.to_f
    if (src == :eur)
      destination
    else
      source = Nokogiri::XML(@response).at_css("Cube[currency='#{src.to_s.upcase}']")
                  .attributes['rate'].value.to_f
      (destination/source).round(4)
    end
  end
end
