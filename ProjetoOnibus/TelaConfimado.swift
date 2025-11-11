//
//  TelaConfimado.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct TelaConfimado: View {
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
                Text("confirmado")
            }
        }
    }
}

#Preview {
    TelaConfimado()
}
