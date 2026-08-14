# Networking — Style Guide

This project implements a custom, lightweight Networking layer based on `URLSession` and Swift 6 Concurrency (`async/await` and `AsyncStream`). It strictly separates the definition of an endpoint from the execution and decoding of requests.

## 🏗 Architecture

The Networking layer (located in `Networking/`) is divided into three primary components:

1. **`APIRouter`**: A protocol defining the contract for an HTTP endpoint.
2. **`APIRequestDispatcher`**: The engine that builds the `URLRequest` and performs the actual network transfer.
3. **`APIClient`**: A high-level facade that uses the dispatcher to execute requests and decodes JSON responses directly into Domain Models/DTOs.

## 🚦 Defining Endpoints (`APIRouter`)

To define a new endpoint, create an enum that conforms to `APIRouter`.

```swift
enum PlacesAPI: APIRouter {
    case getNearbyPlaces(lat: Double, lng: Double)
    case getPlaceDetails(id: String)
    
    var baseURL: URL { URL(string: "https://api.example.com/v1")! }
    
    var path: String {
        switch self {
        case .getNearbyPlaces: return "/places/nearby"
        case .getPlaceDetails(let id): return "/places/\(id)"
        }
    }
    
    var method: HTTPMethod { .get }
    
    var queryParameters: [String: Any]? {
        switch self {
        case .getNearbyPlaces(let lat, let lng):
            return ["lat": lat, "lng": lng]
        default: return nil
        }
    }
    
    // Define authorization requirements
    var authorizationType: AuthorizationType {
        return .bearer // Will automatically inject Token via AuthTokenProviding
    }
}
```

## 🚀 Dispatcher and Client

### `APIRequestDispatching`
Responsible purely for data transfer. It offers two main methods:
- `perform(_ route:) -> Result<APIResponse, NetworkError>`: One-shot HTTP requests returning raw data.
- `stream(_ route:) -> Result<AsyncStream<T>, NetworkError>`: Server-Sent Events (SSE) returning a continuous stream of decoded models.

### `APIClient`
This is what Gateways/Repositories interact with. It abstracts away `APIResponse` and returns strictly typed Decodable DTOs.

```swift
// Example inside a Repository/Gateway Implementation
struct DefaultPlacesRepository: PlacesRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = DependencyContainer.shared.resolve()) {
        self.apiClient = apiClient
    }
    
    func fetchNearbyPlaces() async throws -> [Place] {
        let route = PlacesAPI.getNearbyPlaces(lat: 10.0, lng: -20.0)
        let result: Result<PlacesResponseDTO, NetworkError> = await apiClient.request(route)
        
        switch result {
        case .success(let dto):
            return dto.places.map { $0.toDomain() }
        case .failure(let error):
            throw error
        }
    }
}
```

## 🔐 Authentication & Tokens

The `APIRequestDispatcher` depends on `AuthTokenProviding` to automatically inject authentication headers (like Bearer tokens) into requests that declare an `authorizationType` other than `.none`.

- **Where to store tokens:** Tokens must be stored securely (e.g., using Keychain Services).
- **How it works:** When `APIRequestBuilder` constructs the `URLRequest`, it asks the `AuthTokenProviding` instance for a token matching the route's `authorizationType`.

## 🔄 Server-Sent Events (SSE)

The `stream<T>` method in `APIClient` provides native support for SSE. It buffers the HTTP stream, splits chunks by `\n\n`, extracts `data:` lines, and decodes them into the specified Decodable type, yielding them asynchronously.

```swift
func streamLocationUpdates() async {
    let result: Result<AsyncStream<LocationUpdateDTO>, NetworkError> = await apiClient.stream(LocationAPI.liveTracking)
    
    guard case .success(let stream) = result else { return }
    
    for await update in stream {
        print("Received new location: \(update)")
    }
}
```

---
**See also:**
- [Main Style Guide Index](STYLEGUIDE.md)
