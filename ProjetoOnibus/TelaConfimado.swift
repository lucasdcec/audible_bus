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
    @State var parada: Paradas = Paradas(id: 1, nome: "", distancia: 10, latitude: 0.0, longitude: 0.0)
    @State var mostrarMensagem: Bool = false
    @State var mensagemTexto: String = ""
    @State var quantidadeVezes: Int = 1
    @EnvironmentObject var gerenteDeFavoritos: GerenteDeFavoritos
    @Environment(\.dismiss) private var dismiss

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
                        Image("LogoDoApp")
                            .resizable()
                            .frame(width: 40, height: 40)
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
                    
                    Spacer()
                    
                    //Ícone de Favorito
                    Button(action: {
                        gerenteDeFavoritos.toggleFavorito(parada)
                        quantidadeVezes = quantidadeVezes + 1
                        
                        if gerenteDeFavoritos.isFavorito(parada) {
                            mensagemTexto = "adicionado aos favoritos"
                        } else {
                            mensagemTexto = "removido dos favoritos"
                        }
                        mostrarMensagem = true
                        
                        // Enviar POST para paradafavorita ao adicionar
                        if gerenteDeFavoritos.isFavorito(parada) {
                            enviarParadaFavorita()
                        } else {
                                // Ao remover, precisamos buscar o documento no servidor (pelo campo id)
                                // para recuperar o _id e _rev e apenas então executar o DELETE.
                                // Observação: se houver mais de um documento com o mesmo `id`,
                                // o backend costuma retornar um array; neste caso, a implementação
                                // busca apenas o primeiro registro e faz o DELETE desse único documento.
                            enviarDeleteFavorita()
                        }
                        
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            mostrarMensagem = false
                        }
                    }, label: {
                        VStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .padding()
                                .background(gerenteDeFavoritos.isFavorito(parada) ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            
                            if mostrarMensagem {
                                Text(mensagemTexto)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    })
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Botão favorito")
                    .accessibilityValue(gerenteDeFavoritos.isFavorito(parada) ? "Parada favorita" : "Não é favorita")
                    .accessibilityHint("Toque duas vezes para adicionar ou remover dos favoritos")
                    
                    Spacer()
                        .frame(height: 40)
                    
                    //Card das Informações
                    VStack(spacing: 16) {
                        Text("Confirmação recebida!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            Text("O próximo ônibus para:")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text(parada.nome)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("já foi alertado!")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text("Tempo aproximado de espera: 4 minutos")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Confirmação recebida! O próximo ônibus para a parada \(parada.nome) já foi alertado! Tempo aproximado de espera: 4 minutos")
                    
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
                    
                    //Botões de ação
                    HStack {
                    Button(action: { dismiss() }) {
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
                    else {
                        // Atualiza lista de favoritos (sincroniza com servidor)
                        gerenteDeFavoritos.carregarFavoritos()
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

    // MARK: - Envio de DELETE para parada favorita (usando _id/_rev do servidor)
    private func enviarDeleteFavorita() {
        guard !carregando else { return }
        carregando = true
        erroEnvio = nil

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Buscar documento do servidor usando o id da aplicação
                if let registro = try self.apiService.fetchParadaFavoritaByAppId(parada.id) {
                    print("[enviarDeleteFavorita] registro encontrado: _id=\(registro._id) _rev=\(registro._rev ?? "nil")")
                    guard let rev = registro._rev else {
                        DispatchQueue.main.async {
                            carregando = false
                            erroEnvio = "Registro sem _rev no servidor"
                        }
                        return
                    }

                    // Enviar delete com _id e _rev
                    let sucesso = try self.apiService.deleteParadaFavoritaDocument(registro._id, rev: rev)
                    print("[enviarDeleteFavorita] delete result: \(sucesso)")
                    DispatchQueue.main.async {
                        carregando = false
                        if !sucesso {
                            erroEnvio = "Falha ao remover parada favorita no servidor"
                        }
                        else {
                            gerenteDeFavoritos.carregarFavoritos()
                        }
                    }
                } else {
                    print("[enviarDeleteFavorita] nenhum registro encontrado para id=\(parada.id)")
                    // Registro não encontrado — considera sucesso ou apenas remove localmente
                    DispatchQueue.main.async {
                        carregando = false
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

    // Envia o POST para /paradafavorita
    private func enviarFavoritaRequest(parada: Paradas) throws -> Bool {
        guard let url = URL(string: "http://127.0.0.1:1880/paradafavorita") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // O body será o objeto parada serializado
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(parada)
        } catch {
            throw APIError.networkError(error)
        }
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Bool, APIError> = .failure(.invalidResponse)
        // debug
        if let body = request.httpBody, let str = String(data: body, encoding: .utf8) {
            print("[TelaConfimado] POST /paradafavorita body: \(str)")
        }

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
            // Aceitar qualquer status 2xx como sucesso (Node-RED costuma devolver 201 Created)
            if (200...299).contains(httpResponse.statusCode) {
                result = .success(true)
            } else {
                result = .failure(.httpError(statusCode: httpResponse.statusCode))
            }
            // Debug logs para identificar problemas
            if let requestBody = request.httpBody, let bodyString = String(data: requestBody, encoding: .utf8) {
                print("[enviarFavoritaRequest] request body: \(bodyString)")
            }
            if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                print("[enviarFavoritaRequest] response (status \(httpResponse.statusCode)): \(responseString)")
            } else {
                print("[enviarFavoritaRequest] response status: \(httpResponse.statusCode), no body")
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
