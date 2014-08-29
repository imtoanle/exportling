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
    # TODO: Improve how klass is specified
    #        The current method of including it in hidden fields opens it
    #        up to user tampering
    @export = ExportCreator.new(export_params, _current_export_owner).perform
    unless @export.valid?
      fail ArgumentError, @export.decorate.invalid_attributes_message
    end
  end

  def create
    @export = ExportCreator.new(export_params, _current_export_owner).perform

    unless @export.valid?
      fail ArgumentError, @export.decorate.invalid_attributes_message
    end

    # Save the export and start it processing
    @export.save
    @export.perform_async!

    redirect_to root_path
  end

  def download
    @export = Exportling::Export.find_by(id: params[:id],
                                         owner_id: _current_export_owner.id)

    if @export.nil?
      flash[:error] = I18n.t('exportling.export.download.not_found')
      redirect_to root_path
    elsif @export.incomplete?
      flash[:error] = I18n.t('exportling.export.download.incomplete')
      redirect_to root_path
    elsif @export.file_missing?
      flash[:error] = I18n.t('exportling.export.download.missing')
      redirect_to root_path
    else
      send_file @export.output.path, @export.send_file_options
    end
  end

  def retry
    @export = Exportling::Export.find_by(id: params[:id],
                                         owner_id: _current_export_owner.id)
    @export.status = 'created'
    @export.save
    @export.perform_async!

    flash[:message] = I18n.t('exportling.export.retry')
    redirect_to root_path
  end

  def export_params
    ExportRequest.new(params.require(:export))
  end
end
