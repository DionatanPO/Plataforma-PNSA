# Visão Geral Técnica - Plataforma PNSA
**Data de Geração:** 16/12/2025
**Versão do Documento:** 1.0

## 1. Resumo Executivo
A **Plataforma PNSA** (Paróquia Nossa Senhora Auxiliadora) é um sistema de gestão eclesiástica multiplataforma (Web e Desktop) desenvolvido para modernizar e centralizar os processos administrativos da paróquia. O sistema foca na gestão de fiéis (dizimistas), controle financeiro de contribuições, segurança de acesso e relatórios administrativos.

O projeto destaca-se pela interface moderna (Fluent Design/Material 3), alta responsividade e arquitetura escalável baseada em microsserviços do Firebase.

---

## 2. Stack Tecnológico

### Frontend & Mobile/Desktop
*   **Framework:** Flutter (Dart) - Versão estável recente.
*   **Gerência de Estado:** GetX (Alta performance e injeção de dependência simplificada).
*   **Design System:** Customizado, com suporte a Temas (Claro/Escuro) e componentes responsivos.
*   **Plataformas Alvo:** Web (PWA), Windows (Desktop).

### Backend & Infraestrutura (Serverless)
*   **Plataforma:** Google Firebase.
*   **Autenticação:** Firebase Auth (Email/Senha, Gestão de Sessão Persistente).
*   **Banco de Dados:** Cloud Firestore (NoSQL, Tempo Real).
*   **Armazenamento:** Firebase Storage (para avatares e documentos - *preparado*).
*   **Hospedagem:** Firebase Hosting (para versão Web).

---

## 3. Arquitetura do Sistema
O sistema segue uma arquitetura **MVVM (Model-View-ViewModel)** adaptada com Clean Architecture simplificada para facilitar a manutenção:

*   **Data Layer:** Services (`AuthService`, `SessionService`, `FirestoreService`) responsáveis pela comunicação com o backend e cache local (`GetStorage`).
*   **Controller Layer (ViewModel):** Controllers do GetX (`DizimistaController`, `ContribuicaoController`) que contêm a regra de negócios e estado reativo.
*   **UI Layer (View):** Widgets modulares e páginas responsivas que reagem às mudanças de estado.

---

## 4. Inventário de Módulos e Funcionalidades

### 🔐 4.1. Autenticação e Segurança
*   **Login Seguro:** Autenticação via e-mail e senha com validação robusta.
*   **Gestão de Sessão:** Persistência automática (Web/Desktop) com timeout e verificação de status do usuário (ativo/inativo) em tempo real.
*   **Recuperação de Senha:** Fluxo automatizado via e-mail.
*   **Splash Screen Inteligente:** Verificação de integridade da sessão e roteamento automático.

### 👥 4.2. Gestão de Acesso (Admin)
*   **Controle de Usuários:** Cadastro de novos operadores/administradores.
*   **Permissões:** Sistema preparado para níveis de acesso (Admin, Operador, Leitura).
*   **Status:** Ativação e desativação de contas de usuários.
*   **Auditoria:** Registro de último acesso e criação de conta.

### ⛪ 4.3. Gestão de Fiéis (Dizimistas)
*   **Cadastro Completo:** Dados pessoais, endereço, contato e datas importantes (nascimento, casamento).
*   **Busca Avançada:** Pesquisa em tempo real por nome, CPF ou telefone.
*   **Listagem Otimizada:** Tabela responsiva com paginação e ordenação.
*   **Edição/Exclusão:** Gestão do ciclo de vida do cadastro do fiel.

### 💰 4.4. Controle de Contribuições
*   **Registro de Dízimos:** Interface otimizada para lançamento rápido de entradas financeiras.
*   **Histórico:** Visualização de contribuições passadas por fiel.
*   **Validação:** Regras de negócio para garantir integridade dos dados financeiros.

### 📊 4.5. Relatórios e Dashboards (Módulo em Expansão)
*   **Dashboard Principal:** Visão geral de métricas (implementação base).
*   **Relatórios de Vendas/Ações:** Módulos específicos para eventos e campanhas (`ActionView`, `ReportView`).

### ⚙️ 4.6. Configurações e Perfil
*   **Perfil do Usuário:** Edição de dados cadastrais e foto de perfil (Avatar).
*   **Temas:** Alternância dinâmica entre Modo Claro e Modo Escuro com persistência de preferência.
*   **Suporte:** Telas de ajuda e "Sobre o sistema".

---

## 5. Diferenciais Técnicos (Valor Agregado)
Estes pontos justificam um valor maior no orçamento devido à qualidade técnica:

1.  **UI/UX Premium:** Não é um "sistema padrão". Possui animações, transições suaves, feedback visual rico e design consistente.
2.  **Componentização:** Uso de widgets reutilizáveis (`ModernHeader`, `ModernSearchBar`) que reduzem custo de manutenção futura.
3.  **Responsividade Real:** O sistema se adapta de telas de celular a monitores ultrawide sem quebrar o layout.
4.  **Código Limpo:** Estrutura organizada, tipada e documentada, facilitando a passagem de conhecimento ou expansão por outros desenvolvedores.

---

## 6. Estimativa de Complexidade (Para Orçamento)

| Módulo | Complexidade | Status | Observação |
| :--- | :---: | :---: | :--- |
| **Infraestrutura Base** | Alta | ✅ Concluído | Configuração Firebase, Rotas, Temas, Auth Guard. |
| **Autenticação** | Média | ✅ Concluído | Login, Logout, Recuperação, Sessão. |
| **Gestão de Acesso** | Média | ✅ Concluído | CRUD de usuários do sistema. |
| **Dizimistas** | Alta | ✅ Concluído | CRUD complexo, Busca, Filtros. |
| **Contribuições** | Alta | 🚧 Em Ajuste | Lançamentos, Integração com Dizimista. |
| **Relatórios** | Alta | 🚧 Em Progresso | `ActionView` possui alta complexidade de lógica. |
| **Dashboard** | Média | 🟡 Básico | Precisa de integração com dados reais. |

**Total Estimado de Telas/Views:** ~15 a 20 telas principais + diálogos modais.

---

## 7. Próximos Passos Recomendados
*   Finalização do módulo de Relatórios Financeiros.
*   Testes de carga e segurança no Firestore.
*   Deploy automatizado (CI/CD) para Web e Windows.
