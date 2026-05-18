## ⚙️ Como Executar Localmente

### 1. Preparando e Rodando o Backend (C#)

### Pré-requisitos

Antes de iniciar, certifique-se de ter instalado:

- **.NET 8 SDK**
- **MongoDB**
- **MinIO**
- **Docker** (opcional)

Todos os serviços devem estar rodando localmente.

### Configurando as Variáveis de Ambiente

Abra o arquivo `appsettings.json` dentro do projeto da API.

Para facilitar os testes locais, o arquivo já está apontando para `localhost`. Preencha os dados do seu ambiente conforme necessário:

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

### Restaurar Dependências e Executar

Abra o terminal na raiz do projeto backend e execute:

```bash
dotnet restore
dotnet run --project WtcCrm.API/WtcCrm.API.csproj
```

### Swagger da API

A API iniciará por padrão em:

```txt
http://localhost:5157
```

Para visualizar e testar os endpoints, acesse:

```txt
http://localhost:5157/swagger
```

---

## 📱 Configuração do Aplicativo (iOS)

O aplicativo consome o backend através de **REST APIs** e **SignalR (WebSocket)** para comunicação em tempo real.

A configuração é feita no arquivo:

```swift
APIConfig.swift
```

### Cenário A: Testando no Simulador do Xcode

Ao testar no simulador do Xcode (mesmo Mac que executa a API), utilize:

```swift
private static let host = "localhost"
```

### Cenário B: Testando em iPhone Físico

Ao utilizar um iPhone físico, substitua `localhost` pelo IPv4 local da máquina:

```swift
private static let host = "seu IPv4"
```

Exemplo completo:

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

Para executar o projeto:

1. Abra o projeto no **Xcode 15+**
2. Selecione o dispositivo/simulador
3. Execute:

```txt
Cmd + R
```

O aplicativo será compilado e executado.

---
