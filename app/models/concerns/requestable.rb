module Requestable
  extend ActiveSupport::Concern

  attr_accessor :base_url, :response

  ONE_INSTANCE_PER_CURRENCY = false

  protected

  def request **params
    @response = RestClient.get @url, { :params => params } unless @response
    @response
  end

end
