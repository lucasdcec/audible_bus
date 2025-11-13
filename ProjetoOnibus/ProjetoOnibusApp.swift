//
//  ProjetoOnibusApp.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//

import SwiftUI

@main
struct ProjetoOnibusApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GerenteDeFavoritos())
        }
    }
}
