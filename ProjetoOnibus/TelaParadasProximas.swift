//
//  TelaParadasProximas.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct Paradas: Identifiable, Hashable {
    var id: Int
    var nome: String
    var distancia: Int
    var latitude: Double
    var longitude: Double
}

struct TelaParadasProximas: View {
    @State var paradas: [Paradas] = [
        Paradas(id: 1, nome: "53 - Avenida Washington Soares - Passarela Unifor", distancia: 700, latitude: -3.7689661, longitude: -38.4827782),
        Paradas(id: 2, nome: "53 - Avenida Washington Soares - Edson Queiroz - Unifor", distancia: 99, latitude: -3.7708599, longitude: -38.4819135),
        Paradas(id: 3, nome: "21 - Avenida Valmir Pontes - NAMI", distancia: 66, latitude: -3.771173, longitude: -38.4810759)
    ]
    
    // Estados para controlar navegação programática e feedback
    @State private var navegarParaConfirmacao: Bool = false
    @State private var paradaSelecionada: Paradas?
    @State private var mostrarErro: Bool = false
    @State private var mensagemErro: String = ""
    @State private var carregando: Bool = false
    
    // Instância do serviço de API
    private let apiService: APIServiceProtocol = APIService()
    
    var paradasOrdenadas: [Paradas] {
        paradas.sorted { $0.distancia < $1.distancia }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: "bus")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Audible")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("MyBus")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Audible MyBus")
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Título
                    Text("Selecione a parada em que você se encontra:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                        .accessibilityLabel("Selecione a parada em que você se encontra")
                    
                    // Lista de paradas
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(paradasOrdenadas) { parada in
                                Button(action: {
                                    selecionarParada(parada)
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(parada.nome)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.black)
                                        HStack {
                                            Image(systemName: "location.fill")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            Text("\(parada.distancia) metros")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                            
                                            // Indicador de carregamento
                                            if carregando && paradaSelecionada?.id == parada.id {
                                                ProgressView()
                                                    .padding(.leading, 8)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.7), lineWidth: 1)
                                            )
                                    )
                                }
                                .disabled(carregando)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("A parada \(parada.nome) está a \(parada.distancia) metros de você")
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Mensagem de erro
                    if mostrarErro {
                        Text(mensagemErro)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                            .accessibilityLabel("Erro: \(mensagemErro)")
                    }
                    
                    Spacer()
                    
                    // Botões de ação
                    HStack {
                        NavigationLink(destination: ContentView()) {
                            HStack {
                                Image(systemName: "arrowshape.left.fill")
                                Text("Voltar")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .accessibilityLabel("Voltar para a página inicial")
                        
                        Spacer()
                        
                        Button(action: {
                            // Ação para atualizar paradas
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Atualizar")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .accessibilityLabel("Atualizar lista de paradas")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $navegarParaConfirmacao) {
                if let parada = paradaSelecionada {
                    TelaConfimado(parada: parada)
                }
            }
        }
    }
    
    // MARK: - Métodos privados
    
    /// Seleciona uma parada e envia sua localização para a API
    private func selecionarParada(_ parada: Paradas) {
        // Evitar múltiplas chamadas simultâneas
        guard !carregando else { return }
        
        paradaSelecionada = parada
        carregando = true
        mostrarErro = false
        
        // Executar em background para não bloquear a UI
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Chamar o serviço de API de forma síncrona
                let sucesso = try apiService.enviarLocalizacaoParada(
                    idStop: parada.id,
                    latitude: parada.latitude,
                    longitude: parada.longitude
                )
                
                // Atualizar UI na thread principal
                DispatchQueue.main.async {
                    carregando = false
                    
                    if sucesso {
                        // Navegação bem-sucedida
                        navegarParaConfirmacao = true
                    } else {
                        mostrarErro(mensagem: "Falha ao enviar localização")
                    }
                }
            } catch let error as APIError {
                // Tratar erros da API
                DispatchQueue.main.async {
                    carregando = false
                    mostrarErro(mensagem: error.localizedDescription)
                }
            } catch {
                // Tratar erros genéricos
                DispatchQueue.main.async {
                    carregando = false
                    mostrarErro(mensagem: "Erro desconhecido: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Mostra mensagem de erro e a esconde após 3 segundos
    private func mostrarErro(mensagem: String) {
        mensagemErro = mensagem
        mostrarErro = true
        
        // Esconder erro após 3 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            mostrarErro = false
        }
    }
}

#Preview {
    TelaParadasProximas()
        .environmentObject(GerenteDeFavoritos())
}
