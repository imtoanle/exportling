FactoryGirl.define do
  factory :house do
    sequence(:price) { |n| n }
    sequence(:square_meters) { |n| n * 100 }
  end
end

