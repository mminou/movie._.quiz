import UIKit

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    private func decode(_ data: Data) -> Result<MostPopularMovies, Error> {
        do {
            let movie = try JSONDecoder().decode(MostPopularMovies.self, from: data)
            return .success(movie)
            
        } catch {
            return .failure(error)
        }
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        networkClient.fetch(url: mostPopularMoviesUrl, handler: {result in
            switch result {
            case .success(let data):
                handler(decode(data))
            case .failure(let error):
                handler(.failure(error))
            }
        })
    }
}
