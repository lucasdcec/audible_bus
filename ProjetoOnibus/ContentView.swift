//
//  ContentView.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
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
                
                VStack(spacing: 20) {
                    Button("Buscar paradas próximas") {
                        // Ação para buscar paradas
                    }
                    .accessibilityLabel("Buscar as 5 paradas mais próximas")
                    
                    Button("Paradas favoritas") {
                        // Ação para ver favoritas
                    }
                    .accessibilityLabel("Olhar as paradas favoritas do usuário")
                }
                .padding()
                
                
            }
        }
    }
}

#Preview {
    ContentView()
}
