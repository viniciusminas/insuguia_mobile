# InsuGuia Mobile (Protótipo Didático)

Protótipo educacional em Flutter que **simula recomendações iniciais** para manejo de glicemia em paciente **não crítico** durante internação hospitalar.  

Não é um dispositivo médico, não foi validado para uso clínico e **não deve ser utilizado para decisões reais em saúde**.

---

## Contexto e objetivos

Este app foi desenvolvido como parte do **Projeto de Extensão da disciplina Desenvolvimento para Plataformas Móveis** (UNIDAVI).

Principais objetivos:

- Exercitar o uso de **Flutter** com **Firebase/Firestore** em um cenário próximo da prática em saúde.
- Traduzir a resposta de um médico especialista (Dr. Itairan) em um **fluxo digital guiado**.
- Implementar um cálculo **simulado** de dose de insulina em cenário **não crítico**, com foco em aprendizado, não em precisão clínica.
- Garantir uma UX simples para cadastro, visualização e acompanhamento didático dos pacientes.

---

## Escopo clínico (didático)

- Cenário: paciente **adulto, não crítico**, em ambiente de **enfermaria** ou similar.
- O app **não** cobre todos os cenários do protocolo (ex.: UTI, NPO, nutrição parenteral total, insulinoterapia prévia complexa).
- A lógica de cálculo é baseada em um **resumo simplificado** do protocolo:  
  – Dose Total Diária (DTD) proporcional ao peso  
  – Separação em insulina basal e prandial  
  – Distribuição de NPH e rápida para paciente em dieta oral  

Em todos os textos da interface está reforçado o caráter **exclusivamente acadêmico** do protótipo.

---

## Principais funcionalidades

### 1. Cadastro de paciente

Tela de formulário com:

- Nome (fictício)
- Sexo
- Idade
- Peso (kg)
- Altura (cm)
- Creatinina (mg/dL)
- Local (Enfermaria, UTI, Ambulatório)
- Cenário (Crítico / Não crítico)

O formulário possui:

- **Validação básica** de faixas (ex.: peso, altura, creatinina).
- **Persistência leve de rascunho** com `shared_preferences`  
  (se o usuário sair da tela, parte dos dados permanece preenchida).

Os pacientes são salvos em uma coleção `pacientes` do **Cloud Firestore**.

### 2. Lista de pacientes (Firestore)

- Tela de listagem que exibe todos os pacientes cadastrados no Firebase, em ordem decrescente de criação.
- Cada item mostra nome, idade, sexo e local.
- Botão “Detalhes” abre a tela de **Sugestão** para aquele paciente.

### 3. Cálculo simulado de insulina (cenário não crítico)

Na tela de **Sugestão**, para pacientes com cenário “Não crítico”:

1. **Cálculo de IMC** a partir de peso e altura.
2. Estimativa de **sensibilidade à insulina** (sensível / habitual / resistente) de forma didática, usando faixas de IMC.
3. Cálculo da **Dose Total Diária (DTD)** na faixa de **0,2 a 0,6 UI/kg/dia**, onde:
   - Metade da DTD é considerada **insulina basal**.
   - Metade da DTD é considerada **bôlus/prandial**.
4. Distribuição da insulina basal como **NPH 3x/dia** (06h, 11h, 22h).
5. Distribuição da insulina rápida como **3 doses pré-refeição** (café, almoço, jantar).
6. **Arredondamento das doses** para unidades inteiras, simulando a limitação dos dispositivos de aplicação.

O resultado é apresentado em forma de texto estruturado, incluindo:

- Dieta (descrita de forma genérica).
- Monitorização glicêmica (AC/HS, 03h se necessário).
- Insulina basal (NPH, três horários).
- Insulina rápida/prandial antes das refeições.
- Recomendações gerais de correção e reavaliação diária (simuladas).

Para cenários diferentes de “Não crítico”, a tela gera um texto mais genérico, sem cálculo detalhado.

### 4. Exportação da sugestão

Na tela de Sugestão:

- Botão **“Baixar .txt”** que exporta o texto gerado para um arquivo `.txt`  
  (implementação específica para Web, via `utils/download.dart`).

### 5. Acompanhamento diário (simulado)

Tela de **Acompanhamento diário** para cada paciente:

- Permite registrar glicemias em diferentes momentos:
  - AC Café, AC Almoço, AC Jantar, HS (ao deitar), 03:00.
- As leituras são salvas em uma subcoleção `acompanhamentos` do paciente no Firestore.
- A tela exibe a lista das últimas leituras e uma frase-resumo:

  - Média de jejum (AC Café) > 180 → sugerir aumento ~10% da basal (simulado).  
  - Média de jejum < 70 → sugerir redução ~10% da basal (simulado).  
  - Média dentro da faixa → sugerir manutenção da dose basal.

Essa lógica é apenas **ilustrativa**, para apoiar a discussão em sala.

### 6. Alta hospitalar (simulada)

Tela de **Alta**:

- Exibe orientações gerais simuladas para o paciente.
- Possui botão para **remover o paciente** do Firestore, incluindo seus acompanhamentos.
- Após remover, retorna à tela inicial.

```

Principais pacotes utilizados:

- `flutter` (SDK)
- `firebase_core`
- `cloud_firestore`
- `shared_preferences`

---

## Como executar o projeto

### Pré-requisitos

- Flutter instalado (canal stable).
- Conta Firebase configurada para Web/Windows, com `firebase_options.dart` gerado.
- Para Web: navegador (Chrome ou Edge).
- Para Windows:
  - Visual Studio com workload **“Desktop development with C++”**.
  - Modo de Desenvolvedor habilitado no Windows.

### Passos gerais

Na pasta do projeto:

```bash
flutter clean
flutter pub get
```

### Executar no navegador (Web)

```bash
flutter config --enable-web
flutter run -d chrome   # ou -d edge
```

### Executar como app de Windows

```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

Observação: mensagens relacionadas a Android/Gradle podem aparecer no editor. Se o foco da entrega não inclui Android, essas mensagens podem ser ignoradas nesta fase.

---

## Testes

Caso existam testes de widget adicionais, eles podem ser executados com:

```bash
flutter test
```

---

## Limitações e próximos passos

Algumas simplificações importantes:

- A decisão entre **apenas correção**, **basal/bôlus** e **basal/correção** ainda não está totalmente automatizada; o protótipo assume cenário de **dieta oral em esquema basal/bôlus** para o cálculo detalhado.
- A lógica para pacientes em **NPO** ou em **nutrição enteral/parenteral** está apenas descrita de forma genérica, não implementada em regras completas.
- O manejo de **hipoglicemia** é resumido em orientações textuais, sem árvore de decisão clínica detalhada.

Possíveis evoluções:

- Extrair a lógica de cálculo para uma **camada de domínio** separada (testável de forma isolada).
- Implementar estados com Riverpod ou outro gerenciador de estado.
- Ampliar a cobertura de cenários (NPO, enteral/parenteral, insulinoterapia prévia complexa).
- Melhorar responsividade para telas muito estreitas e suporte a tema escuro.
- Aprofundar a suíte de testes (unitários e de widget).

---

## Aviso importante

Este projeto tem **caráter exclusivamente acadêmico/didático**.  
Não substitui protocolos institucionais, diretrizes científicas ou julgamento clínico individualizado.

---

## Equipe

- **Pedro Henrique Scheidt**
- **Vinícius Minas**
- **Professor:** Sandro Alencar Fernandes  
  Projeto de Extensão – Desenvolvimento para Plataformas Móveis
