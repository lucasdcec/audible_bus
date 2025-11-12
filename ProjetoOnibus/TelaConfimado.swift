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
                Text("confirmado")
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
    TelaConfimado()
}
