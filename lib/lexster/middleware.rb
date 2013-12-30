module Lexster
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      old_enabled, Thread.current[:lexster_enabled] = Thread.current[:lexster_enabled], true
      old_batch, Thread.current[:lexster_current_batch] = Thread.current[:lexster_current_batch], nil
      @app.call(env)
    ensure
      Thread.current[:lexster_enabled] = old_enabled
      Thread.current[:lexster_current_batch] = old_batch
    end
  end
end
