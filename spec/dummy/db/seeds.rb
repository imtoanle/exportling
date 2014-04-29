100.times do |i|
  House.create!(square_meters: i, price: i * 15, furnished: i % 2)
end

User.create(name: 'Dave')
