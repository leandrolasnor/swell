# frozen_string_literal: true

class SupplyReducer
  include Dry::Monads[:try, :result]
  extend Dry::Initializer

  module Types
    include Dry.Types()
  end

  option :payload, type: Types::Hash, reader: :private
  option :state, type: Types::Hash, default: -> { {} }, render: :private

  def call
    res = Try do
      if $caixa.empty?
        $caixa = payload
        @state = payload.merge(erros: [])
      elsif $caixa[:caixaDisponivel] == true
        @state[:erros] = ["caixa-em-uso"]
        @state[:caixa] = $caixa
      else
        $caixa[:caixaDisponivel] = payload[:caixa][:caixaDisponivel]
        $caixa[:notas] = stocked

        @state[:erros] = []
        @state[:caixa] = payload[:caixa]
      end
      @state
    end

    $state << res.value! if res.success?
    $state << { exception: res.exception.message } if res.failure?
    $state
  end

  private

  def stocked
    @stocked ||= payload[:caixa][:notas].merge($caixa[:notas]) { |_, v1, v2| v1 + v2 }
  end
end
