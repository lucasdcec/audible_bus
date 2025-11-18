//
//  APIService.swift
//  ProjetoOnibus
//
//  Created by GitHub Copilot on 14/11/25.
//

import Foundation

// MARK: - Protocolo para injeção de dependência
protocol APIServiceProtocol {
    func enviarLocalizacaoParada(idStop: Int, latitude: Double, longitude: Double) throws -> Bool
    func fetchParadasFavoritas() throws -> [Paradas]
    func fetchParadaFavoritaByAppId(_ id: Int) throws -> ParadaFavoritaRecord?
    func deleteParadaFavoritaDocument(_ documentId: String, rev: String) throws -> Bool
}

// MARK: - Modelo de dados para requisição
struct ParadaLocalizacaoRequest: Codable {
    let idStop: Int
    let latitude: Double
    let longitude: Double
}

// Modelo que representa o documento armazenado no banco do servidor (Node-RED/CouchDB-like)
struct ParadaFavoritaRecord: Codable {
    let _id: String
    let _rev: String?
    let id: Int
    let nome: String
    let distancia: Int
    let latitude: Double
    let longitude: Double
}

// MARK: - Erros customizados
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
        case .invalidResponse:
            return "Resposta inválida do servidor"
        case .httpError(let statusCode):
            return "Erro HTTP: \(statusCode)"
        }
    }
}

// MARK: - Serviço de API
class APIService: APIServiceProtocol {
    // MARK: - Properties
    private let baseURL: String
    private let session: URLSession
    
    // MARK: - Initializer
    init(baseURL: String = "http://127.0.0.1:1880", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    // MARK: - Public Methods
    /// Envia a localização da parada para a API de forma síncrona
    /// - Parameters:
    ///   - idStop: ID da parada
    ///   - latitude: Latitude da parada
    ///   - longitude: Longitude da parada
    /// - Returns: true se a requisição foi bem-sucedida (200 OK)
    /// - Throws: APIError em caso de falha
    func enviarLocalizacaoParada(idStop: Int, latitude: Double, longitude: Double) throws -> Bool {
        // Validar e criar a URL
        guard let url = URL(string: "\(baseURL)/paradasolicitada") else {
            throw APIError.invalidURL
        }
        
        // Criar o request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Criar o body da requisição
        let requestBody = ParadaLocalizacaoRequest(idStop: idStop, latitude: latitude, longitude: longitude)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw APIError.networkError(error)
        }
        
        // Usar semaphore para tornar a requisição síncrona
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Bool, APIError> = .failure(.invalidResponse)
        
        let task = session.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            
            // Verificar erro de rede
            if let error = error {
                result = .failure(.networkError(error))
                return
            }
            
            // Verificar resposta HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                result = .failure(.invalidResponse)
                return
            }
            
            // Debug: log request body
            if let body = request.httpBody, let str = String(data: body, encoding: .utf8) {
                print("[APIService.enviarLocalizacaoParada] request body: \(str)")
            }
            // Verificar status code (aceitar qualquer 2xx como sucesso)
            if (200...299).contains(httpResponse.statusCode) {
                result = .success(true)
            } else {
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("APIService.enviarLocalizacaoParada -> HTTP status: \(httpResponse.statusCode) body: \(body)")
                } else {
                    print("APIService.enviarLocalizacaoParada -> HTTP status: \(httpResponse.statusCode) (no body)")
                }
                result = .failure(.httpError(statusCode: httpResponse.statusCode))
            }
        }
        
        task.resume()
        semaphore.wait()
        
        // Retornar o resultado
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }

    /// Busca as paradas favoritas no backend
    func fetchParadasFavoritas() throws -> [Paradas] {
        guard let url = URL(string: "\(baseURL)/paradasfavoritas") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<[Paradas], APIError> = .failure(.invalidResponse)

        let task = session.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }

            if let error = error {
                result = .failure(.networkError(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                result = .failure(.invalidResponse)
                return
            }

            
            if httpResponse.statusCode == 404 {
                // Sem registro encontrado — retornar lista vazia
                result = .success([])
                return
            }
            if httpResponse.statusCode == 404 {
                // Not found: return nil instead of throwing
                result = .success(nil)
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                result = .failure(.httpError(statusCode: httpResponse.statusCode))
                return
            }

            do {
                let decoder = JSONDecoder()
                let paradas = try decoder.decode([Paradas].self, from: data)
                result = .success(paradas)
            } catch {
                result = .failure(.networkError(error))
            }
        }

        task.resume()
        semaphore.wait()

        switch result {
        case .success(let paradas):
            return paradas
        case .failure(let error):
            throw error
        }
    }

    /// Busca uma parada favorita no backend usando o id da aplicação (campo id)
    ///
    /// Observação: o servidor pode retornar mais de um documento com o mesmo `id` (isso acontece com bancos NoSQL
    /// quando não há uma restrição de unicidade no campo). Essa função tenta decodificar primeiro um array e,
    /// caso existam múltiplos registros, retorna apenas o primeiro elemento encontrado. Isso é intencional —
    /// quando necessário apagar um único registro, removemos apenas a primeira ocorrência.
    func fetchParadaFavoritaByAppId(_ id: Int) throws -> ParadaFavoritaRecord? {
        guard let url = URL(string: "\(baseURL)/paradafavorita?id=\(id)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<ParadaFavoritaRecord?, APIError> = .failure(.invalidResponse)

        let task = session.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }

            if let error = error {
                result = .failure(.networkError(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                result = .failure(.invalidResponse)
                return
            }

            if httpResponse.statusCode == 404 {
                // Not found — return nil
                result = .success(nil)
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                // debug
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("APIService.fetchParadaFavoritaByAppId -> HTTP status: \(httpResponse.statusCode) body: \(body)")
                } else {
                    print("APIService.fetchParadaFavoritaByAppId -> HTTP status: \(httpResponse.statusCode) (no body)")
                }
                result = .failure(.httpError(statusCode: httpResponse.statusCode))
                return
            }

            // tentar decodificar array primeiro
            let decoder = JSONDecoder()
            do {
                if let array = try? decoder.decode([ParadaFavoritaRecord].self, from: data), let first = array.first {
                    result = .success(first)
                    return
                }
                let single = try decoder.decode(ParadaFavoritaRecord.self, from: data)
                result = .success(single)
            } catch {
                // tentar wrappers comuns (CouchDB-like) - { "docs": [ ... ] }
                do {
                    struct DocsWrapper: Codable { let docs: [ParadaFavoritaRecord] }
                    let docs = try decoder.decode(DocsWrapper.self, from: data)
                    result = .success(docs.docs.first)
                    return
                } catch {
                    // tentar o formato rows -> { "rows": [ {"doc": {...} } ] }
                    do {
                        struct Row: Codable { let doc: ParadaFavoritaRecord }
                        struct RowsWrapper: Codable { let rows: [Row] }
                        let rows = try decoder.decode(RowsWrapper.self, from: data)
                        result = .success(rows.rows.first?.doc)
                        return
                    } catch {
                        result = .failure(.networkError(error))
                    }
                }
            }
        }

        task.resume()
        semaphore.wait()

        switch result {
        case .success(let record):
            return record
        case .failure(let error):
            throw error
        }
    }

    /// Deleta o documento do backend usando o _id e _rev do banco
    func deleteParadaFavoritaDocument(_ documentId: String, rev: String) throws -> Bool {
        guard let url = URL(string: "\(baseURL)/paradafavorita/delete") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["_id": documentId, "_rev": rev]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            throw APIError.networkError(error)
        }

        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Bool, APIError> = .failure(.invalidResponse)

        let task = session.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if let error = error {
                result = .failure(.networkError(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                result = .failure(.invalidResponse)
                return
            }
            if (200...299).contains(httpResponse.statusCode) {
                result = .success(true)
            } else {
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("APIService.deleteParadaFavoritaDocument -> HTTP status: \(httpResponse.statusCode) body: \(body)")
                } else {
                    print("APIService.deleteParadaFavoritaDocument -> HTTP status: \(httpResponse.statusCode) (no body)")
                }
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
