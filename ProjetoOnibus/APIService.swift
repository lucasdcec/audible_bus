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
}

// MARK: - Modelo de dados para requisição
struct ParadaLocalizacaoRequest: Codable {
    let idStop: Int
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
            
            // Verificar status code
            if httpResponse.statusCode == 200 {
                result = .success(true)
            } else {
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

            guard httpResponse.statusCode == 200 else {
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
}
