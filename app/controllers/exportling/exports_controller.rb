# TODO: Ensure all exports scoped to owner
class Exportling::ExportsController < Exportling::ApplicationController

  decorates_assigned :export

  def index
    exports  = Exportling::Export.where(owner_id: _current_export_owner.id)
    @exports = Exportling::ExportDecorator.decorate_collection(exports)
  end

  def new
    @export = Exportling::Export.new(klass: params[:klass],
                                     owner_id: _current_export_owner.id,
                                     params: params[:params],
                                     file_type: params[:file_type])
  end

  def create
    @export = Exportling::Export.new(export_params)

    # Hashes are not permitted by strong parameters, so we need to pull the params out separately
    # See: https://github.com/rails/strong_parameters#permitted-scalar-values
    @export.params = params[:export][:params]
    @export.owner  = _current_export_owner


    # TODO: Some kind of error handling
    if @export.valid?
      @export.save

      # FIXME: Sidekiq isn't picking these jobs up (probably not configured correctly locally)
      # @export.worker_class.perform_async(@export.id)
      @export.worker_class.perform(@export.id)  # Perform export synchronously for now

      redirect_to exports_path
    end
  end

  def download
    @export = Exportling::Export.find_by(id: params[:id], owner_id: _current_export_owner.id)
      send_file @export.output.path, disposition: 'attachment', x_sendfile: true, filename: @export.file_name
  end

  def export_params
    params.require(:export).permit(
      :klass, :file_type
    )
  end
end
