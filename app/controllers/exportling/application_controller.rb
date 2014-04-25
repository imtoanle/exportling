class Exportling::ApplicationController < ApplicationController
  helper Exportling::ApplicationHelper

  # Skip cancan authorization if used
  # TODO: Should be able to use cancan to authorize exports
  if respond_to?(:skip_authorization_check)
    skip_authorization_check
  end

  def current_export_owner
    self.send(Exportling.export_owner_method)
  end
end
