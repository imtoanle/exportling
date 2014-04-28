# TODO: Ensure all exports scoped to owner
class Exportling::ExportsController < Exportling::ApplicationController

  decorates_assigned :export

  def index
    exports  = Exportling::Export.where(owner_id: _current_export_owner.id)
    @exports = Exportling::ExportDecorator.decorate_collection(exports)
  end

  def new
    # TODO: Improve how klass is specified
    #        The current method of including it in hidden fields opens it
    #        up to user tampering
    @export = Exportling::Export.new(klass: params[:klass],
                                     owner_id: _current_export_owner.id,
                                     params: params[:params],
                                     file_type: params[:file_type])

    unless @export.valid?
      raise ArgumentError, @export.invalid_atributes_message
    end
  end

  def create
    @export = Exportling::Export.new(export_params)

    # Hashes are not permitted by strong parameters, so we need to pull the params out separately
    # See: https://github.com/rails/strong_parameters#permitted-scalar-values
    @export.params = params[:export][:params]
    @export.owner  = _current_export_owner

    unless @export.valid?
      raise ArgumentError, @export.invalid_atributes_message
    end

    @export.save
    # FIXME: Sidekiq isn't picking these jobs up (probably not configured correctly locally)
    # @export.worker_class.perform_async(@export.id)
    @export.perform! # Perform export synchronously for now

    redirect_to root_path
  end

  # TODO: Consider making this the show action (we don't use #show otherwise)
  def download
    @export = Exportling::Export.find_by(id: params[:id], owner_id: _current_export_owner.id)

    if @export.nil?
      flash[:error] = I18n.t('exportling.export.download.not_found')
      redirect_to root_path
    elsif @export.incomplete?
      flash[:error] = I18n.t('exportling.export.download.incomplete')
      redirect_to root_path
    else
      send_file @export.output.path, disposition: 'attachment', x_sendfile: true, filename: @export.file_name
    end
  end

  def export_params
    params.require(:export).permit(
      :klass, :file_type
    )
  end
end
