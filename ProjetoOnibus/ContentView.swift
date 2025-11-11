//
//  ContentView.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    
                    HStack{
                        Image(systemName: "bus")
                            .frame(width: 20,height: 20)
                            .accessibilityHidden(true)
                        VStack{
                            Text("Audible")
                            Text("MyBus")
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Audible MyBus")
                    Spacer()
                    VStack(spacing: 20) {
                        // BOTÃO 1 - Paradas Próximas
                        NavigationLink(destination: TelaParadasProximas()) {
                            Text("Buscar paradas próximas")
                                .frame(maxWidth: .infinity,minHeight: 30)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .accessibilityLabel("Buscar as 5 paradas mais próximas")
                        
                        // BOTÃO 2 - Favoritas
                        NavigationLink(destination: TelaFavoritos()) {
                            Text("Paradas favoritas")
                                .frame(maxWidth: .infinity,minHeight: 30)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .accessibilityLabel("Olhar as paradas favoritas do usuário")
                    }
                    .padding()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
