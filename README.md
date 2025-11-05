# insuguia_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## REDME em construção (Acompanhamento e registro de implementações)

# InsuGuia Mobile (Protótipo Didático)

> Este app é um **protótipo educacional** que **simula** recomendações iniciais para manejo de glicemia em **paciente não crítico**. **Não** é um dispositivo médico e **não deve** ser usado para decisões clínicas.

---

## Sobre o projeto

O **InsuGuia Mobile** é um app Flutter criado como parte do Projeto de Extensão da disciplina **Desenvolvimento para Plataformas Móveis**. Nesta fase (Entrega 2), o foco foi evoluir o protótipo com **ajustes de UX**, **feedback ao usuário**, **persistência leve de rascunho**, **exportação do texto da sugestão via download para os usuários** e **testes de widget**.


---

## Como rodar

### Pré-requisitos

* **Flutter**
* VS Code ou Android Studio (opcional)
* Para **Web**: Chrome/Edge
* Para **Windows**: Visual Studio com workload **Desktop development with C++** e **Developer Mode** do Windows habilitado

### Passos (vale para Web e Windows)

```bash
flutter clean
flutter pub get
```

### Rodar no navegador (Web)

```bash
flutter config --enable-web
flutter run -d chrome   # ou -d edge
```

### Rodar como app de Windows

> Requer Developer Mode habilitado.

```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

---

## Implementado na Entrega 2

* **Validação/UX do formulário**: campo **Peso (kg)** com máscara simples, *helper text* e validação (faixa 1–400).
* **Tema e consistência**: Material 3 com *seed color* e leve aumento da tipografia (via `MediaQuery.textScaler`).
* **Feedback ao usuário**: banner de **uso didático** e **SnackBar** ao copiar a sugestão.
* **Exportar sugestão (Web)**: botão **Baixar .txt** realiza o download do texto gerado.
* **Persistência leve (rascunho)**: guarda **nome** e **peso** com `shared_preferences`.
* **Acessibilidade**: `Semantics` no texto da sugestão.
* **Testes de widget**: smoke test da Home e fluxo **Novo Paciente → Sugestão**.

---

## Testes

Rode os testes com:

```bash
flutter test
```

Arquivos sugeridos:

* `test/home_smoke_test.dart` — Home e fluxo até a tela de Sugestão
* `test/draft_and_feedback_test.dart` — rascunho (SharedPreferences mock) e SnackBar de cópia

---

## 🗂️ Estrutura (simplificada)

```
lib/
 ├─ main.dart                # telas: Home, Formulário, Sugestão
 └─ utils/
     ├─ download.dart        # export condicional (web/io)
     ├─ download_web.dart    # implementação web (package:web)
     ├─ download_io.dart     # implementação desktop (file_selector) [opcional]
     └─ download_stub.dart   # no-op fallback
```

---

## ⚠️ Observações

* Mensagens relacionadas a **Android/Gradle** podem aparecer no painel do editor. Se não for compilar para Android nesta fase, ignore.
* O botão **Baixar .txt** funciona diretamente na **Web**; no **Windows** requer a implementação com `file_selector` no qual ainda não implementamos na aplicação.

---

## 🧭 Roadmap (próximas entregas)

* Camada de **regras/domain** para os cálculos simulados
* Estado com **Riverpod** (ou similar)
* Reformatar a sugestão em **seções/tabela**
* **Responsividade** para telas muito estreitas e **dark mode**
* Protótipo de **acompanhamento diário** (simulado)

---

## 📄 Licença/uso

Projeto de caráter **acadêmico/didático**. Não utilizar para decisões clínicas.

---

## 👥 Equipe

* Pedro Henrique Scheidt
* Vinícius Minas

Professor: Sandro Alencar Fernandes — Projeto de Extensão / Desenvolvimento para Plataformas Móveis

