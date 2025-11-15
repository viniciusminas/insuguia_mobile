import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/download.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InsuGuia (Protótipo Didático)',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.02),
        ),
        child: child!,
      ),
      home: const HomePage(),
    );
  }
}

// ==================== MODELOS SIMPLES ====================
class Patient {
  final String nome;
  final String sexo; // 'Masculino', 'Feminino', 'Outro/Prefere não informar'
  final int idade; // anos
  final double pesoKg;
  final double alturaCm;
  final double creatinina; // mg/dL (apenas exibida nesta versão)
  final String local; // Enfermaria, UTI, Ambulatório
  final String cenario; // Não crítico (com cálculo) | Outros (sem cálculo)

  const Patient({
    required this.nome,
    required this.sexo,
    required this.idade,
    required this.pesoKg,
    required this.alturaCm,
    required this.creatinina,
    required this.local,
    required this.cenario,
  });
}

class GlycemiaReading {
  final String momento; // AC Café, AC Almoço, AC Jantar, HS, 03:00
  final double valor;
  final DateTime ts;

  GlycemiaReading({
    required this.momento,
    required this.valor,
    DateTime? ts,
  }) : ts = ts ?? DateTime.now();
}

// ==================== HOME ====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('InsuGuia — Protótipo Didático')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer.withAlpha((0.35 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '⚠️ Uso didático. Não é um dispositivo médico. Não utilizar para decisões clínicas.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('InsuGuia Mobile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        Text('Protótipo acadêmico (Flutter) para simular uma sugestão inicial em cenário NÃO CRÍTICO.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Novo paciente'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PatientFormPage()),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Sobre'),
                  onPressed: () => showAboutDialog(
                    context: context,
                    applicationName: 'InsuGuia (Protótipo Didático)',
                    applicationVersion: 'Sprint continuidade — 2025',
                    children: const [
                      Text('Este app é uma prova de conceito para fins educacionais.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== FORMULÁRIO DO PACIENTE ====================
class PatientFormPage extends StatefulWidget {
  const PatientFormPage({super.key});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();
  final _creatCtrl = TextEditingController();

  String _sexo = 'Masculino';
  String _local = 'Enfermaria';
  String _cenario = 'Não crítico';

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final sp = await SharedPreferences.getInstance();
    _nomeCtrl.text = sp.getString('draft_nome') ?? '';
    _idadeCtrl.text = sp.getString('draft_idade') ?? '';
    _pesoCtrl.text = sp.getString('draft_peso') ?? '';
    _alturaCtrl.text = sp.getString('draft_altura') ?? '';
    _creatCtrl.text = sp.getString('draft_creat') ?? '';
    setState(() {
      _sexo = sp.getString('draft_sexo') ?? _sexo;
      _local = sp.getString('draft_local') ?? _local;
      _cenario = sp.getString('draft_cenario') ?? _cenario;
    });
  }

  Future<void> _saveDraft() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('draft_nome', _nomeCtrl.text);
    await sp.setString('draft_idade', _idadeCtrl.text);
    await sp.setString('draft_peso', _pesoCtrl.text);
    await sp.setString('draft_altura', _alturaCtrl.text);
    await sp.setString('draft_creat', _creatCtrl.text);
    await sp.setString('draft_sexo', _sexo);
    await sp.setString('draft_local', _local);
    await sp.setString('draft_cenario', _cenario);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
    _creatCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;

    final p = Patient(
      nome: _nomeCtrl.text.trim(),
      sexo: _sexo,
      idade: int.tryParse(_idadeCtrl.text) ?? 0,
      pesoKg: double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0,
      alturaCm: double.tryParse(_alturaCtrl.text.replaceAll(',', '.')) ?? 0,
      creatinina: double.tryParse(_creatCtrl.text.replaceAll(',', '.')) ?? 0,
      local: _local,
      cenario: _cenario,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SuggestionPage(patient: p)),
    );
  }

  InputDecoration _dec(String label, {String? helper}) => InputDecoration(
        labelText: label,
        helperText: helper,
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro do Paciente')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomeCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: _dec('Nome (fictício)'),
                    onChanged: (_) => _saveDraft(),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sexo,
                        items: const [
                          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                          DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                          DropdownMenuItem(value: 'Outro/Prefere não informar', child: Text('Outro/Prefere não informar')),
                        ],
                        onChanged: (v) { setState(() => _sexo = v!); _saveDraft(); },
                        decoration: _dec('Sexo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _idadeCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _dec('Idade (anos)') ,
                        onChanged: (_) => _saveDraft(),
                        validator: (v) {
                          final i = int.tryParse(v ?? '');
                          if (i == null || i < 0 || i > 120) return '0–120';
                          return null;
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pesoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                        decoration: _dec('Peso (kg)', helper: 'Ex.: 72,5'),
                        onChanged: (_) => _saveDraft(),
                        validator: (v) {
                          final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                          if (x == null || x <= 0 || x > 400) return '1–400 kg';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _alturaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                        decoration: _dec('Altura (cm)', helper: 'Ex.: 170'),
                        onChanged: (_) => _saveDraft(),
                        validator: (v) {
                          final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                          if (x == null || x <= 0 || x > 250) return '50–250 cm';
                          return null;
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _creatCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                    decoration: _dec('Creatinina (mg/dL)', helper: 'Usada apenas como dado exibido nesta versão'),
                    onChanged: (_) => _saveDraft(),
                    validator: (v) {
                      final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                      if (x == null || x < 0 || x > 20) return '0–20 mg/dL';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _local,
                        items: const [
                          DropdownMenuItem(value: 'Enfermaria', child: Text('Enfermaria')),
                          DropdownMenuItem(value: 'UTI', child: Text('UTI')),
                          DropdownMenuItem(value: 'Ambulatório', child: Text('Ambulatório')),
                        ],
                        onChanged: (v) { setState(() => _local = v!); _saveDraft(); },
                        decoration: _dec('Local de internação'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _cenario,
                        items: const [
                          DropdownMenuItem(value: 'Não crítico', child: Text('Não crítico')), // cálculo habilitado
                          DropdownMenuItem(value: 'Outro (sem cálculo)', child: Text('Outro (sem cálculo)')),
                        ],
                        onChanged: (v) { setState(() => _cenario = v!); _saveDraft(); },
                        decoration: _dec('Classificação clínica'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Gerar sugestão (simulado)'),
                    onPressed: _proceed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== SUGESTÃO ====================
class SuggestionPage extends StatelessWidget {
  final Patient patient;
  const SuggestionPage({super.key, required this.patient});

  String _buildSuggestion() {
    final b = StringBuffer();
    b.writeln('InsuGuia — Sugestão (SIMULADO)\n');
    b.writeln('Paciente: ${patient.nome} | Sexo: ${patient.sexo} | Idade: ${patient.idade}');
    b.writeln('Cenário: ${patient.cenario} | Peso: ${patient.pesoKg.toStringAsFixed(1)} kg | Altura: ${patient.alturaCm.toStringAsFixed(0)} cm');
    b.writeln('Creatinina: ${patient.creatinina.toStringAsFixed(2)} mg/dL | Local: ${patient.local}\n');

    // Cálculo SIMPLIFICADO: apenas quando Não crítico
    double? basal;
    if (patient.cenario == 'Não crítico') {
      basal = (patient.pesoKg * 0.2).clamp(0, 100);
    }

    b.writeln('1) Dieta: conforme avaliação da equipe (simulado).');
    b.writeln('2) Monitorização: glicemias AC/HS; considerar 03:00 se necessário (simulado).');
    if (basal != null) {
      b.writeln('3) Basal: dose inicial sugerida (simulada): ${basal.toStringAsFixed(1)} UI SC à noite (0,2 UI/kg).');
    } else {
      b.writeln('3) Basal: não calculado para este cenário (simulado).');
    }
    b.writeln('4) Insulina de ação rápida: correção conforme faixa (simulado).');
    b.writeln('5) Hipoglicemia: seguir protocolo institucional (simulado).');
    b.writeln('\n⚠️ Conteúdo didático. Não utilizar para decisões clínicas.');
    return b.toString();
  }

  void _copiar(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _buildSuggestion()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Texto copiado para a área de transferência.')),
      );
    }
  }

  void _baixarTxt() {
    downloadTxt(_buildSuggestion(), 'sugestao_${patient.nome}.txt');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final texto = _buildSuggestion();

    return Scaffold(
      appBar: AppBar(title: const Text('Sugestão (Simulado)')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(texto),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.copy_all),
                      label: const Text('Copiar sugestão'),
                      onPressed: () => _copiar(context),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Baixar .txt'),
                      onPressed: _baixarTxt,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.monitor_heart),
                      label: const Text('Acompanhamento diário (simulado)'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FollowUpPage(patient: patient)),
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.local_hospital),
                      label: const Text('Alta hospitalar (simulado)'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DischargePage(patient: patient)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer.withAlpha((0.35 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Este é um protótipo educacional. Não possui validade clínica.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ACOMPANHAMENTO DIÁRIO (SIMULADO) ====================
class FollowUpPage extends StatefulWidget {
  final Patient patient;
  const FollowUpPage({super.key, required this.patient});

  @override
  State<FollowUpPage> createState() => _FollowUpPageState();
}

class _FollowUpPageState extends State<FollowUpPage> {
  final _valorCtrl = TextEditingController();
  String _momento = 'AC Café';
  final List<GlycemiaReading> _leituras = [];

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  void _adicionar() {
    final v = double.tryParse(_valorCtrl.text.replaceAll(',', '.'));
    if (v == null || v <= 0) return;
    setState(() {
      _leituras.add(GlycemiaReading(momento: _momento, valor: v));
      _valorCtrl.clear();
    });
  }

  String _sugestaoAjuste() {
    if (_leituras.isEmpty) return 'Sem leituras até o momento.';
    // regra SIMPLIFICADA para demo
    // média de jejum (AC Café) -> ajuste basal 10% para cima se >180; para baixo se <70
    final jejum = _leituras.where((e) => e.momento == 'AC Café').map((e) => e.valor).toList();
    double? mediaJejum;
    if (jejum.isNotEmpty) {
      mediaJejum = jejum.reduce((a, b) => a + b) / jejum.length;
    }

    if (mediaJejum != null) {
      if (mediaJejum > 180) {
        return 'Média de jejum: ${mediaJejum.toStringAsFixed(0)} mg/dL → considerar ↑ basal em ~10% (simulado).';
      } else if (mediaJejum < 70) {
        return 'Média de jejum: ${mediaJejum.toStringAsFixed(0)} mg/dL → considerar ↓ basal em ~10% (simulado).';
      } else {
        return 'Média de jejum: ${mediaJejum.toStringAsFixed(0)} mg/dL → manter dose basal (simulado).';
      }
    }

    // fallback
    return 'Colete leituras AC/HS para sugerir ajustes (simulado).';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acompanhamento diário (simulado)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _momento,
                      items: const [
                        DropdownMenuItem(value: 'AC Café', child: Text('AC Café')),
                        DropdownMenuItem(value: 'AC Almoço', child: Text('AC Almoço')),
                        DropdownMenuItem(value: 'AC Jantar', child: Text('AC Jantar')),
                        DropdownMenuItem(value: 'HS', child: Text('HS (ao deitar)')),
                        DropdownMenuItem(value: '03:00', child: Text('03:00 (se necessário)')),
                      ],
                      onChanged: (v) => setState(() => _momento = v!),
                      decoration: const InputDecoration(
                        labelText: 'Momento',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _valorCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                      decoration: const InputDecoration(
                        labelText: 'Glicemia (mg/dL)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                    onPressed: _adicionar,
                  ),
                ]),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: ListView.separated(
                      itemCount: _leituras.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final e = _leituras[i];
                        return ListTile(
                          leading: const Icon(Icons.bloodtype_outlined),
                          title: Text('${e.momento} — ${e.valor.toStringAsFixed(0)} mg/dL'),
                          subtitle: Text('${e.ts.hour.toString().padLeft(2,'0')}:${e.ts.minute.toString().padLeft(2,'0')}'),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.secondaryContainer.withAlpha((0.25 * 255).round()),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(_sugestaoAjuste()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ALTA (SIMULADO) ====================
class DischargePage extends StatelessWidget {
  final Patient patient;
  const DischargePage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final orientacoes = [
      'Orientações gerais — SIMULADO:\n',
      '• Manter acompanhamento ambulatorial conforme equipe.\n',
      '• Educar sobre sinais de hipoglicemia e condutas (15–15).\n',
      '• Revisar técnica de aplicação e locais de aplicação.\n',
      '• Plano de monitorização domiciliar (AC/HS) — simulado.\n',
      '• Reforçar que este app é didático e não substitui conduta clínica.\n',
    ].join('\n');

    return Scaffold(
      appBar: AppBar(title: const Text('Alta hospitalar (simulado)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(orientacoes),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
