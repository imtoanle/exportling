class Exportling::ExportsController < Exportling::ApplicationController
  def index
    @exports = Exportling::Export.all
  end
end
