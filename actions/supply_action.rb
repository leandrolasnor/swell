# frozen_string_literal: true

class SupplyAction
  include Dry::Monads[:try]
  extend Dry::Initializer

  module Types
    include Dry.Types()
  end

  option :state, type: Types::Hash, default: -> { {} }, render: :private

  def call(payload:)
    Try do
      if $atm.empty?
        $atm = payload[:caixa]
        @state = payload.merge(erros: [])
      elsif $atm[:caixaDisponivel] == true
        @state[:erros] = ["caixa-em-uso"]
        @state[:caixa] = $atm
      else
        $atm[:caixaDisponivel] = payload[:caixa][:caixaDisponivel]
        $atm[:notas] = payload[:caixa][:notas].merge($atm[:notas]) { |_, v1, v2| v1 + v2 }

        @state[:erros] = []
        @state[:caixa] = payload[:caixa]
      end

      @state
    end
  end
end
