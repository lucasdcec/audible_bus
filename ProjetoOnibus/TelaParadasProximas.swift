//
//  TelaParadasProximas.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct TelaParadasProximas: View {
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
                VStack {
                    Text("nome da parada")
                    Text("distancia da parada para o usuario em metros")
                }
                .foregroundColor(.black)
                .padding()
                .background(
                    Rectangle()
                        .fill(Color.gray.opacity(0.5)) // Interior cinza
                        .border(Color.black, width: 2) // Borda preta
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("nome da parada, distancia da parada para o usuario em metros")
                
                NavigationLink(destination: ContentView()) {
                    Image(systemName: "arrowshape.left.fill")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }.accessibilityLabel("Voltar para a página paradas próximas")
                
                Image(systemName: "arrow.clockwise")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
    }
    }

}

#Preview {
    TelaParadasProximas()
}
