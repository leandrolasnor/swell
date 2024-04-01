# frozen_string_literal: true

class RunCommand < Dry::CLI::Command
  include Dry::Events::Publisher[:publisher]
  register_event('event')

  desc 'Read inputs from inputs.json file'

  def call
    subscribe(EventListener.new)
    File.open('inputs.json', 'r') do |file|
      publish('event', payload: JSON.parse(file.read, symbolize_names: true))
    end
    File.write('output.json', JSON.pretty_generate($state))
  end
end
