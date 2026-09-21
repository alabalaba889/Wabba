# Wabba Luks

**Você imagina. A Wabba Luks constrói.**

A Wabba Luks é um **APP**, não um site. A proposta é funcionar como uma equipe virtual de desenvolvimento: receber uma ideia, analisar, planejar, arquitetar, desenvolver, testar, corrigir, construir e entregar.

## Base atual
- Android nativo com Kotlin + Jetpack Compose.
- Projetos dentro do APP.
- Chat de IA desacoplado por AIProvider.
- Provedor Mock para testes locais.
- Base de agentes especializados.
- Testes unitários iniciais.
- Estrutura para API keys de provedores externos sem segredos no código.

## Fluxo
IDEIA → ANÁLISE → PLANEJAMENTO → ARQUITETURA → DESENVOLVIMENTO → TESTES → CORREÇÕES → BUILD → ENTREGA

## Segurança
API keys reais nunca devem ser commitadas, embutidas no APK, colocadas no frontend ou escritas em logs.

## Testes
Os testes unitários ficam em app/src/test. Execute ./gradlew test com Android SDK/Gradle disponíveis.
