# frozen_string_literal: true

class EventListener
  def on_supply(event)
    payload = event[:payload]
    res = ::SupplyAction.new.(payload:)
    $state << deep_copy(res.value!) if res.success?
  end

  def on_withdraw(event)
    payload = event[:payload]
    res = ::WithdrawAction.new.(payload:)
    $last_withdraw = payload if res.success?
    $state << deep_copy(res.value!) if res.success?
  end

  private

  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end
end
