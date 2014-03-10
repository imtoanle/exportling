module Exportling
  module ApplicationHelper
    def method_missing(method, *args, &block)
      main_app.send(method, *args)
    end
  end
end
