class RatesController < ApplicationController
  after_action :destroy_actors

  def index
    providers     = {oe: OpenExchange, ecb: Ecb, ca: CurrApi}
    base_currency = :eur
    currencies    = [:aud, :usd, :nok]

    @salt = request.uuid.gsub('-','') # unique actor ids per request
    @instances = prepare_instances providers, currencies
    supervise @instances
    
    tasks = enqueue_tasks @instances, currencies, base_currency

    @response = get_tasks_results providers, currencies, tasks
  end

  private

  @instances
  @salt
  @supervisiongroup

  def prepare_instances providers, currencies
    providers.reduce({}) do |hash, (key, provider)|
      if (provider::ONE_INSTANCE_PER_CURRENCY)
        hash.merge(
          key => {
            provider:  provider,
            instances: currencies.map { |curr| merge_symbols(key, curr, @salt) }
          }
        )
      else
        hash.merge(
          key => {
            provider:  provider,
            instances: [merge_symbols(key, @salt)]
          }
        )
      end
    end
  end

  def merge_symbols *sym
    sym.join('_').to_sym
  end

  def supervise instances
    @supervisiongroup = Celluloid::SupervisionGroup.new
    instances.each do |key, value|
      value[:instances].each do |instance|
        @supervisiongroup.add value[:provider], as: instance
      end
    end
  end

  def destroy_actors
    @supervisiongroup.terminate
  end

  def enqueue_tasks instances, currencies, base_currency
    future_objects = kill_values_in_hash instances

    instances.each do |key, value|
      if value[:provider]::ONE_INSTANCE_PER_CURRENCY
        value[:instances].each_with_index do |instance, idx|
          future_objects[key][currencies[idx]] = Celluloid::Actor[instance].future
                                                    .get_rate base_currency, currencies[idx]
        end
      else
        currencies.each do |currency|
          future_objects[key][currency] = Celluloid::Actor[value[:instances][0]].future
                                                .get_rate base_currency, currency
        end
      end
    end

    future_objects
  end

  def get_tasks_results providers, currencies, future_objects
    # results = kill_values_in_hash providers
    results = Hash[currencies.map{ |currency| [currency, Hash.new] }]

    future_objects.each do |provider, currencies|
      currencies.each do |currency, future_object|
        results[currency][provider] = future_object.value
      end
    end
    results
  end

  def kill_values_in_hash hash
    hash.reduce({}) { |hash, (key, value)| hash.merge(key => Hash.new) }
  end

end
