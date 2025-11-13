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
    @State var parada:Paradas = Paradas(id: 1, nome: "a", distancia: 10)
    @State var mostrarMensagem: Bool = false
    
    @State var mensagemTexto: String = ""
    @State var quantidadeVezes :Int = 1
    
    @EnvironmentObject var gerenteDeFavoritos: GerenteDeFavoritos
    
    var body: some View {
        
        NavigationStack{
        ZStack{
            VStack{
                
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
                Spacer()
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
                    if gerenteDeFavoritos.isFavorito(parada) {
                        HStack{
                            Image(systemName: "star.fill")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .accessibilityLabel("Parada adicionada aos favoritos")
                            if mostrarMensagem {
                                Text(mensagemTexto)
                            }
                        }
                    } else {
                        if quantidadeVezes == 1 {
                            HStack {
                                Image(systemName: "star.fill")
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .accessibilityLabel("Clique para adicionar ou remover dos favoritos")
                                if mostrarMensagem {
                                    Text(mensagemTexto)
                                }
                            }
                        } else {
                            HStack {
                                Image(systemName: "star.fill")
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .accessibilityLabel("Parada removida dos favoritos")
                                if mostrarMensagem {
                                    Text(mensagemTexto)
                                }
                            }
                        }
                    }
                })
                
                VStack {
                    Text("O próximo ônibus que irá para a parada: ")
                    Text("\(parada.nome) já foi alertado!")
                    Text("Tempo aproximado de espera:** x minutos**")
                }
                .accessibilityLabel("O próximo ônibus que irá para a parada: \(parada.nome) já foi alertado! Tempo aproximado de espera:** x minutos**")
                
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
