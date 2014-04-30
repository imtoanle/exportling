module Exportling
  class ExportDecorator < Draper::Decorator
    delegate_all
    # This error message is not shown to end users (as they don't control form composition)
    # It is an error message for developers using exportling, and is raised
    # in the export controller's create action if the export is invalid
    def invalid_attributes_message
      return '' if valid?

      attribute_error_messages = errors.full_messages.join('. ') + '.'
      I18n.t('exportling.export.invalid_attributes') + ' ' + attribute_error_messages
    end

    def elapsed
      return I18n.t('exportling.export.elapsed_created') unless processed?

      taken = (started_at - completed_at).round
      if taken < 1
        I18n.t('exportling.export.elapsed_fast')
      else
        taken
      end
    end
  end
end
