# frozen_string_literal: true

class RunCommand < Dry::CLI::Command
  include Dry::Events::Publisher[:input_publisher]
  register_event('input')

  desc 'Read inputs from inputs.json file'

  def call
    subscribe(InputListener.new)
    File.open('inputs.json', 'r') do |file|
      JSON.parse(file.read, symbolize_names: true).each { publish('input', input: _1) }
    end
    File.write('output.json', JSON.pretty_generate($state))
  end
end
