//
//  TelaFavoritos.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct TelaFavoritos: View {
    @EnvironmentObject var gerenteDeFavoritos: GerenteDeFavoritos
        @State private var carregando: Bool = false
    
    var body: some View {
        ZStack{
            VStack{
                //Header
                HStack(spacing: 12) {
                    Image("LogoDoApp")
                        .resizable()
                        .frame(width: 40,height: 40)
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
                
                //Listagem das paradas favoritas
                Text("Suas paradas favoritas!")
                    .font(.title).fontWeight(.bold)
                    .accessibilityLabel("Suas paradas favoritas")
                    .onAppear {
                        carregando = true
                        gerenteDeFavoritos.carregarFavoritos()
                        // Pequeno delay para simular carregamento e permitir atualização
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            carregando = false
                        }
                    }
                if carregando {
                    // Mostrar indicador enquanto carrega
                    ProgressView("Carregando...")
                        .padding()
                } else if gerenteDeFavoritos.paradasFavoritas.isEmpty {
                    // Mostrar mensagem de nenhuma parada favorita uma única vez
                    List {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Nenhuma parada favorita")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("Adicione paradas para vê-las aqui")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Nenhuma parada favorita. Adicione paradas para vê-las aqui")
                    }
                } else {
                    List(gerenteDeFavoritos.paradasFavoritas) { parada in
                        HStack{
                            VStack(alignment: .leading) {
                                Text(parada.nome)
                                Text("\(parada.distancia) metros")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            Button(action: {
                                gerenteDeFavoritos.removerDosFavoritos(parada)
                            }, label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            })
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(parada.nome). \(parada.distancia) metros. Botão remover")
                        .accessibilityAction(named: "Remover dos favoritos") { 
                            gerenteDeFavoritos.removerDosFavoritos(parada)
                        }
                    }
                }
                
            }
        }
    }
}

#Preview {
    TelaFavoritos()
        .environmentObject(GerenteDeFavoritos())
}
