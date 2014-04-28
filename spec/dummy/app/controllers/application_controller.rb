class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Method called by exportling to determine current export owner
  # Generally defined by the authentication gem (e.g current_user for devise)
  def current_export_owner
    User.first_or_create
  end
end
