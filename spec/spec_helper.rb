require 'rspec'
require 'factory_girl'

require 'webshot'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
