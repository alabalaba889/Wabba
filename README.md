# Wabba Luks

**Você imagina. A Wabba Luks constrói.**

A Wabba Luks é um **APP Android nativo**, não um site. A proposta é funcionar como uma equipe virtual de desenvolvimento: receber uma ideia, analisar, planejar, arquitetar, desenvolver, testar, corrigir, construir e entregar.

## Base atual
- Kotlin + Jetpack Compose.
- Projetos e fluxo inicial de criação.
- Chat de IA desacoplado por `AIProvider`.
- Mock local para desenvolvimento e testes.
- Provedor HTTP compatível com APIs no formato OpenAI Chat Completions.
- Configuração de provedor dentro do app.
- API key protegida com Android Keystore + AES/GCM.
- IDs de mensagens monotônicos para evitar colisões em listas Compose.
- Testes unitários e testes instrumentados no emulador.
- CI com testes unitários, lint, APK debug e testes instrumentados.

## Fluxo
IDEIA → ANÁLISE → PLANEJAMENTO → ARQUITETURA → DESENVOLVIMENTO → TESTES → CORREÇÕES → BUILD → ENTREGA

## Provedores de IA
A interface `AIProvider` permite adicionar novos provedores sem acoplar a UI a um fornecedor específico.

O provedor `openai-compatible` recebe uma Base URL, modelo e chave. A chave é guardada localmente de forma criptografada usando uma chave protegida pelo Android Keystore.

A integração de rede usa HTTPS quando a Base URL fornecida é HTTPS. A Wabba não grava a chave em logs, código-fonte ou arquivos do repositório.

> Para produção, recomenda-se também um backend próprio para não distribuir uma chave de alto privilégio dentro de um APK.

## Segurança
- Nunca commitar `.env`, API keys, keystores ou `google-services.json`.
- Não colocar segredos em BuildConfig, resources ou código.
- Não registrar headers de autorização ou corpos contendo credenciais em logs.
- Validar respostas e códigos HTTP de provedores.
- Usar limites de timeout para evitar requests pendurados.

## CI
O workflow `.github/workflows/android.yml` executa:
1. testes unitários;
2. lint;
3. build do APK debug;
4. testes Compose instrumentados em Android Emulator.

Os resultados reais do GitHub Actions são usados para corrigir regressões antes de novas alterações.

## Desenvolvimento local
Se Gradle e Android SDK estiverem instalados:

`gradle test`

`gradle lintDebug`

`gradle assembleDebug`

`gradle connectedDebugAndroidTest` com um dispositivo/emulador conectado.
