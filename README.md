# 🚀 WtcChat - Gestão Inteligente com chat integrado

Este aplicativo foi desenvolvido para um trabalho de conclusão/desafio (**Challenge**) da minha graduação, em parceria com o **World Trade Center (WTC)**.

O desafio proposto foi criar uma plataforma funcional de **CRM integrada a um aplicativo móvel**, focada em modernizar a comunicação e o relacionamento da empresa com seus clientes.

A proposta resolve a necessidade de oferecer uma experiência de atendimento semelhante aos aplicativos de mensagens modernos, mas **100% integrada ao contexto corporativo do WTC**, suportando disparos de campanhas, segmentações e métricas.

---

## 📋 Requisitos e Funcionalidades do Projeto

Com base nas especificações do desafio, a solução engloba um **Aplicativo Nativo (iOS)** e um **Backend Robusto**, cobrindo as seguintes funcionalidades:

- **🔐 Autenticação Segura:** Login adaptado para Operadores (CRM) e Clientes.
- **💬 Chat Integrado (Tempo Real):** Conversas 1:1 e por grupos/segmentos, utilizando WebSockets para comunicação instantânea e status de leitura.
- **📊 Visão 360° no CRM (App):** Lista de clientes com busca, filtros inteligentes, gestão de **Score**, **Status**, tags e registro de anotações/tarefas.
- **📢 Campanhas Express:** Módulo para envio imediato de mensagens ricas (com imagens e deeplinks) para segmentos específicos de clientes.
- **📂 Upload de Mídias:** Integração com Storage (**S3 Compatible**) para envio de fotos de perfil, capas de grupo e mídias no chat.
- **🛡️ Governança:** Registros de logs e auditoria de ações críticas da API.

---

## 🛠️ Tecnologias Utilizadas

A solução foi desenhada utilizando **Clean Architecture**, separando as camadas de **Domínio**, **Aplicação** e **Infraestrutura**, garantindo escalabilidade, manutenção e organização do código.

<div align="center">
  <table>
    <tr>
      <td align="center" width="50%">
        <h3><strong>👨‍💻 Linguagens & Front-end</strong></h3>
        <img src="https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white"/>
        <img src="https://img.shields.io/badge/SwiftUI-000000?style=for-the-badge&logo=swift&logoColor=blue"/>
      </td>
      <td align="center" width="50%">
        <h3><strong>⚙️ Backend & Frameworks</strong></h3>
        <img src="https://img.shields.io/badge/C%23-239120?style=for-the-badge&logo=c-sharp&logoColor=white"/>
        <img src="https://img.shields.io/badge/.NET_8-5C2D91?style=for-the-badge&logo=.net&logoColor=white"/>
        <img src="https://img.shields.io/badge/ASP.NET-512BD4?style=for-the-badge&logo=.net&logoColor=white"/>
        <img src="https://img.shields.io/badge/SignalR-512BD4?style=for-the-badge&logo=.net&logoColor=white"/>
        <img src="https://img.shields.io/badge/EF_Core-512BD4?style=for-the-badge&logo=.net&logoColor=white"/>
      </td>
    </tr>
    <tr>
      <td align="center" width="50%">
        <h3><strong>🗄️ Database & Storage</strong></h3>
        <img src="https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white"/>
        <img src="https://img.shields.io/badge/MinIO-C7202C?style=for-the-badge&logo=minio&logoColor=white"/>
      </td>
      <td align="center" width="50%">
        <h3><strong>🚀 Infraestrutura & Segurança</strong></h3>
        <img src="https://img.shields.io/badge/Docker-0DB7ED?style=for-the-badge&logo=docker&logoColor=white"/>
        <img src="https://img.shields.io/badge/JWT-black?style=for-the-badge&logo=jsonwebtokens"/>
      </td>
    </tr>
  </table>
  <br>
</div>

---

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

## 🏛️ Arquitetura do Projeto

O projeto segue os princípios de **Clean Architecture**, organizando responsabilidades em camadas independentes:

```txt
WtcCrm
├── Domain
│   ├── Entities
│   ├── Interfaces
│   └── Rules
│
├── Application
│   ├── UseCases
│   ├── DTOs
│   └── Services
│
├── Infrastructure
│   ├── MongoDB
│   ├── MinIO
│   ├── SignalR
│   └── Authentication
│
└── API
    ├── Controllers
    ├── Middleware
    └── Swagger
```

Essa estrutura garante:

- ✅ **Baixo acoplamento**
- ✅ **Alta escalabilidade**
- ✅ **Facilidade de manutenção**
- ✅ **Separação clara de responsabilidades**

---

## 🎯 Objetivo do Projeto

O **WtcCrm** foi desenvolvido com o objetivo de modernizar a comunicação entre empresa e clientes, trazendo uma experiência semelhante aos aplicativos modernos de mensagens, mas totalmente integrada ao ecossistema corporativo do **WTC**, permitindo:

- Atendimento em tempo real
- Gestão inteligente de relacionamento
- Campanhas segmentadas
- Métricas de engajamento
- Auditoria e governança corporativa

## ✅ Requisitos do Challenge Atendidos

| Requisito | Status |
|-----------|--------|
| Aplicativo nativo iOS | ✅ |
| Backend .NET 8 | ✅ |
| JWT Authentication | ✅ |
| Integração Mobile + API Real | ✅ |
| Banco NoSQL (MongoDB) | ✅ |
| Chat em Tempo Real | ✅ |
| SignalR / WebSocket | ✅ |
| Upload de Mídia (MinIO) | ✅ |
| Governança & Auditoria | ✅ |
| APIs REST Funcionais | ✅ |
| Swagger | ✅ |
| Clean Architecture | ✅ |