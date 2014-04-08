FactoryGirl.define do
  factory :export, class: Exportling::Export do
    # klass is the exporter class
    klass  'HouseExporter'
    status 'created'
    file_type 'csv'

    # TODO: build a house object from another factory if none provided
    params Hash[house: { id: 2 }]

    # FIXME: model shouldn't have a field named 'method', as this is semi-protected in ruby (which is why it's currently in after build)
    after(:build) do |export, evaluator|
      export.method = 'TODO'
    end
  end
end
