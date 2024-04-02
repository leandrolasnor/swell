# frozen_string_literal: true

class EventListener
  def on_supply(event)
    payload = event[:payload]
    res = ::SupplyAction.new.(payload:)
    puts res.exception.message if res.failure?
    $state << res.value! if res.success?
  end

  def on_withdraw(event)
    payload = event[:payload]
    res = ::WithdrawAction.new.(payload:)
    puts res.exception.message if res.failure?
    $last_withdraw = payload if res.success?
    $state << res.value! if res.success?
  end
end
