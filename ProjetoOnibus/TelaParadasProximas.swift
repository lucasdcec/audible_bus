//
//  TelaParadasProximas.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct TelaParadasProximas: View {
    var body: some View {
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
    }
}

#Preview {
    TelaParadasProximas()
}
