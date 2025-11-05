# 📱 Projeto EVT Flutter

Este repositório contém o **projeto EVT**, que integra um backend em **Java (Spring Boot)** e um frontend desenvolvido em **Flutter** voltado exclusivamente para **aplicações Web**.  

---

## 🧩 Estrutura do Projeto

```plaintext
Projeto EVT Flutter/
│
├── pom.xml                  ← Projeto Java (Spring Boot)
├── src/                     ← Código-fonte do backend
├── target/                  ← Saída compilada do backend
│
└── evt_flutter/             ← Projeto Flutter (frontend)
    ├── lib/
    │   ├── main.dart                    ← Arquivo principal da aplicação Flutter
    │   ├── screens/
    │   │   └── cadastro_screens.dart    ← Tela de cadastro do usuário
    │   ├── services/
    │   │   └── cadastro_service.dart    ← Serviço responsável pela lógica de autenticação e cadastro
    │   └── utils/                       ← (opcional) Funções auxiliares e widgets personalizados
    ├── pubspec.yaml                     ← Configuração das dependências do Flutter
    └── web/                             ← Arquivos específicos para execução no navegador
```
---

## ⚙️ Instalação e Execução

Antes de iniciar o projeto, garanta que você possui o **Flutter SDK** instalado corretamente e que o ambiente está configurado para rodar aplicações web.

### 🔹 Instalar dependências
```bash
flutter pub get
```
### 🔹 Rodar o projeto Flutter no navegador
```bash
flutter run -d chrome
```
