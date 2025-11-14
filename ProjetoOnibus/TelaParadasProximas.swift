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
        Paradas(id: 1, nome: "Avenida Washington Soares - Passarela Unifor", distancia: 700, latitude: -3.7689661, longitude: -38.4827782),
        Paradas(id: 2, nome: "Avenida Washington Soares - Edson Queiroz - Unifor", distancia: 99, latitude: -3.7708599, longitude: -38.4819135),
        Paradas(id: 3, nome: "Avenida Valmir Pontes - NAMI", distancia: 66, latitude: -3.771173, longitude: -38.4810759)
    ]
    
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
                                NavigationLink(destination: TelaConfimado(parada: parada)) {
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
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("A parada \(parada.nome) está a \(parada.distancia) metros de você")
                            }
                        }
                        .padding(.horizontal, 20)
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
        }
    }
}

#Preview {
    TelaParadasProximas()
        .environmentObject(GerenteDeFavoritos())
}
