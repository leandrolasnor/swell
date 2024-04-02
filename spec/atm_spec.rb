# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe 'ATM' do
  describe 'commands' do
    describe 'run' do
      let(:output) do
        output = []
        File.open('output.json', 'r') do |file|
          output = JSON.parse(file.read, symbolize_names: true)
        end
        output
      end

      context 'when atm is available' do
        let(:inputs) do
          [
            {
              caixa: {
                caixaDisponivel: false,
                notas: {
                  notasDez: 100,
                  notasVinte: 50,
                  notasCinquenta: 10,
                  notasCem: 30
                }
              }
            },
            {
              caixa: {
                caixaDisponivel: false,
                notas: {
                  notasDez: 350,
                  notasVinte: 1500,
                  notasCinquenta: 2500,
                  notasCem: 100
                }
              }
            },
            {
              caixa: {
                caixaDisponivel: false,
                notas: {
                  notasDez: 50,
                  notasVinte: 150,
                  notasCinquenta: 20,
                  notasCem: 15
                }
              }
            }
          ]
        end
        let(:expected_output) do
          [
            {
              erros: [],
              caixa: {
                caixaDisponivel: false,
                notas: {
                  notasDez: 100,
                  notasVinte: 50,
                  notasCinquenta: 10,
                  notasCem: 30
                }
              }
            },
            {
              erros: [],
              caixa: {
                caixaDisponivel: false,
                notas: {
                  notasDez: 350,
                  notasVinte: 1500,
                  notasCinquenta: 2500,
                  notasCem: 100
                }
              }
            },
            {
              erros: [],
              caixa: {
                caixaDisponivel: false,
                notas: {
                  notasDez: 50,
                  notasVinte: 150,
                  notasCinquenta: 20,
                  notasCem: 15
                }
              }
            }
          ]
        end

        before do
          File.write('inputs.json', JSON.pretty_generate(inputs))
          File.write('output.json', JSON.pretty_generate([]))
          `ruby atm.rb run`
        end

        it 'must be able to get a output without error' do
          expect(output).to match(expected_output)
        end
      end

      context 'when atm is busy' do
        let(:inputs) do
          [
            {
              caixa: {
                caixaDisponivel: true,
                notas: {
                  notasDez: 100,
                  notasVinte: 50,
                  notasCinquenta: 10,
                  notasCem: 30
                }
              }
            },
            {
              caixa: {
                caixaDisponivel: true,
                notas: {
                  notasDez: 350,
                  notasVinte: 1500,
                  notasCinquenta: 2500,
                  notasCem: 100
                }
              }
            }
          ]
        end
        let(:expected_output) do
          [
            {
              caixa: {
                caixaDisponivel: true,
                notas: {
                  notasCem: 30,
                  notasCinquenta: 10,
                  notasDez: 100,
                  notasVinte: 50
                }
              },
              erros: []
            },
            {
              caixa: {
                caixaDisponivel: true,
                notas: {
                  notasCem: 30,
                  notasCinquenta: 10,
                  notasDez: 100,
                  notasVinte: 50
                }
              },
              erros: ["caixa-em-uso"]
            }
          ]
        end

        before do
          File.write('inputs.json', JSON.pretty_generate(inputs))
          File.write('output.json', JSON.pretty_generate([]))
          `ruby atm.rb run`
        end

        it 'must be able to get a output with caixa-em-uso error' do
          expect(output).to match(expected_output)
        end
      end
    end
  end
end
