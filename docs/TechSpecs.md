# 🚀 Como rodar o Projeto FocusStudy

### 1. Back-end (Django)
1. `cd backend`
2. `.\venv\Scripts\activate`
3. `python manage.py runserver`

### 2. Web (Next.js)
1. `cd frontend`
2. `npm run dev`

### 3. Mobile (Flutter)
1. `cd mobile`
2. `flutter run -d chrome` (ou o emulador de sua preferência)

## Informações do Projeto

| Campo | Valor |
|-------|-------|
| **Nome do Projeto** | FocusStudy |
| **Versão** | 1.0.0 |
| **Data** | Maio/2026 |
| **Tipo** | Desafio Técnico - Full Stack |

---

## 1. Visão Geral da Arquitetura

┌─────────────────────────────────────────────────────────────┐
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
│ PostgreSQL 15+ Database │
│ │
│ ┌────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│ │ User │ │ Materia │ │ SessaoEstudo │ │
│ │ (auth) │ │ (estudos) │ │ (registros) │ │
│ └────────────┘ └──────────────┘ └──────────────────┘ │
└─────────────────────────────────────────────────────────────┘
▲
│
┌─────────────────────────────────────────────────────────────┐
│ Mobile (Flutter) │
│ iOS + Android │
└─────────────────────────────────────────────────────────────┘


---

## 2. Stack Tecnológica

| Camada | Tecnologia | Versão |
|--------|------------|--------|
| Backend | Python + Django | 3.11+ / 4.2+ |
| API | Django Ninja | 0.22+ |
| Autenticação | JWT | - |
| Banco de Dados | PostgreSQL | 15+ |
| Driver PostgreSQL | psycopg2-binary | 2.9+ |
| Frontend Web | React + Next.js | 18+ / 14+ |
| Mobile | Flutter | 3.16+ |

---

## 3. Configuração do PostgreSQL

### Instalação

```bash
# Windows - Baixar installer em: https://www.postgresql.org/download/windows/

# macOS
brew install postgresql@15

# Linux (Ubuntu/Debian)
sudo apt update
sudo apt install postgresql-15 postgresql-contrib

Criando o Banco de Dados

sudo -u postgres psql

CREATE DATABASE focusstudy_db;
CREATE USER focususer WITH PASSWORD 'focuspass123';
GRANT ALL PRIVILEGES ON DATABASE focusstudy_db TO focususer;
\q

Configuração no Django (settings.py)

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'focus_study',      # Nome do banco criado no pgAdmin
        'USER': 'postgres',          # Usuário padrão do PostgreSQL
        'PASSWORD': '123456',        # Senha definida na instalação
        'HOST': 'localhost',         # Banco rodando localmente
        'PORT': '5432',              # Porta padrão do PostgreSQL
    }
}

Variáveis de Ambiente (.env)

# .env
DB_NAME=focus_study
DB_USER=postgres
DB_PASSWORD=123456
DB_HOST=localhost
DB_PORT=5432

Configuração Segura com .env

# settings.py
from decouple import config

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': config('DB_NAME'),
        'USER': config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST'),
        'PORT': config('DB_PORT'),
    }
}

4. Criando o Banco de Dados
Via pgAdmin (Recomendado)
Abra o pgAdmin

Clique com botão direito em "Databases"

Selecione "Create" → "Database"

Nome: focus_study

Owner: postgres

Clique em "Save"

Via Terminal/psql

-- Acessar PostgreSQL
psql -U postgres

-- Criar banco de dados
CREATE DATABASE focus_study;

-- Verificar se foi criado
\l

-- Sair
\q


5. Dependências (requirements.txt)

Django==4.2.7
django-ninja==0.22.0
django-ninja-jwt==5.0.0
psycopg2-binary==2.9.9
django-cors-headers==4.3.1
python-decouple==3.8
python-dotenv==1.0.0

Instalação

pip install -r requirements.txt

6. Modelos de Dados

Matéria

class Materia(models.Model):
    id = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=100)
    usuario = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'materias'
        indexes = [models.Index(fields=['usuario', 'nome'])]
        
Sessão de Estudo

class SessaoEstudo(models.Model):
    id = models.AutoField(primary_key=True)
    materia = models.ForeignKey(Materia, on_delete=models.CASCADE)
    data = models.DateField(db_index=True)
    horas_estudadas = models.DecimalField(max_digits=5, decimal_places=2)
    anotacoes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'sessoes_estudo'
        indexes = [models.Index(fields=['materia', '-data'])]


7. API Endpoints
Autenticação
Método	Endpoint	Descrição
POST	/api/auth/pair	Login
POST	/api/usuarios/registrar	Registrar usuário
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

8. Schemas da API

{
  "username": "string",
  "password": "string"
}

Login Response

{
  "access": "string (JWT)",
  "refresh": "string (JWT)"
}

Matéria Schema

{
  "id": "integer",
  "nome": "string"
}

Sessão Schema

{
  "id": "integer",
  "materia_id": "integer",
  "data": "YYYY-MM-DD",
  "horas_estudadas": "float",
  "anotacoes": "string"
}

9. Autenticação JWT
Fluxo de Autenticação

1. POST /api/auth/pair (username, password)
2. Backend valida credenciais
3. Backend retorna {access, refresh}
4. Cliente salva token
5. Cliente envia header: Authorization: Bearer {token}

Configuração JWT

NINJA_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ALGORITHM': 'HS256',
}

10. Estrutura de Pastas

projeto/
│
├── docs/
│   ├── PRD.md
│   └── TechSpecs.md
│
├── backend/
│   │
│   ├── acompanhamento_estudos/
│   │   ├── __init__.py
│   │   ├── asgi.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   │
│   ├── estudos/
│   │   ├── migrations/
│   │   ├── __pycache__/
│   │   ├── __init__.py
│   │   ├── admin.py
│   │   ├── api.py
│   │   ├── apps.py
│   │   ├── models.py
│   │   ├── tests.py
│   │   └── views.py
│   │
│   ├── venv/
│   │   ├── Include/
│   │   ├── Lib/
│   │   └── Scripts/
│   │
│   ├── .gitignore
│   ├── manage.py
│   └── pyvenv.cfg
│
├── frontend/
│   │
│   ├── app/
│   ├── public/
│   ├── node_modules/
│   ├── .next/
│   │
│   ├── .gitignore
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── eslint.config.mjs
│   ├── next-env.d.ts
│   ├── next.config.ts
│   ├── package-lock.json
│   ├── package.json
│   ├── postcss.config.mjs
│   ├── README.md
│   └── tsconfig.json
│
└── mobile/
    │
    ├── android/
    ├── ios/
    ├── linux/
    ├── macos/
    ├── web/
    ├── windows/
    ├── lib/
    ├── test/
    ├── build/
    ├── .dart_tool/
    ├── .idea/
    │
    ├── .flutter-plugins-dependencies
    ├── .gitignore
    ├── .metadata
    ├── analysis_options.yaml
    ├── mobile.iml
    ├── pubspec.lock
    ├── pubspec.yaml
    └── README.md

11. Performance Targets

Métrica	Alvo
API Response Time	< 200ms
Web FCP	< 1.5s
Mobile Frame Rate	60 fps
APK Size	< 15 MB

12. Comandos Úteis
Django + PostgreSQL

# Criar migrações
python manage.py makemigrations

# Ver SQL das migrações
python manage.py sqlmigrate app_name 0001

# Aplicar migrações
python manage.py migrate

# Acessar o banco pelo Django
python manage.py dbshell

# Rodar servidor
python manage.py runserver

PostgreSQL

# Acessar PostgreSQL via terminal
psql -U postgres -d focus_study

# Ver tabelas
\dt

# Ver dados de uma tabela
SELECT * FROM materias;

# Sair
\q

Flutter

# Instalar dependências
flutter pub get

# Rodar app
flutter run

# Build APK
flutter build apk --release

13. Decisões Técnicas
Decisão	Motivo
Django Ninja	Mais rápido que DRF, type hints, documentação automática
PostgreSQL	Robusto, escalável, índices avançados, suporte a transações
Next.js	SSR, SEO, performance, deploy fácil na Vercel
Flutter	Cross-platform, 60fps nativo, UI consistente
JWT	Stateless, escalável, fácil integração mobile/web

14. Docker Compose

version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: focusstudy_db
      POSTGRES_USER: focususer
      POSTGRES_PASSWORD: focuspass123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:

15. Códigos de Status HTTP

Status	Significado
200	OK
201	Created
400	Bad Request
401	Unauthorized
404	Not Found
500	Internal Error

16. Considerações Finais

Banco de Dados: PostgreSQL 15+ em desenvolvimento e produção

Backend: Django + Django Ninja com autenticação JWT

Frontend Web: React + Next.js com TailwindCSS

Mobile: Flutter com suporte iOS/Android

API: RESTful com documentação automática (Swagger)