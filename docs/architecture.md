# Arquitetura da Wabba Luks

A Wabba Luks é um **APP**, não um site. A base inicial é Android nativo em Kotlin/Jetpack Compose.

## Camadas
1. Interface do APP.
2. Gerenciador de projetos.
3. Orquestrador de IA.
4. Provedores de IA através de AIProvider.
5. Agentes: Manager, Architect, Designer, Coder, Tester, Debugger, Builder e Reviewer.
6. Ferramentas: arquivos, execução, testes, build e exportação.
7. Verificação automática.
8. Segurança e auditoria.

## Fluxo
IDEIA → ANÁLISE → PLANEJAMENTO → ARQUITETURA → DESENVOLVIMENTO → TESTES → CORREÇÕES → BUILD → ENTREGA

API keys nunca devem ficar no código, README, APK ou logs.
