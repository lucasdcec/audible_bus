//
//  ContentView.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gerenteDeFavoritos: GerenteDeFavoritos
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    //Header
                    HStack(spacing: 12) {
                        Image("LogoDoApp")
                            .resizable()
                            .frame(width: 40,height: 40)
//                            .font(.title2)
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
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    
                    Spacer()
                    
                    //Botões principais
                    VStack(spacing: 24) {
                        //Paradas Próximas
                        NavigationLink(destination: TelaParadasProximas()) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .font(.title3)
                                Text("Buscar onibus e paradas próximas")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding(.horizontal, 20)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
<<<<<<< HEAD
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Buscar paradas próximas")
=======
                        .accessibilityLabel("Buscar onibus e paradas próximas")
>>>>>>> f90548f203b01a64945758b4e938da452be61dac
                        
                        //Favoritas
                        NavigationLink(destination: TelaFavoritos()) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.title3)
                                Text("Rotas favoritas")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding(.horizontal, 20)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
<<<<<<< HEAD
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Paradas favoritas")
=======
                        .accessibilityLabel("Olhar as rotas favoritas do usuário")
>>>>>>> f90548f203b01a64945758b4e938da452be61dac
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
  
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GerenteDeFavoritos())
}
