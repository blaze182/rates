module Requestable
  extend ActiveSupport::Concern

  attr_accessor :base_url, :response

  ONE_INSTANCE_PER_CURRENCY = false

  protected

  def request
    @response = RestClient.get @url unless @response
    @response
  end

end
