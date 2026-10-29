## ⚙️ How to Run Locally

### 1. Preparing and Running the Backend (C#)

### Prerequisites

Before starting, make sure you have installed:

- **.NET 8 SDK**
- **MongoDB**
- **MinIO**
- **Docker** (optional)

All services must be running locally.

### Configuring the Environment Variables

Open the `appsettings.json` file inside the API project.

To make local testing easier, the file already points to `localhost`. Fill in your environment's data as needed:

```json
{
  "ConnectionStrings": {
    "MongoConnection": "mongodb://localhost:27017"
  },
  "DatabaseConfig": {
    "Name": "WTC-Chat"
  },
  "JwtSettings": {
    "Secret": "CHAVE_SUPER_SECRETA_PARA_TESTES_1234567890",
    "ExpirationMinutes": 120
  },
  "Minio": {
    "Endpoint": "localhost:9000",
    "AccessKey": "minioadmin",
    "SecretKey": "minioadmin",
    "BucketName": "wtc-media"
  }
}
```

### Restore Dependencies and Run

Open the terminal at the root of the backend project and run:

```bash
dotnet restore
dotnet run --project WtcCrm.API/WtcCrm.API.csproj
```

### API Swagger

By default, the API will start at:

```txt
http://localhost:5157
```

To view and test the endpoints, go to:

```txt
http://localhost:5157/swagger
```

---

## 📱 App Configuration (iOS)

The app consumes the backend through **REST APIs** and **SignalR (WebSocket)** for real-time communication.

The configuration is done in the file:

```swift
APIConfig.swift
```

### Scenario A: Testing on the Xcode Simulator

When testing on the Xcode simulator (same Mac running the API), use:

```swift
private static let host = "localhost"
```

### Scenario B: Testing on a Physical iPhone

When using a physical iPhone, replace `localhost` with the machine's local IPv4:

```swift
private static let host = "your IPv4"
```

Full example:

```swift
import Foundation

enum APIConfig {

    private static let host = "localhost"
    private static let port = "5157"

    private static let baseURLString =
        "http://\(host):\(port)"

    static let baseUrl =
        URL(string: "\(baseURLString)/api/")!

    static let signalRUrl =
        URL(string: "\(baseURLString)/chatHub")!
}
```

To run the project:

1. Open the project in **Xcode 15+**
2. Select the device/simulator
3. Run:

```txt
Cmd + R
```

The app will be built and run.

---
