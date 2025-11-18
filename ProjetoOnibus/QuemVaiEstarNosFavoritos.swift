//
//  QuemVaiEstarNosFavoritos.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 13/11/25.
//

import SwiftUI

class GerenteDeFavoritos: ObservableObject {
    @Published var paradasFavoritas: [Paradas] = []
    private let apiService: APIServiceProtocol = APIService()
    
    func adicionarAosFavoritos(_ parada: Paradas) {
        if !paradasFavoritas.contains(where: { $0.id == parada.id }) {
            paradasFavoritas.append(parada)
            print("Parada adicionada aos favoritos: \(parada.nome). Total: \(paradasFavoritas.count)")
        }
    }
    
    func removerDosFavoritos(_ parada: Paradas) {
        if let index = paradasFavoritas.firstIndex(where: { $0.id == parada.id }) {
            paradasFavoritas.remove(at: index)
            print("Parada removida dos favoritos: \(parada.nome). Total: \(paradasFavoritas.count)")
        }
    }
    
    func isFavorito(_ parada: Paradas) -> Bool {
        return paradasFavoritas.contains(where: { $0.id == parada.id })
    }
    
    func toggleFavorito(_ parada: Paradas) {
        if isFavorito(parada) {
            removerDosFavoritos(parada)
        } else {
            adicionarAosFavoritos(parada)
        }
    }
    
    func quantidadeDeFavoritos() -> Int {
        return paradasFavoritas.count
    }

    /// Carrega as paradas favoritas do backend e atualiza o array local
    func carregarFavoritos() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let paradas = try self.apiService.fetchParadasFavoritas()
                DispatchQueue.main.async {
                    self.paradasFavoritas = paradas
                }
            } catch {
                print("Erro ao carregar paradas favoritas: \(error.localizedDescription)")
            }
        }
    }
}
