# frozen_string_literal: true

class EventListener
  def on_event(event)
    payload = event[:payload]
    case payload
    in { caixa: {caixaDisponivel: true | false, notas: {notasCem: Integer, notasCinquenta: Integer, notasVinte: Integer, notasDez: Integer}}}
      ::SupplyReducer.new(payload:).call
    in {saque: {valor: Integer, horario: String}}
      ::WithdrawReducer.new(payload:).call
    else
      $state
    end
  end
end
