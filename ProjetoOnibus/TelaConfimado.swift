//
//  ContentView.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//
//
//  TelaConfimado.swift
//  ProjetoOnibus
//

import SwiftUI

struct TelaConfimado: View {
    @State var parada: Paradas = Paradas(id: 1, nome: "", distancia: 10, latitude: 0, longitude: 0)
    @State var mostrarMensagem: Bool = false
    @State var mensagemTexto: String = ""
    @State var quantidadeVezes: Int = 1
    @EnvironmentObject var gerenteDeFavoritos: GerenteDeFavoritos
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    
                    // Header
                    HStack(spacing: 12) {
                        Image("LogoDoApp")
                            .resizable()
                            .frame(width: 40, height: 40)
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
                    
                    Spacer()
                    
                    //Ícone de Favorito
                    Button(action: {
                        gerenteDeFavoritos.toggleFavorito(parada)
                        quantidadeVezes = quantidadeVezes + 1
                        
                        if gerenteDeFavoritos.isFavorito(parada) {
                            mensagemTexto = "adicionado aos favoritos"
                        } else {
                            mensagemTexto = "removido dos favoritos"
                        }
                        mostrarMensagem = true
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            mostrarMensagem = false
                        }
                    }, label: {
                        VStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .padding()
                                .background(gerenteDeFavoritos.isFavorito(parada) ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            
                            if mostrarMensagem {
                                Text(mensagemTexto)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    })
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Botão favorito") //Label fixa
                    .accessibilityValue(gerenteDeFavoritos.isFavorito(parada) ? "Parada favorita" : "Não é favorita") //Resposta dinamica
                    .accessibilityHint("Toque duas vezes para adicionar ou remover dos favoritos") //Ação
                    
                    Spacer()
                        .frame(height: 40) //Espaçamento entre botão e card
                    
                    //Card das Informações
                    VStack(spacing: 16) {
                        Text("Confirmação recebida!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            Text("O próximo ônibus para:")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text(parada.nome)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("já foi alertado!")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text("Tempo aproximado de espera: x minutos")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Confirmação recebida! O próximo ônibus para a parada \(parada.nome) já foi alertado! Tempo aproximado de espera: x minutos")
                    
                    Spacer()
                    
                    //Botões de ação
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
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

#Preview {
    TelaConfimado()
        .environmentObject(GerenteDeFavoritos())
}
