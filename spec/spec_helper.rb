require 'simplecov'
require 'simplecov-console'
require 'rspec'

RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

RSpec.configure do |c|
  c.hiera_config = File.expand_path(File.join(__FILE__, '../../spec/hiera.yaml'))
end

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'

  formatter SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console
    ]
  )
end
