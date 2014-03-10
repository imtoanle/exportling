class Exportling::ExportsController < Exportling::ApplicationController
  def index
    @exports = Exportling::Export.where(user: current_user)
  end

  def new
    # TODO: security
    @export = Exportling::Export.new(klass: params[:klass],
                                     method: params[:method],
                                     params: params[:params],
                                     file_type: params[:file_type])
  end

  def create
    # TODO: security
    @export = Exportling::Export.new(export_params)
    @export.user = current_user || nil

    if @export.valid?
      @export.save

      redirect_to exports_path
    end
  end

  def download
    @export = Exportling::Export.find(params[:id])
    # TODO: security
    redirect_to @export.output.url
  end

  def export_params
    params.require(:export).permit(
      :klass, :params, :method, :file_type
    )
  end
end
