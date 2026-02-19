GitHub Repositories iOS App
An iOS application that allows users to search and browse GitHub repositories using the GitHub public API.
The project is built using Clean Architecture principles, with clear separation of Data, Domain, and Presentation layers to ensure scalability, testability, and maintainability.


Features: - 
- Search GitHub repositories
- Display repository list
- Navigate to repository detail screen
- Error handling with banner display
- In-memory caching
- Clean architecture separation
- Unit test targets included


Architecture Overview: - 
This project follows a Clean Architecture approach with layered separation:

Layer Breakdown: -
Presentation Layer:
- SwiftUI Views
- ViewModels
- Router

Domain Layer:
- Business logic
- Use cases
- Repository protocols
- Domain models

Data Layer"
- API service
- DTO models
- Repository implementation
- Cache mechanism
- Utility classes


Data Flow: -
- User searches from UI
- ViewModel calls UseCase
- UseCase calls Repository (protocol)
- Repository Implementation calls APIService
- Response mapped from DTO → Domain Model
- Data returned to ViewModel
- UI updates via published state
