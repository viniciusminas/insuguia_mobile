import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/download.dart'; //para baixar .txt (web)

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
  // Aumenta levemente a tipografia sem tocar no TextTheme (evita o assert)
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
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ Uso didático. Não é um dispositivo médico. '
                          'Não utilizar para decisões clínicas.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),

                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'InsuGuia Mobile',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Protótipo acadêmico (Flutter) para simular uma sugestão inicial de '
                          'manejo de glicemia em paciente NÃO CRÍTICO.',
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
                    applicationVersion: 'Entrega 2 — 05/11/2025',
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
  void initState() {
    super.initState();
    _carregarRascunho(); // <- persistência leve (rascunho)
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarRascunho() async {
    final sp = await SharedPreferences.getInstance();
    _nomeCtrl.text = sp.getString('draft_nome') ?? '';
    _pesoCtrl.text = sp.getString('draft_peso') ?? '';
  }

  Future<void> _salvarRascunho() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('draft_nome', _nomeCtrl.text);
    await sp.setString('draft_peso', _pesoCtrl.text);
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
                    onChanged: (_) => _salvarRascunho(),
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
                    // Máscara simples: permite dígitos, vírgula e ponto
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                    ],
                    onChanged: (_) => _salvarRascunho(),
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      helperText: 'Ex.: 72,5',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final vv = double.tryParse((v ?? '').replaceAll(',', '.'));
                      if (vv == null || vv <= 0 || vv > 400) {
                        return 'Informe um peso entre 1 e 400 kg';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _cenario,
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

  void _baixarTxt() {
    final texto = _textoSugestao();
    downloadTxt(texto, 'sugestao_${args.nome}.txt');
  }

@override
Widget build(BuildContext context) {
  final texto = _textoSugestao();
  final cs = Theme.of(context).colorScheme;

  return Scaffold(
    appBar: AppBar(title: const Text('Sugestão (Simulado)')),
    body: Center(
      child: SingleChildScrollView(           
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
                  child: Semantics(
                    label: 'Texto com a sugestão simulada',
                    child: Text(texto),
                  ),
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
                  FilledButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Baixar .txt'),
                    onPressed: _baixarTxt,
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
