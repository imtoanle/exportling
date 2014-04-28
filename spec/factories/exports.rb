FactoryGirl.define do
  factory :export, class: Exportling::Export do
    association :owner, factory: :user
    klass  'HouseCsvExporter'
    status 'created'
    file_type 'csv'

    # TODO: build a house object from another factory if none provided
    params Hash[house: { id: 2 }]
  end
end
