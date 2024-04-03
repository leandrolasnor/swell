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

      describe 'supply event' do
        before do
          File.write('inputs.json', JSON.pretty_generate(inputs))
          File.write('output.json', JSON.pretty_generate([]))
          `ruby atm.rb run`
        end

        context 'when atm is available for supply' do
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

        context 'when atm is busy for supply' do
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

          it 'must be able to get a output with caixa-em-uso error' do
            expect(output).to match(expected_output)
          end
        end
      end

      describe 'withdraw event' do
        before do
          File.write('inputs.json', JSON.pretty_generate(inputs))
          File.write('output.json', JSON.pretty_generate([]))
          `ruby atm.rb run`
        end

        context 'on success' do
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
                saque: {
                  valor: 80,
                  horario: "2019-02-13T11:01:01.000Z"
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
                    notasDez: 100,
                    notasVinte: 50,
                    notasCinquenta: 10,
                    notasCem: 30
                  }
                },
                erros: []
              },
              {
                caixa: {
                  caixaDisponivel: true,
                  notas: {
                    notasDez: 99,
                    notasVinte: 49,
                    notasCinquenta: 9,
                    notasCem: 30
                  }
                },
                erros: []
              }

            ]
          end

          it 'must be able to get a output without errors' do
            expect(output).to match(expected_output)
          end
        end

        context 'when Non-existent atm structure' do
          let(:inputs) do
            [
              {
                saque: {
                  valor: 80,
                  horario: "2019-02-13T11:01:01.000Z"
                }
              }
            ]
          end
          let(:expected_output) do
            [
              {
                caixa: {},
                erros: ['caixa-inexistente']
              }

            ]
          end

          it 'must be able to get a output with caixa-inexistente error' do
            expect(output).to match(expected_output)
          end
        end

        context 'when atm unavailable to carry out operations' do
          let(:inputs) do
            [
              {
                caixa: {
                  caixaDisponivel: false,
                  notas: {
                    notasDez: 0,
                    notasVinte: 0,
                    notasCinquenta: 1,
                    notasCem: 3
                  }
                }
              },
              {
                saque: {
                  valor: 600,
                  horario: "2019-02-13T11:01:01.000Z"
                }
              }
            ]
          end
          let(:expected_output) do
            [
              {
                caixa: {
                  caixaDisponivel: false,
                  notas: {
                    notasDez: 0,
                    notasVinte: 0,
                    notasCinquenta: 1,
                    notasCem: 3
                  }
                },
                erros: []
              },
              {
                caixa: {
                  caixaDisponivel: false,
                  notas: {
                    notasDez: 0,
                    notasVinte: 0,
                    notasCinquenta: 1,
                    notasCem: 3
                  }
                },
                erros: ["caixa-indisponivel"]
              }
            ]
          end

          it 'must be able to get a output with caixa-indisponivel error' do
            expect(output).to match(expected_output)
          end
        end

        context 'when withdrawal amount greater than the amount of money available' do
          let(:inputs) do
            [
              {
                caixa: {
                  caixaDisponivel: true,
                  notas: {
                    notasDez: 0,
                    notasVinte: 0,
                    notasCinquenta: 1,
                    notasCem: 3
                  }
                }
              },
              {
                saque: {
                  valor: 600,
                  horario: "2019-02-13T11:01:01.000Z"
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
                    notasDez: 0,
                    notasVinte: 0,
                    notasCinquenta: 1,
                    notasCem: 3
                  }
                },
                erros: []
              },
              {
                caixa: {
                  caixaDisponivel: true,
                  notas: {
                    notasDez: 0,
                    notasVinte: 0,
                    notasCinquenta: 1,
                    notasCem: 3
                  }
                },
                erros: ["valor-indisponivel"]
              }
            ]
          end

          it 'must be able to get a output with valor-indisponivel error' do
            expect(output).to match(expected_output)
          end
        end

        context 'when there is more than one successful withdrawal of the same amount in an interval of less than 10 minutes' do
          let(:inputs) do
            [
              {
                caixa: {
                  caixaDisponivel: true,
                  notas: {
                    notasDez: 10,
                    notasVinte: 0,
                    notasCinquenta: 2,
                    notasCem: 3
                  }
                }
              },
              {
                saque: {
                  valor: 60,
                  horario: "2019-02-13T11:01:01.000Z"
                }
              },
              {
                saque: {
                  valor: 60,
                  horario: "2019-02-13T11:09:01.000Z"
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
                    notasDez: 10,
                    notasVinte: 0,
                    notasCinquenta: 2,
                    notasCem: 3
                  }
                },
                erros: []
              },
              {
                caixa: {
                  caixaDisponivel: true,
                  notas: {
                    notasDez: 9,
                    notasVinte: 0,
                    notasCinquenta: 1,
                    notasCem: 3
                  }
                },
                erros: []
              },
              {
                caixa: {},
                erros: ["saque-duplicado"]
              }
            ]
          end

          it 'must be able to get a output with saque-duplicado error' do
            expect(output).to match(expected_output)
          end
        end
      end
    end
  end
end
