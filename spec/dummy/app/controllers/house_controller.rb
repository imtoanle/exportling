class HouseController < ApplicationController

  def index
    @houses = House.all

    # Hard code the owner for now
    @user   = User.find_by(name: 'Dave')
  end
end
