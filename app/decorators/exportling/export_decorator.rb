module Exportling
  class ExportDecorator < Draper::Decorator
    delegate_all
    delegate :current_page, :total_entries, :total_pages, :per_page, :offset

    # This error message is not shown to end users (as they don't control form composition)
    # It is an error message for developers using exportling, and is raised
    # in the export controller's create action if the export is invalid
    def invalid_attributes_message
      return '' if valid?

      attribute_error_messages = errors.full_messages.join('. ') + '.'
      I18n.t('exportling.export.invalid_attributes') + ' ' + attribute_error_messages
    end
  end
end
