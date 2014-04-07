# TODO: Ensure all exports scoped to owner
class Exportling::ExportsController < Exportling::ApplicationController
  def index
    # @exports = Exportling::Export.where(owner: params[:owner_id])
    @exports = Exportling::Export.all
  end

  def new
    # TODO: security
    @export = Exportling::Export.new(klass: params[:klass],
                                     method: params[:method],
                                     owner_id: params[:owner_id],
                                     params: params[:params],
                                     file_type: params[:file_type])
  end

  def create
    # TODO: security
    @export = Exportling::Export.new(export_params)

    # TODO: Major sercurity
    # We Need to allow main application to specify owner in control action, rather than just supplying it in the form
    @export.owner = Exportling.export_owner_class.find(params[:export][:owner_id])

    byebug

    # TODO: Some kind of error handling
    if @export.valid?
      @export.save

      redirect_to exports_path
    end
  end

  def download
    @export = Exportling::Export.find(params[:export_id])
    # TODO: security

    # FIXME: provide a way to download the file
    # redirect_to @export.output.url
  end

  def export_params
    params.require(:export).permit(
      :klass, :params, :method, :file_type
    )
  end
end
