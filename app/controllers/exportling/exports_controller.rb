# TODO: Ensure all exports scoped to owner
class Exportling::ExportsController < Exportling::ApplicationController
  decorates_assigned :export

  def index
    # TODO: Limit exports to those associated with current owner
    # @exports = Exportling::Export.where(owner: params[:owner_id])
    @exports = Exportling::ExportDecorator.decorate_collection(Exportling::Export.all)
  end

  def new
    # TODO: security
    @export = Exportling::Export.new(klass: params[:klass],
                                     owner_id: params[:owner_id],
                                     params: params[:params],
                                     file_type: params[:file_type])
  end

  def create
    # TODO: security
    @export = Exportling::Export.new(export_params)

    # Hashes are not permitted by strong parameters, so we need to pull the params out separately
    # See: https://github.com/rails/strong_parameters#permitted-scalar-values
    @export.params = params[:export][:params]

    # TODO: Major sercurity
    # We Need to allow main application to specify owner in control action, rather than just supplying it in the form
    @export.owner = Exportling.export_owner_class.find(params[:export][:owner_id])

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
    # TODO: security
    @export = Exportling::Export.find(params[:id])

    send_file @export.output.path, disposition: 'attachment', x_sendfile: true, filename: @export.file_name
  end

  def export_params
    params.require(:export).permit(
      :klass, :file_type
    )
  end
end
