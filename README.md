# product_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Questionário de Reflexão (Atividade 2)
Após concluir a Atividade 2, responda às seguintes perguntas:

Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.
R: O mecanismo de cache foi implementado na pasta /datasource. Essa escolha faz sentido porque é nessa camada que ocorre a obtenção dos dados. Assim, o cache funciona como mais uma fonte de dados possível, permitindo que o repository recupere informações tanto do cache quanto de outras origens.

Por que o ViewModel não deve realizar chamadas HTTP diretamente?
R: Porque os dados que chegam à camada de apresentação já devem estar processados e convertidos para o formato de entidades. Caso o ViewModel fosse responsável por fazer chamadas HTTP e tratar esses dados, ele acabaria acumulando responsabilidades além de sua função principal, que é auxiliar a interface.

O que poderia acontecer se a interface acessasse diretamente o DataSource?
R:Se a interface acessasse o DataSource diretamente, poderia haver chamadas repetidas ou desnecessárias de dados, o que prejudicaria a performance do aplicativo. Além disso, a interface teria que lidar com dados ainda no formato de Model, exigindo a criação de lógicas de conversão que atualmente são responsabilidade do Repository.

Como essa arquitetura facilitaria a substituição da API por um banco de dados local?
R: Isso ocorre porque os métodos usados para buscar informações já estão definidos nos repositories. Dessa forma, bastaria criar um novo DataSource que utilize o banco de dados local e ajustar o repository para utilizá-lo, sem necessidade de alterar outras partes do sistema.