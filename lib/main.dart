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
    final color = const Color(0xFF1565C0); 
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InsuGuia (Protótipo Didático)',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        appBarTheme: const AppBarTheme(elevation: 0),
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

class SlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const SlideIn({super.key, required this.child, this.delay = Duration.zero});
  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(duration: const Duration(milliseconds: 550), vsync: this);
  late final Animation<Offset> _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, _c.forward);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SlideTransition(position: _slide, child: FadeTransition(opacity: _c, child: widget.child));
}

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  const GradientButton({super.key, required this.onPressed, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, cs.primaryContainer]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(220, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

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
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com ícone + gradient
                SlideIn(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cs.primary.withOpacity(0.08), cs.secondary.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: cs.primaryContainer,
                          child: Icon(Icons.medical_services, color: cs.onPrimaryContainer),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('InsuGuia Mobile',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                              SizedBox(height: 6),
                              Text('Protótipo acadêmico para manejo inicial em cenário NÃO CRÍTICO.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Aviso didático destacado
                SlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Uso exclusivamente didático. Não utilizar para decisões clínicas.',
                            style: TextStyle(color: Colors.orange[800], fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Botões
                SlideIn(
                  delay: const Duration(milliseconds: 220),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      GradientButton(
                        icon: Icons.person_add_alt_1,
                        text: 'Iniciar novo paciente',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PatientFormPage()),
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Sobre'),
                        onPressed: () => showAboutDialog(
                          context: context,
                          applicationName: 'InsuGuia (Protótipo Didático)',
                          applicationVersion: 'Versão Acadêmica — 2025',
                          applicationIcon: const Icon(Icons.medical_services),
                          children: const [
                            Text('Este aplicativo é uma prova de conceito educacional.'),
                          ],
                        ),
                      ),
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

  InputDecoration _dec(String label, {String? helper, String? suffix}) => InputDecoration(
        labelText: label,
        helperText: helper,
        suffixText: suffix,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro do Paciente')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SlideIn(
                    child: TextFormField(
                      controller: _nomeCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _dec('Nome (fictício)'),
                      onChanged: (_) => _saveDraft(),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _sexo,
                          items: const [
                            DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                            DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                            DropdownMenuItem(
                                value: 'Outro/Prefere não informar',
                                child: Text('Outro/Prefere não informar')),
                          ],
                          onChanged: (v) {
                            setState(() => _sexo = v!);
                            _saveDraft();
                          },
                          decoration: _dec('Sexo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _idadeCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _dec('Idade (anos)'),
                          onChanged: (_) => _saveDraft(),
                          validator: (v) {
                            final i = int.tryParse(v ?? '');
                            if (i == null || i < 0 || i > 120) return '0–120';
                            return null;
                          },
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  SlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pesoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                          decoration: _dec('Peso', helper: 'Ex.: 72,5', suffix: 'kg'),
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
                          decoration: _dec('Altura', helper: 'Ex.: 170', suffix: 'cm'),
                          onChanged: (_) => _saveDraft(),
                          validator: (v) {
                            final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                            if (x == null || x <= 0 || x > 250) return '50–250 cm';
                            return null;
                          },
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  SlideIn(
                    delay: const Duration(milliseconds: 240),
                    child: TextFormField(
                      controller: _creatCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                      decoration: _dec('Creatinina', helper: 'Usada apenas como dado exibido nesta versão', suffix: 'mg/dL'),
                      onChanged: (_) => _saveDraft(),
                      validator: (v) {
                        final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                        if (x == null || x < 0 || x > 20) return '0–20 mg/dL';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _local,
                          items: const [
                            DropdownMenuItem(value: 'Enfermaria', child: Text('Enfermaria')),
                            DropdownMenuItem(value: 'UTI', child: Text('UTI')),
                            DropdownMenuItem(value: 'Ambulatório', child: Text('Ambulatório')),
                          ],
                          onChanged: (v) {
                            setState(() => _local = v!);
                            _saveDraft();
                          },
                          decoration: _dec('Local de internação'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _cenario,
                          items: const [
                            DropdownMenuItem(value: 'Não crítico', child: Text('Não crítico')),
                            DropdownMenuItem(value: 'Outro (sem cálculo)', child: Text('Outro (sem cálculo)')),
                          ],
                          onChanged: (v) {
                            setState(() => _cenario = v!);
                            _saveDraft();
                          },
                          decoration: _dec('Classificação clínica'),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Gerar sugestão (simulado)'),
                    onPressed: _proceed,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '⚠️ Resultado didático. Não utilizar para decisões clínicas.',
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

class SuggestionPage extends StatelessWidget {
  final Patient patient;
  const SuggestionPage({super.key, required this.patient});

  String _buildSuggestion() {
    final b = StringBuffer();
    b.writeln('InsuGuia — Sugestão (SIMULADO)\n');
    b.writeln('Paciente: ${patient.nome} | Sexo: ${patient.sexo} | Idade: ${patient.idade}');
    b.writeln(
        'Cenário: ${patient.cenario} | Peso: ${patient.pesoKg.toStringAsFixed(1)} kg | Altura: ${patient.alturaCm.toStringAsFixed(0)} cm');
    b.writeln('Creatinina: ${patient.creatinina.toStringAsFixed(2)} mg/dL | Local: ${patient.local}\n');

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
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card com leve gradient de fundo
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary.withOpacity(0.06), cs.secondary.withOpacity(0.04)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(texto),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
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
                    color: cs.secondaryContainer.withOpacity(.35),
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
    // regra SIMPLIFICADA para demo — média de jejum (AC Café)
    final jejum =
        _leituras.where((e) => e.momento == 'AC Café').map((e) => e.valor).toList();
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

    return 'Colete leituras AC/HS para sugerir ajustes (simulado).';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Acompanhamento diário (simulado)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
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
                      decoration: const InputDecoration(labelText: 'Momento'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _valorCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                      decoration: const InputDecoration(labelText: 'Glicemia (mg/dL)'),
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
                    child: ListView.separated(
                      itemCount: _leituras.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final e = _leituras[i];
                        return ListTile(
                          leading: Icon(Icons.bloodtype_outlined, color: cs.primary),
                          title: Text('${e.momento} — ${e.valor.toStringAsFixed(0)} mg/dL'),
                          subtitle: Text(
                              '${e.ts.hour.toString().padLeft(2, '0')}:${e.ts.minute.toString().padLeft(2, '0')}'),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer.withOpacity(.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(_sugestaoAjuste()),
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
    final cs = Theme.of(context).colorScheme;
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
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Text(orientacoes),
            ),
          ),
        ),
      ),
    );
  }
}
