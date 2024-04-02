# frozen_string_literal: true

class InputListener
  include Dry::Events::Publisher[:event_publisher]
  extend Dry::Initializer

  option :event_listener, default: -> { subscribe(EventListener.new) }, reader: :private

  register_event('supply')
  register_event('withdraw')

  def on_input(event)
    input = event[:input]
    case input
    in { caixa: {caixaDisponivel: true | false, notas: {notasCem: Integer, notasCinquenta: Integer, notasVinte: Integer, notasDez: Integer}}}
      publish('supply', payload: input)
    in {saque: {valor: Integer, horario: String}}
      publish('withdraw', payload: input)
    end
  end
end
