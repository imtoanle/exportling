class ExportCreator
  attr_reader :params, :owner

  def initialize(params, owner)
    @params = params
    @owner = owner
  end

  def perform
    Exportling::Export.new(params).tap do |export|
      export.owner = owner
      if params[:name].blank?
        export.name = params[:klass]
      end
    end
  end
end
