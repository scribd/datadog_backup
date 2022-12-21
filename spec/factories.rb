class BodyStrategy
  def initialize
    @strategy = FactoryBot.strategy_by_name(:create).new
  end

  #delegate :association, to: :@strategy

  def result(evaluation)
    JSON.parse(@strategy.result(evaluation).dump(:json))
  end
end

FactoryBot.register_strategy(:body, BodyStrategy)

FactoryBot.define do
  factory :dashboard, class: DatadogBackup::Dashboards do
    id { 'abc-123-def' }
    body { 
      { 
        'id' => 'abc-123-def',
        'title' => 'abc' 
      } 
    }

    skip_create
    initialize_with { DatadogBackup::Dashboards.new_resource(id: id, body: body) }
  end

  factory :monitor, class: DatadogBackup::Monitors do
    id { '12345' }
    body { 
      { 
        'id'=> '12345',
        'name' => '12345'
      } 
    }

    skip_create
    initialize_with { DatadogBackup::Monitors.new_resource(id: id, body: body) }
  end

  factory :synthetic_api, class: DatadogBackup::Synthetics do
    id { 'mno-789-pqr' }
    body { 
      { 
        'type' => 'api',
        'public_id' => 'mno-789-pqr',
      } 
    }

    skip_create
    initialize_with { DatadogBackup::Synthetics.new_resource(id: id, body: body) }
  end

  factory :synthetic_browser, class: DatadogBackup::Synthetics do
    id { 'stu-456-vwx' }
    body { 
      { 
        'type' => 'browser',
        'public_id' => 'stu-456-vwx',
      } 
    }

    skip_create
    initialize_with { DatadogBackup::Synthetics.new_resource(id: id, body: body) }
  end
end
