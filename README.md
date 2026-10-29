# 🚀 WtcChat - Smart Management with integrated chat

This app was developed for a capstone project/challenge (**Challenge**) in my undergraduate program, in partnership with the **World Trade Center (WTC)**.

The proposed challenge was to create a functional **CRM platform integrated with a mobile app**, focused on modernizing the company's communication and relationship with its clients.

The proposal addresses the need to offer a support experience similar to modern messaging apps, but **100% integrated into WTC's corporate context**, supporting campaign broadcasts, segmentation and metrics.

---

## 📋 Project Requirements and Features

Based on the challenge specifications, the solution includes a **Native App (iOS)** and a **Robust Backend**, covering the following features:

- **🔐 Secure Authentication:** Login adapted for Operators (CRM) and Clients.
- **💬 Integrated Chat (Real Time):** 1:1 and group/segment conversations, using WebSockets for instant communication and read status.
- **📊 360° View in the CRM (App):** Client list with search, smart filters, management of **Score**, **Status**, tags and recording of notes/tasks.
- **📢 Express Campaigns:** Module for immediately sending rich messages (with images and deeplinks) to specific client segments.
- **📂 Media Upload:** Integration with Storage (**S3 Compatible**) for sending profile photos, group covers and chat media.
- **🛡️ Governance:** Logging and auditing of critical API actions.

---

## 🛠️ Technologies Used

The solution was designed using **Clean Architecture**, separating the **Domain**, **Application** and **Infrastructure** layers, ensuring scalability, maintainability and code organization.

<div align="center">
  <table>
    <tr>
      <td align="center" width="50%">
        <h3><strong>👨‍💻 Languages & Front-end</strong></h3>
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
        <h3><strong>🚀 Infrastructure & Security</strong></h3>
        <img src="https://img.shields.io/badge/Docker-0DB7ED?style=for-the-badge&logo=docker&logoColor=white"/>
        <img src="https://img.shields.io/badge/JWT-black?style=for-the-badge&logo=jsonwebtokens"/>
      </td>
    </tr>
  </table>
  <br>
</div>

---

## 🏛️ Project Architecture

The project follows **Clean Architecture** principles, organizing responsibilities into independent layers:

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

This structure ensures:

- ✅ **Low coupling**
- ✅ **High scalability**
- ✅ **Ease of maintenance**
- ✅ **Clear separation of responsibilities**

---

## 🎯 Project Goal

**WtcCrm** was developed with the goal of modernizing communication between the company and its clients, bringing an experience similar to modern messaging apps, but fully integrated into **WTC**'s corporate ecosystem, enabling:

- Real-time support
- Smart relationship management
- Segmented campaigns
- Engagement metrics
- Corporate auditing and governance

## ✅ Challenge Requirements Met

| Requirement | Status |
|-----------|--------|
| Native iOS app | ✅ |
| .NET 8 backend | ✅ |
| JWT Authentication | ✅ |
| Mobile + Real API integration | ✅ |
| NoSQL database (MongoDB) | ✅ |
| Real-Time Chat | ✅ |
| SignalR / WebSocket | ✅ |
| Media Upload (MinIO) | ✅ |
| Governance & Auditing | ✅ |
| Functional REST APIs | ✅ |
| Swagger | ✅ |
| Clean Architecture | ✅ |
