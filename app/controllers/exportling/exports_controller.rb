# TODO: Ensure all exports scoped to owner
class Exportling::ExportsController < Exportling::ApplicationController
  decorates_assigned :export

  def index
    # query = params[:q] || {}
    # query.merge({ owner_id_eql: current_export_owner.id })
    # @query = Exportling::Export.ransack(query)
    # exports = @query.result.page(params[:page] || 1)
    exports  = Exportling::Export.where(owner_id: _current_export_owner.id)
                                 .order(created_at: :desc)
                                 .page(params[:page] || 1)
    @exports = Exportling::ExportsDecorator.decorate(exports)
  end

  def new
    name = params[:name] || params[:klass]
    # TODO: Improve how klass is specified
    #        The current method of including it in hidden fields opens it
    #        up to user tampering
    @export = Exportling::Export.new(name: name,
                                     klass: params[:klass],
                                     owner_id: _current_export_owner.id,
                                     params: params[:params],
                                     file_type: params[:file_type])
    unless @export.valid?
      raise ArgumentError, @export.invalid_attributes_message
    end
  end

  def create
    @export = Exportling::Export.new(export_params)

    # Hashes are not permitted by strong parameters, so we need to pull the params out separately
    # See: https://github.com/rails/strong_parameters#permitted-scalar-values
    @export.params = params[:export][:params]
    @export.owner  = _current_export_owner

    unless @export.valid?
      raise ArgumentError, @export.invalid_attributes_message
    end

    # Save the export and start it processing
    @export.save
    @export.perform_async!

    redirect_to root_path
  end

  def download
    @export = Exportling::Export.find_by(id: params[:id], owner_id: _current_export_owner.id)

    if @export.nil?
      flash[:error] = I18n.t('exportling.export.download.not_found')
      redirect_to root_path
    elsif @export.incomplete?
      flash[:error] = I18n.t('exportling.export.download.incomplete')
      redirect_to root_path
    else
      send_file_options = {
        disposition:  'attachment',
        x_sendfile:   true,
        filename:     @export.file_name
      }
      send_file @export.output.path, send_file_options
    end
  end

  def retry
    @export = Exportling::Export.find_by(id: params[:id],
                                         owner_id: _current_export_owner.id)
    @export.status = 'pending'
    @exports.save
    @export.perform!
  end

  def export_params
    params.require(:export).permit(
      :klass, :file_type, :name
    )
  end
end
