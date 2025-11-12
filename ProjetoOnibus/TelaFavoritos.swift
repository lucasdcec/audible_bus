//
//  TelaFavoritos.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct TelaFavoritos: View {
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
                
                Text("Suas ultimas paradas!")
                Image(systemName: "star.fill")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
//                    .frame(width: 40,height: 30)

                
                    .font(.title)
                
            }
        }
    }
}

#Preview {
    TelaFavoritos()
}
