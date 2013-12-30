require 'lexster'
require 'active_record'
require 'neography'
require 'rest-client'

# ENV['NEOID_LOG'] = 'true'

uri = URI.parse(ENV["NEO4J_URL"] ? ENV["NEO4J_URL"] : ENV['TRAVIS'] ? "http://localhost:7474" : "http://localhost:7574")
$neo = Neography::Rest.new(uri.to_s)

Neography.configure do |c|
  c.server = uri.host
  c.port = uri.port

  if uri.user && uri.password
    c.authentication = 'basic'
    c.username = uri.user
    c.password = uri.password
  end
end

Lexster.db = $neo

logger, ActiveRecord::Base.logger = ActiveRecord::Base.logger, Logger.new('/dev/null')
ActiveRecord::Base.configurations = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'support/database.yml')))
ActiveRecord::Base.establish_connection('sqlite3')

require 'support/schema'
require 'support/models'

ActiveRecord::Base.logger = logger

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
  end
  
  config.before(:each) do
    Lexster.node_models.each(&:destroy_all)
    Lexster.clean_db(:yes_i_am_sure)
    Lexster.reset_cached_variables
  end
end

Lexster.initialize_all
