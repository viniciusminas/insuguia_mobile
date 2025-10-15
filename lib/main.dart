import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('InsuGuia Mobile',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        Text(
                          'Protótipo acadêmico (Flutter) para simular uma sugestão inicial de manejo de glicemia em paciente NÃO CRÍTICO.',
                        ),
                        SizedBox(height: 8),
                        Text(
                          '⚠️ Uso didático. Não é um dispositivo médico. Não utilizar para decisões clínicas.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
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
                    applicationVersion: 'Entrega 1 — 15/10/2025',
                    children: const [
                      Text('Projeto de Extensão — Desenvolvimento para Plataformas Móveis.'),
                      Text('Este app é apenas uma prova de conceito para fins educacionais.'),
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

class PatientFormPage extends StatefulWidget {
  const PatientFormPage({super.key});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  String _cenario = 'Não crítico';

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  void _gerarSugestao() {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeCtrl.text.trim();
    final peso = double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0;

    final doseBasal = (peso * 0.2).clamp(0, 100).toStringAsFixed(1); // SIMULADO

    final args = SugestaoArgs(
      nome: nome,
      cenario: _cenario,
      pesoKg: peso,
      doseBasalSimulada: doseBasal,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SuggestionPage(args: args)),
    );
  }

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
                    decoration: const InputDecoration(
                      labelText: 'Nome (fictício)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pesoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final vv = double.tryParse((v ?? '').replaceAll(',', '.'));
                      if (vv == null || vv <= 0) return 'Informe um peso válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _cenario, // evita o aviso deprecado do 'value'
                    items: const [
                      DropdownMenuItem(value: 'Não crítico', child: Text('Não crítico')),
                    ],
                    onChanged: (v) => setState(() => _cenario = v ?? 'Não crítico'),
                    decoration: const InputDecoration(
                      labelText: 'Cenário',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Gerar sugestão (simulado)'),
                    onPressed: _gerarSugestao,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ Resultado apenas para fins acadêmicos. Não utilizar em decisões clínicas.',
                    style: TextStyle(fontStyle: FontStyle.italic),
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

class SugestaoArgs {
  final String nome;
  final String cenario;
  final double pesoKg;
  final String doseBasalSimulada;
  const SugestaoArgs({
    required this.nome,
    required this.cenario,
    required this.pesoKg,
    required this.doseBasalSimulada,
  });
}

class SuggestionPage extends StatelessWidget {
  final SugestaoArgs args;
  const SuggestionPage({super.key, required this.args});

  String _textoSugestao() {
    return [
      'InsuGuia — Sugestão (SIMULADO)\n',
      'Paciente: ${args.nome} | Cenário: ${args.cenario} | Peso: ${args.pesoKg.toStringAsFixed(1)} kg\n',
      '1) Dieta: conforme avaliação da equipe (simulado).',
      '2) Monitorização: glicemias AC/HS; considerar 03:00 se necessário (simulado).',
      '3) Basal: dose inicial sugerida (simulada): ${args.doseBasalSimulada} UI SC à noite.',
      '4) Insulina de ação rápida: correção conforme faixa (simulado).',
      '5) Hipoglicemia: seguir protocolo institucional (simulado).',
      '\n⚠️ Conteúdo didático. Não utilizar para decisões clínicas.'
    ].join('\n');
  }

  void _copiar(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _textoSugestao()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Texto copiado para a área de transferência.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = _textoSugestao();
    return Scaffold(
      appBar: AppBar(title: const Text('Sugestão (Simulado)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
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
                Row(
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.copy_all),
                      label: const Text('Copiar sugestão'),
                      onPressed: () => _copiar(context),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Este é um protótipo educacional. Não possui validade clínica.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
