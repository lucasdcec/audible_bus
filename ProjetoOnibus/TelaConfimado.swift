//
//  TelaConfimado.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct TelaConfimado: View {
    @State var parada:Paradas = Paradas(id: 1, nome: "a", distancia: 10)
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
                VStack{
                    Text("O proximo ônibus que irá para a parada: ")
                    Text("\(parada.nome) já foi alertado!")
                    Text("Tempo aproximado de espera:** x minutos**")
                }
                .accessibilityLabel("O proximo ônibus que irá para a parada: \(parada.nome) já foi alertado! Tempo aproximado de espera:** x minutos**")
                
                
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
}
