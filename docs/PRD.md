# PRD - FocusStudy

## 📋 Informações do Projeto

| Campo | Valor |
|-------|-------|
| **Nome do Projeto** | FocusStudy |
| **Versão** | 1.0.0 |
| **Data** | Janeiro/2026 |
| **Autor** | [Seu nome] |
| **Status** | Em desenvolvimento |

## 🎯 Objetivo do Produto

**FocusStudy** é um aplicativo de gerenciamento de estudos que permite aos usuários:

- Registrar horas de estudo por matéria
- Acompanhar progresso através de estatísticas e gráficos
- Manter anotações sobre cada sessão de estudo
- Visualizar métricas de desempenho

## 👥 Personas

### 1. Estudante Universitário (Principal)
- **Idade:** 18-25 anos
- **Necessidades:** Organizar múltiplas matérias, preparar provas
- **Dores:** Perde noção do tempo estudado, procrastina

### 2. Concurseiro
- **Idade:** 25-35 anos
- **Necessidades:** Disciplina rigorosa, acompanhamento detalhado
- **Dores:** Precisa de métricas para ajustar estratégia

### 3. Autodidata
- **Idade:** 20-40 anos
- **Necessidades:** Aprender novos assuntos de forma organizada
- **Dores:** Falta de estrutura nos estudos

## 📱 Funcionalidades

### MVP (Mínimo Produto Viável)

| ID | Funcionalidade | Prioridade | Descrição |
|----|---------------|------------|------------|
| F01 | Login/Registro | 🔴 Alta | Autenticação com JWT |
| F02 | CRUD Matérias | 🔴 Alta | Criar, editar, excluir matérias |
| F03 | CRUD Sessões | 🔴 Alta | Registrar sessões de estudo |
| F04 | Dashboard | 🔴 Alta | Cards com estatísticas |
| F05 | Gráficos | 🟡 Média | Progresso semanal |
| F06 | Logout | 🔴 Alta | Sair da aplicação |

## 📊 Métricas de Sucesso

| Métrica | Alvo | Como medir |
|---------|------|-------------|
| Tempo de cadastro | < 2 min | Analytics |
| Sessões por usuário | > 5/semana | Banco de dados |
| Retenção (D+7) | > 40% | Banco de dados |
| API Response | < 200ms | Logging |

## 🎨 Fluxos Principais

### Fluxo 1: Registro de Estudo

Login → Dashboard → Nova Sessão → Selecionar Matéria
→ Inserir Horas → Anotações → Salvar → Dashboard atualizado


### Fluxo 2: Gerenciar Matérias

Login → Menu Matérias → Ver lista → Adicionar/Editar/Excluir


## ⚠️ Restrições Técnicas

- **Backend:** Django 4.2+, SQLite/PostgreSQL
- **Frontend Web:** React 18+, Next.js 14+
- **Mobile:** Flutter 3.16+
- **API:** RESTful com autenticação JWT

## 🚀 Cronograma (Desafio Técnico - 5 dias)

| Dia | Tarefa | Entregável |
|-----|--------|-------------|
| Dia 1 | Setup + Models + API | Backend rodando |
| Dia 2 | Frontend Web (React) | Telas web |
| Dia 3 | Mobile Flutter (Login/Cadastro) | Telas iniciais |
| Dia 4 | Mobile Flutter (Dashboard) | App completo |
| Dia 5 | Documentação + Apresentação | Pitch final |