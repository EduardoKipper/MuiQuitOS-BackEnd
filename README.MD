# 🦟 MuiQuitOS-BackEnd

Backend MVP em Julia para registro e controle de focos do mosquito Aedes Aegypti.

## ⚙️ Setup do Sistema

1. **Pré-requisitos:**
   - Julia instalado ([🔗](https://julialang.org/downloads/))

2. **Instale as dependências do projeto:**
   Abra o terminal na pasta do projeto (MuiQuitOS-BackEnd) e execute em sequência:
   ```sh
   julia
   ] activate .
   dev ./MuiQuitOSBackEnd
   ```
   (O `]` entra no modo de pacote do Julia REPL. Use Backspace para voltar ao prompt `julia>`.)

3. **Instale as dependências do pacote:**
   Feche o terminal anterior e abra um novo.
   No novo terminal, entre na pasta do pacot~e:
   ```sh
   cd MuiQuitOSBackEnd
   ```
   E execute em sequência:
   ```sh
   julia
   ] activate .
   add CSV DataFrames JSON3 HTTP Sockets Statistics StatsBase Plots Gadfly Dates
   ```
   > **Observação:**
   > O pacote `Dates` agora é utilizado para manipulação de datas e geração dos gráficos temporais.

4. **Geração automática de gráficos:**
   Ao executar o backend, três gráficos são gerados automaticamente na pasta `cache/`:
   - `registers_by_neighbourhood_pie.png`: Registros por bairro (gráfico de pizza)
   - `registers_by_time_of_day_line.png`: Registros por hora do dia (gráfico de linha)
   - `registers_by_month_line.png`: Registros por mês (gráfico de linha)

   Durante a geração dos gráficos, mensagens informativas são exibidas no console indicando o início e o término de cada gráfico.

5. **Execute o servidor:**
   Com as etapas anteriores feitas, toda vez que quiser executar o servidor basta executar, em ordem:
   ```sh
   julia
   ] activate .
   ```
   Pressione CTRL + C e execute:
   ```sh
   include("app.jl")
   ```

   ### O backend estará disponível em: http://localhost:8080 🚀

## 📁 Estrutura dos Arquivos
- `database/users.csv`: 👤 Usuários do sistema
- `database/registers.csv`: 🦟 Registros de focos de mosquito
- `MuiQuitOSBackEnd/src/models/`: 🧩 Definições de tipos (User, Register)
- `MuiQuitOSBackEnd/src/controllers/`: 🧠 Lógica das rotas
- `MuiQuitOSBackEnd/src/routes/`: 🛣️ Definição das rotas

## 📡 Rotas da API

### 🔑 Login
- `POST /login`
  - **Body:** `{ "name": "string", "password": "string" }`
  - **Resposta:** 200 OK com dados do usuário, 401 para credenciais inválidas

### 👤 Usuários
- `GET /users` — Lista todos os usuários
- `POST /users` — Cria usuário
  - **Body:** `{ "name": "string", "email": "string", "password": "string", "type": "string" }`
- `PUT /users` — Atualiza usuário
  - **Body:** igual ao POST
- `DELETE /users` — Remove usuário
  - **Body:** `{ "email": "string" }`

### 🦟 Registros
- `GET /registers` — Lista todos os registros
- `POST /registers` — Cria registro
  - **Body:** `{ "user_id": "string", "cep": "string", "datetime": "string", "intensity": float, "evidence": "string", "latitude": float, "longitude": float, "city": "string", "state": "string", "neighbourhood": "string", "access_difficulty": int, "focus_size": int, "larvae": boolean }`
- `PUT /registers` — Atualiza registro
  - **Body:** `{ "register_id": int, "user_id": "string", "cep": "string", "datetime": "string", "intensity": float, "evidence": "string", "latitude": float, "longitude": float, "city": "string", "state": "string", "neighbourhood": "string", "access_difficulty": int, "focus_size": int, "larvae": boolean }`
- `DELETE /registers` — Remove registro
  - **Body:** `{ "register_id": int }`

## 📋 Tabela de Endpoints da API

| Método | Rota         | Descrição                        | Body/Parâmetros                                                                                                                                                                                           | Resposta Exemplo           |
|--------|--------------|-----------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------|
| POST   | /login       | Login de usuário                  | `{ "name": "string", "password": "string" }`                                                                                                                                                             | 200 OK (usuário), 401      |
| GET    | /users       | Lista todos os usuários           | -                                                                                                                                                                                                         | 200 OK (lista usuários)    |
| POST   | /users       | Cria novo usuário                 | `{ "name": "string", "email": "string", "password": "string", "type": "string" }`                                                                                                                            | 201 Created, 409 (duplicado) |
| PUT    | /users       | Atualiza usuário                  | `{ "name": "string", "email": "string", "password": "string", "type": "string" }`                                                                                                                            | 200 OK                     |
| DELETE | /users       | Remove usuário                    | `{ "email": "string" }`                                                                                                                                                                                  | 200 OK                     |
| GET    | /registers   | Lista todos os registros          | -                                                                                                                                                                                                         | 200 OK (lista registros)   |
| POST   | /registers   | Cria novo registro de mosquito    | `{ "user_id": "string", "cep": "string", "datetime": "string", "intensity": float, "evidence": "string", "latitude": float, "longitude": float, "city": "string", "state": "string", "neighbourhood": "string", "access_difficulty": int, "focus_size": int, "larvae": boolean }` | 201 Created, 400 (user_id inválido) |
| PUT    | /registers   | Atualiza registro                 | `{ "register_id": int, "user_id": "string", "cep": "string", "datetime": "string", "intensity": float, "evidence": "string", "latitude": float, "longitude": float, "city": "string", "state": "string", "neighbourhood": "string", "access_difficulty": int, "focus_size": int, "larvae": boolean }` | 200 OK                     |
| DELETE | /registers   | Remove registro                   | `{ "register_id": int }`                                                                                                                                                                                 | 200 OK                     |

> **Observação:**
> - Todos os bodies devem ser enviados em JSON.
> - O campo `intensity` em `/registers` é um número de ponto flutuante.
> - O campo `user_id` deve ser um email válido cadastrado em `/users`.

## ℹ️ Observações
- Todos os dados são persistidos em arquivos CSV 📄.
- O sistema não implementa autenticação avançada (JWT, hashing de senha, etc).
- Ideal para MVP e testes rápidos ⚡.

---

## Comandos experimentais

- Criar usuário: curl -X POST http://localhost:8080/users -H "Content-Type: application/json" -d "{\"name\": \"Nome Exemplo\", \"email\": \"exemplo@email.com\", \"password\": \"senha123\", \"type\": \"user\"}"
- Buscar usuários: curl -X GET http://localhost:8080/users
- Fazer registro de mosquito: curl -X POST http://localhost:8080/registers -H "Content-Type: application/json" -d "{\"user_id\": \"exemplo@email.com\", \"cep\": \"88015-700\", \"datetime\": \"2025-07-01T10:00:00\", \"intensity\": 6.8, \"evidence\": null, \"latitude\": -27.5935, \"longitude\": -48.5585, \"city\": \"Florianópolis\", \"state\": \"SC\", \"neighbourhood\": \"Centro\", \"access_difficulty\": 7, \"focus_size\": 8, \"larvae\": true}"
- Buscar registros de mosquito: curl -X GET http://localhost:8080/registers
