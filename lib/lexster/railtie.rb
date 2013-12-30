require 'lexster/middleware'

module Lexster
  class Railtie < Rails::Railtie
    initializer "lexster.configure_rails_initialization" do
      config.after_initialize do
        Lexster.initialize_all
      end
    end

    initializer 'lexster.inject_middleware' do |app|
      app.middleware.use Ndoid::Middleware
    end
  end
end
