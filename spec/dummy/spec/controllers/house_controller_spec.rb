require 'spec_helper'

describe HouseController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'export'" do
    it "returns http success" do
      get 'export'
      expect(response).to be_success
    end
  end

end
