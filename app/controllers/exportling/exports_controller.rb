# TODO: Ensure all exports scoped to owner
class Exportling::ExportsController < Exportling::ApplicationController
  before_action :load_and_authorize_export, only: [:download, :retry]

  decorates_assigned :export

  def index
    # query = params[:q] || {}
    # query.merge({ owner_id_eql: current_export_owner.id })
    # @query = Exportling::Export.ransack(query)
    # exports = @query.result.page(params[:page] || 1)
    exports = using_pundit ? policy_scope(exports_scope) : exports_scope
    @exports = Exportling::ExportsDecorator.decorate(exports)
  end

  def new
    # TODO: Improve how klass is specified
    #        The current method of including it in hidden fields opens it
    #        up to user tampering
    @export = ExportCreator.new(export_params, _current_export_owner).perform
    authorize_new_export

    unless @export.valid?
      fail ArgumentError, @export.decorate.invalid_attributes_message
    end
  end

  def create
    @export = ExportCreator.new(export_params, _current_export_owner).perform
    authorize_new_export

    unless @export.valid?
      fail ArgumentError, @export.decorate.invalid_attributes_message
    end

    # Save the export and start it processing
    @export.save
    @export.perform_async!

    redirect_to root_path
  end

  def download
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
      redirect_to  @export.output.url
    end
  end

  def retry
    @export.status = 'created'
    @export.save
    @export.perform_async!

    flash[:message] = I18n.t('exportling.export.retry')
    redirect_to root_path
  end

  private

  def load_and_authorize_export
    @export = Exportling::Export.find_by(id: params[:id],
                                         owner_id: _current_export_owner.id)

    authorize(@export) if using_pundit
  end

  def authorize_new_export
    return unless using_pundit

    if @export.authorize_on_class.nil?
      msg = "You must pass a class name to authorize_on_class in your exporter"
      raise ArgumentError, msg
    end

    authorize(@export.authorize_on_class, :export?)
  end

  def export_params
    ExportRequest.new(params.require(:export).permit!).to_hash
  end

  def exports_scope
    Exportling::Export.where(owner_id: _current_export_owner.id)
                                     .order(created_at: :desc)
                                     .page(params[:page] || 1)
  end
end
