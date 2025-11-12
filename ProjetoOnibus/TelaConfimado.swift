//
//  TelaConfimado.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct TelaConfimado: View {
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
                NavigationLink(destination: TelaParadasProximas()) {
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
                Spacer()
            }
        }
    }
    }
}

#Preview {
    TelaConfimado()
}
