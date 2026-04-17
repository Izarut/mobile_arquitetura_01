# mobile_arquitetura_02

Versão evoluída da aplicação Flutter com arquitetura em camadas, gestão explícita de estados, tratamento de erros e cache local.

---

## O que foi implementado

### Estado da interface

A interface representa explicitamente **quatro estados distintos** por meio do enum `ProductStatus`:

| Status | Descrição |
|--------|-----------|
| `initial` | Nenhuma requisição foi feita ainda |
| `loading` | Requisição em andamento |
| `success` | Dados carregados com sucesso da API |
| `cached` | Dados retornados do cache (API indisponível) |
| `error` | Falha sem nenhum dado disponível |

A `ProductPage` usa um `switch` sobre `state.status` para renderizar o widget correto para cada situação — sem condicionais aninhadas ou flags booleanas ambíguas.

### Tratamento de erros

- O `ProductRemoteDatasource` propaga exceções de rede (`DioException`) sem tratá-las — isso é responsabilidade do `Repository`.
- O `ProductRepositoryImpl` captura a exceção, tenta o cache, e só lança `Failure` se não houver fallback disponível.
- O `ProductViewModel` captura `Failure` com `on Failure catch` e armazena a mensagem amigável no estado.
- A `ProductPage` exibe a mensagem de erro com um botão "Tentar novamente".

### Cache local

O `ProductCacheDatasource` armazena os produtos em memória. O `ProductRepositoryImpl` salva o cache após cada sucesso de API e usa-o como fallback quando a API falha. Quando os dados vêm do cache, a UI exibe um banner informando o usuário.

---

## Questionário de Reflexão

### 1. Em qual camada foi implementado o mecanismo de cache? Por quê?

O cache foi implementado em **duas camadas com responsabilidades distintas**:

- **`ProductCacheDatasource` (camada de dados / DataSource):** responsável pelo armazenamento em si — salvar e recuperar os modelos da memória. É uma operação pura de I/O, sem lógica de negócio.

- **`ProductRepositoryImpl` (camada de dados / Repository):** responsável pela **decisão** de quando usar o cache — tentar a API primeiro, salvar no cache em caso de sucesso, e recorrer ao cache em caso de falha.

Essa divisão é adequada porque o Repository é o árbitro natural entre fontes de dados. Colocar a lógica de fallback no ViewModel violaria a separação de camadas (o ViewModel ficaria sabendo de detalhes de infraestrutura). Colocar no DataSource também seria errado (o DataSource não deve decidir de onde os dados vêm — só executar o I/O).

### 2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?

Porque isso criaria um **acoplamento entre lógica de apresentação e infraestrutura de rede**, trazendo vários problemas:

- **Testabilidade:** para testar o ViewModel, seria necessário mockar o HTTP — o que é mais complexo do que mockar um simples `ProductRepository`.
- **Manutenibilidade:** trocar a biblioteca HTTP (ex: `dio` por `http`) exigiria modificar o ViewModel.
- **Reutilização:** a lógica de requisição não poderia ser compartilhada com outros ViewModels facilmente.
- **Responsabilidade única:** o ViewModel deve apenas coordenar estado de UI, não executar I/O.

### 3. O que poderia acontecer se a interface acessasse diretamente o DataSource?

A interface teria acesso a detalhes de implementação que não lhe pertencem:

- Precisaria conhecer `ProductModel` (modelo de dados) em vez de `Product` (entidade de domínio).
- Ficaria responsável por tratar erros de rede, aplicar cache e converter modelos — misturando responsabilidades.
- Qualquer mudança no DataSource (ex: trocar `Dio` por `http`, adicionar autenticação) forçaria mudanças na UI.
- Não haveria ponto central para adicionar regras de negócio (ex: filtros, ordenação, paginação) sem duplicação.

Em suma: a interface se tornaria frágil, difícil de testar e de manter.

### 4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?

Bastaria criar um novo DataSource — por exemplo, `ProductLocalDatasource` usando SQLite ou Hive — e injetá-lo no `ProductRepositoryImpl` no lugar (ou ao lado) do `ProductRemoteDatasource`.

O `ProductRepository` (interface de domínio) continuaria com a mesma assinatura `Future<CacheResult> getProducts()`. O ViewModel e a UI **não precisariam de nenhuma alteração**, pois dependem apenas da abstração do Repository, não de como os dados são obtidos.

Isso é possível porque a arquitetura em camadas garante que cada camada dependa apenas da camada imediatamente abaixo por meio de abstrações (interfaces), e não de implementações concretas.

---

## Estrutura do projeto

```
lib/
├── core/
│   └── errors/
│       └── failure.dart          # Exceção de domínio com mensagem amigável
├── data/
│   ├── datasources/
│   │   ├── product_cache_datasource.dart   # I/O: armazenamento em memória
│   │   └── product_remote_datasource.dart  # I/O: chamada HTTP
│   ├── models/
│   │   └── product_model.dart    # Modelo de dados (serialização JSON)
│   └── repositories/
│       └── product_repository_impl.dart    # Decide entre API e cache
├── domain/
│   ├── entities/
│   │   └── product.dart          # Entidade de domínio pura
│   └── repositories/
│       └── product_repository.dart         # Contrato (interface) do repository
├── presentation/
│   ├── pages/
│   │   └── product_page.dart     # UI com switch sobre ProductStatus
│   └── viewmodel/
│       ├── product_state.dart    # Enum + classe de estado
│       └── product_viewmodel.dart          # Coordena estado, delega ao repository
└── main.dart                     # Composição de dependências
```
