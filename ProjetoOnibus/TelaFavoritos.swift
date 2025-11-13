//
//  TelaFavoritos.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct TelaFavoritos: View {
    @EnvironmentObject var gerenteDeFavoritos: GerenteDeFavoritos
    
    var body: some View {
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
                
                Text("Suas paradas favoritas!")
                    .font(.title).fontWeight(.bold)
                    .accessibilityLabel("Suas paradas favoritas")
                if gerenteDeFavoritos.paradasFavoritas.isEmpty {
                    VStack {
                        Image(systemName: "star.fill")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
//                    .frame(width: 40,height: 30)

                
                            .font(.title)
                        Text("Nenhuma parada favorita")
                            .accessibilityLabel("Nenhuma parada favorita por enquanto")
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
                            .accessibilityLabel("\(parada.nome). \(parada.distancia) metros")
                            Button(action: {
                                gerenteDeFavoritos.removerDosFavoritos(parada)
                            }, label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .accessibilityLabel("Clique aqui para remover dos favoritos")
                            })
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
