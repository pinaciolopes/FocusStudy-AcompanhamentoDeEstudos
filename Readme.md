# 🎓 FocusStudy

![Status](https://img.shields.io/badge/status-development-blue)
![Backend](https://img.shields.io/badge/backend-Django%20Ninja-green)
![Frontend](https://img.shields.io/badge/frontend-React%20%7C%20Next.js-blue)
![Mobile](https://img.shields.io/badge/mobile-Flutter-cyan)
![Database](https://img.shields.io/badge/database-PostgreSQL-orange)

## 📋 Sobre o Projeto

**FocusStudy** é uma aplicação completa de gerenciamento de estudos desenvolvida como desafio técnico Full Stack. A aplicação permite que usuários:

- ✅ Registrem horas de estudo por matéria
- 📊 Acompanhem progresso através de estatísticas e gráficos
- 📝 Mantenham anotações sobre cada sessão de estudo
- 📱 Acessem via Web e Mobile (iOS/Android)

## 🎯 Funcionalidades

### Implementadas

- [x] Autenticação JWT (Login/Registro)
- [x] CRUD completo de matérias
- [x] CRUD completo de sessões de estudo
- [x] Dashboard com estatísticas em tempo real
- [x] Gráfico de progresso semanal
- [x] Listagem das últimas sessões
- [x] Interface responsiva (Web + Mobile)

### Próximas Features

- [ ] Notificações push
- [ ] Metas diárias/semanais
- [ ] Exportação de dados (CSV/PDF)
- [ ] Dark mode
- [ ] Gráficos mais avançados

## 🏗️ Arquitetura do Projeto

─────────────────────────────────────────────────────────────┐
│ Frontend Web (React/Next.js) │
│ http://localhost:3000 │
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ API Gateway (Django Ninja) │
│ http://localhost:8000 │
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ PostgreSQL Database │
│ Database: focus_study │
└─────────────────────────────────────────────────────────────┘
▲
│
┌─────────────────────────────────────────────────────────────┐
│ Mobile (Flutter) │
│ iOS + Android │
└─────────────────────────────────────────────────────────────┘


## 🛠️ Tecnologias Utilizadas

| Camada | Tecnologia | Versão |
|--------|------------|--------|
| **Backend** | Python + Django | 3.11+ / 4.2+ |
| **API** | Django Ninja | 0.22+ |
| **Autenticação** | JWT | - |
| **Banco de Dados** | PostgreSQL | 15+ |
| **Frontend Web** | React + Next.js | 18+ / 14+ |
| **Mobile** | Flutter | 3.16+ |
| **Estilização Web** | TailwindCSS | 3+ |
| **Gráficos Mobile** | fl_chart | 0.66+ |

## 📁 Estrutura do Projeto
focusstudy/
│
├── backend/ # Backend Django + Django Ninja
│ ├── manage.py
│ ├── requirements.txt
│ ├── .env
│ └── apps/
│ ├── api/
│ │ └── api.py # Endpoints da API
│ └── core/
│ └── models.py # Modelos de dados
│
├── frontend-web/ # Frontend React/Next.js
│ ├── package.json
│ ├── tailwind.config.js
│ └── src/
│ ├── app/ # Pages (App Router)
│ ├── components/ # Componentes reutilizáveis
│ └── lib/ # Utilitários e API
│
├── mobile/ # App Flutter
│ ├── pubspec.yaml
│ └── lib/
│ ├── screens/ # Telas do app
│ ├── models/ # Modelos de dados
│ ├── services/ # Conexão com API
│ └── widgets/ # Componentes reutilizáveis
│
├── docs/ # Documentação
│ ├── prd.md # Product Requirements Document
│ └── tech-specs.md # Technical Specifications
│
└── README.md # Este arquivo


## 🚀 Como Executar o Projeto

### Pré-requisitos

- Python 3.11+
- Node.js 18+
- Flutter 3.16+
- PostgreSQL 15+
- Git

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/focusstudy.git
cd focusstudy
2. Configurar o Backend
bash
# Entrar na pasta do backend
cd backend

# Criar ambiente virtual
python -m venv venv

# Ativar ambiente virtual
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt

# Configurar banco de dados
# Crie um banco PostgreSQL chamado 'focus_study'
# Configure no settings.py ou .env

# Executar migrações
python manage.py makemigrations
python manage.py migrate

# Criar superusuário (opcional)
python manage.py createsuperuser

# Rodar servidor
python manage.py runserver
O backend estará rodando em http://localhost:8000

3. Configurar o Frontend Web
bash
# Em outro terminal, entre na pasta do frontend
cd frontend-web

# Instalar dependências
npm install

# Rodar o projeto
npm run dev
O frontend web estará rodando em http://localhost:3000

4. Configurar o Mobile (Flutter)
bash
# Em outro terminal, entre na pasta do mobile
cd mobile

# Instalar dependências
flutter pub get

# Rodar o app
flutter run

# Para build APK
flutter build apk --release
📡 API Endpoints
Autenticação
Método	Endpoint	Descrição
POST	/api/auth/pair	Login
POST	/api/usuarios/registrar	Registrar
DELETE	/api/usuarios/me	Deletar conta
Matérias
Método	Endpoint	Descrição
GET	/api/materias	Listar matérias
POST	/api/materias	Criar matéria
PUT	/api/materias/{id}	Atualizar matéria
DELETE	/api/materias/{id}	Deletar matéria
Sessões
Método	Endpoint	Descrição
GET	/api/sessoes	Listar sessões
POST	/api/sessoes	Criar sessão
PUT	/api/sessoes/{id}	Atualizar sessão
DELETE	/api/sessoes/{id}	Deletar sessão
📱 Demonstração
Web
Tela de Login

Dashboard com estatísticas

CRUD de matérias

Registro de sessões

Mobile
Interface nativa (iOS/Android)

Drawer menu lateral

Gráficos interativos

Cards de estatísticas

🔧 Configuração do Banco de Dados
PostgreSQL
sql
-- Criar banco de dados
CREATE DATABASE focus_study;

-- Conectar ao banco
\c focus_study
Configuração Django
python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'focus_study',
        'USER': 'postgres',
        'PASSWORD': '123456',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
📊 Testes
Backend
bash
cd backend
python manage.py test
Frontend Web
bash
cd frontend-web
npm test
Mobile
bash
cd mobile
flutter test
🐛 Troubleshooting
Erro: PostgreSQL connection refused
bash
# Iniciar serviço do PostgreSQL
# Linux:
sudo systemctl start postgresql
# macOS:
brew services start postgresql@15
Erro: flutter pub get failed
bash
flutter clean
flutter pub get
Erro: Django migrations
bash
python manage.py makemigrations
python manage.py migrate --fake
python manage.py migrate
📈 Performance
Métrica	Alvo	Status
API Response	< 200ms	✅
Web FCP	< 1.5s	✅
Mobile 60fps	✅	✅
APK Size	< 15MB	✅
📚 Documentação
PRD (Product Requirements Document)

Tech Specs (Technical Specifications)

👨‍💻 Autor
Seu Pablo Phelipe Inacio Lopes

GitHub: @pinaciolopes

LinkedIn: pinaciolopes

📄 Licença
Este projeto foi desenvolvido como parte de um desafio técnico.

🙏 Agradecimentos
Django Ninja pela API rápida e eficiente

Flutter pela excelente experiência cross-platform

PostgreSQL pela robustez e confiabilidade

🎯 Status do Projeto
✅ Backend - Concluído
✅ Frontend Web - Concluído
✅ Mobile - Concluído
📝 Documentação - Em andamento
🚀 Deploy - Pendente

Desenvolvido com 💻 e ☕ para um desafio técnico


