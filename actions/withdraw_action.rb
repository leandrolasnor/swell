# frozen_string_literal: true

class WithdrawAction
  include Dry::Monads[:try]
  extend Dry::Initializer

  module Types
    include Dry.Types()
  end

  option :state, type: Types::Hash, default: -> { {} }, render: :private

  def call(payload:)
    Try do
      if $atm.blank?
        @state[:caixa] = {}
        @state[:erros] = ["caixa-inexistente"]
      elsif $atm[:caixaDisponivel] == false
        @state[:caixa] = $atm
        @state[:erros] = ["caixa-indisponivel"]
      elsif withdraw_duplicated?
        @state[:caixa] = {}
        @state[:erros] = ["saque-duplicado"]
      elsif (total_atm < payload[:saque][:valor].to_i) || !calculate_remainder?
        @state[:caixa] = $atm
        @state[:erros] = ["valor-indisponivel"]
      else
        $atm[:notas] = @remainder
        @state[:caixa] = $atm
        @state[:erros] = []
      end

      @state
    end
  end

  private

  def calculate_remainder?
    notasCem, rest = payload[:saque][:valor].to_i.divmod(100)
    notasCinquenta, rest = rest.divmod(50) if rest.positive?
    notasVinte, rest = rest.divmod(20) if rest.positive?
    notasDez, rest = rest.divmod(10) if rest.positive?

    return false if rest.positive?

    @remainder = {
      notasCem: $atm[:notas][:notasCem] - notasCem,
      notasCinquenta: $atm[:notas][:notasCinquenta] - notasCinquenta,
      notasVinte: $atm[:notas][:notasVinte] - notasVinte,
      notasDez: $atm[:notas][:notasDez] - notasDez
    }
  end

  def withdraw_duplicated?
    (($last_withdraw[:saque][:horario].to_time + 10.minutes).to_i >= payload[:saque][:horario].to_time.to_i) && \
      $last_withdraw[:saque][:valor] == payload[:saque][:valor]
  end

  def total_atm
    @total_atm ||= $atm[:notas].sum do |currency, quantity|
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
