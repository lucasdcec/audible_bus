//
//  ContentView.swift
//  ProjetoOnibus
//
//  Created by Turma02-14 on 11/11/25.
//
//
//  TelaConfimado.swift
//  ProjetoOnibus
//

import SwiftUI

struct TelaConfimado: View {
    @State var parada: Paradas = Paradas(id: 1, nome: "a", distancia: 10, latitude: 0.0, longitude: 0.0)
    @State var mostrarMensagem: Bool = false
    @State var mensagemTexto: String = ""
    @State var quantidadeVezes: Int = 1
    @EnvironmentObject var gerenteDeFavoritos: GerenteDeFavoritos

    // Instância do serviço de API
    private let apiService: APIServiceProtocol = APIService()
    @State private var carregando: Bool = false
    @State private var erroEnvio: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
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
                    Spacer()
                    Button(action: {
                        gerenteDeFavoritos.toggleFavorito(parada)
                        quantidadeVezes = quantidadeVezes + 1
                        if gerenteDeFavoritos.isFavorito(parada) {
                            mensagemTexto = "adicionado aos favoritos"
                            // Enviar POST para paradafavorita ao adicionar
                            enviarParadaFavorita()
                        } else {
                            mensagemTexto = "removido dos favoritos"
                            // Enviar DELETE para paradafavorita/delete ao remover
                            enviarDeleteFavorita()
                        }
                        mostrarMensagem = true
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            mostrarMensagem = false
                        }
                    }, label: {
                        if gerenteDeFavoritos.isFavorito(parada) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .accessibilityLabel("Parada adicionada aos favoritos")
                                if mostrarMensagem {
                                    Text(mensagemTexto)
                                }
                            }
                        } else {
                            if quantidadeVezes == 1 {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .padding()
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .accessibilityLabel("Clique para adicionar ou remover dos favoritos")
                                    if mostrarMensagem {
                                        Text(mensagemTexto)
                                    }
                                }
                            } else {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .padding()
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .accessibilityLabel("Parada removida dos favoritos")
                                    if mostrarMensagem {
                                        Text(mensagemTexto)
                                    }
                                }
                            }
                        }
                    })
                    VStack {
                        Text("O próximo ônibus que irá para a parada: ")
                        Text("\(parada.nome) já foi alertado!")
                        Text("Tempo aproximado de espera:** x minutos**")
                    }
                    .accessibilityLabel("O próximo ônibus que irá para a parada: \(parada.nome) já foi alertado! Tempo aproximado de espera:** x minutos**")
                    // Mensagem de erro de envio
                    if let erroEnvio = erroEnvio {
                        Text("Erro ao enviar parada favorita: \(erroEnvio)")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
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
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    // MARK: - Envio de parada favorita
    private func enviarParadaFavorita() {
        guard !carregando else { return }
        carregando = true
        erroEnvio = nil
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Enviar POST para /paradafavorita
                let sucesso = try enviarFavoritaRequest(parada: parada)
                DispatchQueue.main.async {
                    carregando = false
                    if !sucesso {
                        erroEnvio = "Falha ao enviar parada favorita"
                    }
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    carregando = false
                    erroEnvio = error.localizedDescription
                }
            } catch {
                DispatchQueue.main.async {
                    carregando = false
                    erroEnvio = "Erro desconhecido: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Envio de DELETE parada favorita
    private func enviarDeleteFavorita() {
        guard !carregando else { return }
        carregando = true
        erroEnvio = nil
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let sucesso = try enviarDeleteRequest(id: parada.id)
                DispatchQueue.main.async {
                    carregando = false
                    if !sucesso {
                        erroEnvio = "Falha ao remover parada favorita"
                    }
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    carregando = false
                    erroEnvio = error.localizedDescription
                }
            } catch {
                DispatchQueue.main.async {
                    carregando = false
                    erroEnvio = "Erro desconhecido: \(error.localizedDescription)"
                }
            }
        }
    }

    // Envia o DELETE para /paradafavorita/delete
    private func enviarDeleteRequest(id: Int) throws -> Bool {
        guard let url = URL(string: "http://127.0.0.1:1880/paradafavorita/delete") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["id": id]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            throw APIError.networkError(error)
        }
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Bool, APIError> = .failure(.invalidResponse)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if let error = error {
                result = .failure(.networkError(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                result = .failure(.invalidResponse)
                return
            }
            if httpResponse.statusCode == 200 {
                result = .success(true)
            } else {
                result = .failure(.httpError(statusCode: httpResponse.statusCode))
            }
        }
        task.resume()
        semaphore.wait()
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }

    // Envia o POST para /paradafavorita
    private func enviarFavoritaRequest(parada: Paradas) throws -> Bool {
        guard let url = URL(string: "http://127.0.0.1:1880/paradafavorita") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // O body será o objeto parada serializado
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(parada)
        } catch {
            throw APIError.networkError(error)
        }
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Bool, APIError> = .failure(.invalidResponse)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if let error = error {
                result = .failure(.networkError(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                result = .failure(.invalidResponse)
                return
            }
            if httpResponse.statusCode == 200 {
                result = .success(true)
            } else {
                result = .failure(.httpError(statusCode: httpResponse.statusCode))
            }
        }
        task.resume()
        semaphore.wait()
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}

#Preview {
TelaConfimado()
    .environmentObject(GerenteDeFavoritos())
}
