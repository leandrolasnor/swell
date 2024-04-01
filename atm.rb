# frozen_string_literal: true

$last_withdraw = { saque: { valor: 0, horario: '1970-01-01T00:00:00.000Z' } }
$caixa = {
  caixaDisponivel: false,
  notas: {
    notasDez: 0,
    notasVinte: 0,
    notasCinquenta: 0,
    notasCem: 0
  }
}
$state = []

require 'active_support/all'
require 'dry/initializer'
require 'dry/validation'
require 'dry/events'
require 'dry/monads'
require 'dry/cli'
require 'date'
require 'json'
require 'pry'

Dir['./commands/**/*.rb'].each { require _1 }
Dir['./reducers/**/*.rb'].each { require _1 }
Dir['./listeners/**/*.rb'].each { require _1 }
Dir['./overrides/**/*.rb'].each { require _1 }

module Commands
  extend Dry::CLI::Registry
  register 'run', RunCommand
end
Dry::CLI.new(Commands).call
