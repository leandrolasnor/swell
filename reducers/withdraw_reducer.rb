# frozen_string_literal: true

class WithdrawReducer
  include Dry::Monads[:try]
  extend Dry::Initializer

  module Types
    include Dry.Types()
  end

  option :payload, type: Types::Hash, reader: :private
  option :state, type: Types::Hash, default: -> { {} }, render: :private

  def call
    res = Try do
      if $caixa.blank?
        @state[:caixa] = {}
        @state[:erros] = ["caixa-inexistente"]
      elsif $caixa[:caixaDisponivel] == false
        @state[:caixa] = $caixa
        @state[:erros] = ["caixa-indisponivel"]
      elsif withdraw_duplicated?
        @state[:caixa] = {}
        @state[:erros] = ["saque-duplicado"]
      elsif (total_atm < payload[:saque][:valor].to_i) || !calculate_remainder?
        @state[:caixa] = $caixa
        @state[:erros] = ["valor-indisponivel"]
      else
        $caixa[:notas] = @remainder
        @state[:caixa] = $caixa
        @state[:erros] = []
      end

      @state
    end

    $last_withdraw = payload if res.success?
    $state << res.value! if res.success?
    $state << { exception: res.exception.message } if res.failure?
    $state
  end

  private

  def calculate_remainder?
    notasCem, rest = payload[:saque][:valor].to_i.divmod(100)
    notasCinquenta, rest = rest.divmod(50) if rest.positive?
    notasVinte, rest = rest.divmod(20) if rest.positive?
    notasDez, rest = rest.divmod(10) if rest.positive?

    return false if rest.positive?

    @remainder = {
      notasCem: $caixa[:notas][:notasCem] - notasCem,
      notasCinquenta: $caixa[:notas][:notasCinquenta] - notasCinquenta,
      notasVinte: $caixa[:notas][:notasVinte] - notasVinte,
      notasDez: $caixa[:notas][:notasDez] - notasDez
    }
  end

  def withdraw_duplicated?
    (($last_withdraw[:saque][:horario].to_time + 10.minutes).to_i >= payload[:saque][:horario].to_time.to_i) && \
      $last_withdraw[:saque][:valor] == payload[:saque][:valor]
  end

  def total_atm
    @total_atm ||= $caixa[:notas].sum do |currency, quantity|
      case currency
      when :notasDez
        10 * quantity
      when :notasVinte
        20 * quantity
      when :notasCinquenta
        50 * quantity
      when :notasCem
        100 * quantity
      else 0
      end
    end
  end
end
