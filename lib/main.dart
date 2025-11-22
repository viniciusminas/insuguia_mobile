import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'utils/download.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.grey.shade50,
          foregroundColor: Colors.black87,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
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

class _SlideInState extends State<SlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary,
              cs.primary.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 2,
            shape: const StadiumBorder(),
          ),
          icon: Icon(icon, size: 18, color: Colors.white),
          label: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class Patient {
  final String id;
  final String nome;
  final String sexo;
  final int idade;
  final double pesoKg;
  final double alturaCm;
  final double creatinina;
  final String local;
  final String cenario;

  const Patient({
    this.id = '',
    required this.nome,
    required this.sexo,
    required this.idade,
    required this.pesoKg,
    required this.alturaCm,
    required this.creatinina,
    required this.local,
    required this.cenario,
  });

  Patient copyWith({
    String? id,
    String? nome,
    String? sexo,
    int? idade,
    double? pesoKg,
    double? alturaCm,
    double? creatinina,
    String? local,
    String? cenario,
  }) {
    return Patient(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sexo: sexo ?? this.sexo,
      idade: idade ?? this.idade,
      pesoKg: pesoKg ?? this.pesoKg,
      alturaCm: alturaCm ?? this.alturaCm,
      creatinina: creatinina ?? this.creatinina,
      local: local ?? this.local,
      cenario: cenario ?? this.cenario,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'sexo': sexo,
      'idade': idade,
      'pesoKg': pesoKg,
      'alturaCm': alturaCm,
      'creatinina': creatinina,
      'local': local,
      'cenario': cenario,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Patient.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Patient(
      id: doc.id,
      nome: (data['nome'] ?? '') as String,
      sexo: (data['sexo'] ?? '') as String,
      idade: (data['idade'] is int)
          ? data['idade'] as int
          : int.tryParse('${data['idade']}') ?? 0,
      pesoKg: (data['pesoKg'] is num)
          ? (data['pesoKg'] as num).toDouble()
          : double.tryParse('${data['pesoKg']}') ?? 0,
      alturaCm: (data['alturaCm'] is num)
          ? (data['alturaCm'] as num).toDouble()
          : double.tryParse('${data['alturaCm']}') ?? 0,
      creatinina: (data['creatinina'] is num)
          ? (data['creatinina'] as num).toDouble()
          : double.tryParse('${data['creatinina']}') ?? 0,
      local: (data['local'] ?? '') as String,
      cenario: (data['cenario'] ?? '') as String,
    );
  }
}

class GlycemiaReading {
  final String id;
  final String momento;
  final double valor;
  final DateTime ts;

  GlycemiaReading({
    this.id = '',
    required this.momento,
    required this.valor,
    DateTime? ts,
  }) : ts = ts ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'momento': momento,
      'valor': valor,
      'ts': Timestamp.fromDate(ts),
    };
  }

  factory GlycemiaReading.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return GlycemiaReading(
      id: doc.id,
      momento: (data['momento'] ?? '') as String,
      valor: (data['valor'] is num)
          ? (data['valor'] as num).toDouble()
          : double.tryParse('${data['valor']}') ?? 0,
      ts: (data['ts'] is Timestamp)
          ? (data['ts'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

// Referências e helpers do Firebase/Firestore
final CollectionReference<Map<String, dynamic>> pacientesRef =
    FirebaseFirestore.instance.collection('pacientes');

Future<String> createPatientInFirestore(Patient patient) async {
  final docRef = await pacientesRef.add(patient.toMap());
  return docRef.id;
}

Future<void> deletePatientWithFollowUps(String patientId) async {
  final docRef = pacientesRef.doc(patientId);
  final followUpsSnap =
      await docRef.collection('acompanhamentos').get();

  for (final d in followUpsSnap.docs) {
    await d.reference.delete();
  }

  await docRef.delete();
}

Future<void> addFollowUpReading(
    String patientId, GlycemiaReading reading) async {
  final docRef = pacientesRef.doc(patientId);
  await docRef.collection('acompanhamentos').add(reading.toMap());
}

//Home
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
                // Header
                SlideIn(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withOpacity(0.08),
                          cs.secondary.withOpacity(0.05)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: cs.primaryContainer,
                          child: Icon(Icons.medical_services,
                              color: cs.onPrimaryContainer),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'InsuGuia Mobile',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Protótipo acadêmico para manejo inicial em cenário NÃO CRÍTICO.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Aviso
                SlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange[800]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Uso exclusivamente didático. Não utilizar para decisões clínicas.',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                //Botões
                SlideIn(
                  delay: const Duration(milliseconds: 220),
                  child: Column(
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: 260),
                          child: GradientButton(
                            icon: Icons.person_add_alt_1_rounded,
                            text: 'Iniciar novo paciente',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const PatientFormPage()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: 260),
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.info_outline_rounded,
                                  size: 18),
                              label: const Text('Sobre'),
                              onPressed: () => showAboutDialog(
                                context: context,
                                applicationName:
                                    'InsuGuia (Protótipo Didático)',
                                applicationVersion:
                                    'Versão Acadêmica — 2025',
                                applicationIcon:
                                    const Icon(Icons.medical_services),
                                children: const [
                                  Text(
                                      'Este aplicativo é uma prova de conceito educacional.'),
                                  Text(
                                      'Não utilizar este protótipo para decisões clínicas reais.'),
                                ],
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                              ),
                            ),
                          ),
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

// Formulário do paciente
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

  void _proceed() async {
    if (!_formKey.currentState!.validate()) return;

    final p = Patient(
      nome: _nomeCtrl.text.trim(),
      sexo: _sexo,
      idade: int.tryParse(_idadeCtrl.text) ?? 0,
      pesoKg: double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0,
      alturaCm:
          double.tryParse(_alturaCtrl.text.replaceAll(',', '.')) ?? 0,
      creatinina:
          double.tryParse(_creatCtrl.text.replaceAll(',', '.')) ?? 0,
      local: _local,
      cenario: _cenario,
    );

    try {
      final id = await createPatientInFirestore(p);
      final patientWithId = p.copyWith(id: id);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SuggestionPage(patient: patientWithId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar paciente: $e')),
      );
    }
  }

  InputDecoration _dec(String label,
          {String? helper, String? suffix}) =>
      InputDecoration(
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
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Informe um nome'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sexo,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Masculino',
                                  child: Text('Masculino')),
                              DropdownMenuItem(
                                  value: 'Feminino',
                                  child: Text('Feminino')),
                            ],
                            onChanged: (v) {
                              setState(() => _sexo = v ?? _sexo);
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: _dec('Idade (anos)'),
                            onChanged: (_) => _saveDraft(),
                            validator: (v) {
                              final i = int.tryParse(v ?? '');
                              if (i == null || i < 0 || i > 120) {
                                return '0–120';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pesoCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9,\\.]'))
                            ],
                            decoration: _dec('Peso (kg)'),
                            onChanged: (_) => _saveDraft(),
                            validator: (v) {
                              final x = double.tryParse(
                                  (v ?? '').replaceAll(',', '.'));
                              if (x == null || x < 20 || x > 250) {
                                return '20–250 kg';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _alturaCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9,\\.]'))
                            ],
                            decoration: _dec('Altura (cm)'),
                            onChanged: (_) => _saveDraft(),
                            validator: (v) {
                              final x = double.tryParse(
                                  (v ?? '').replaceAll(',', '.'));
                              if (x == null || x < 100 || x > 230) {
                                return '100–230 cm';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideIn(
                    delay: const Duration(milliseconds: 260),
                    child: TextFormField(
                      controller: _creatCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9,\\.]'))
                      ],
                      decoration: _dec(
                        'Creatinina (mg/dL)',
                        helper:
                            'Usada apenas como dado exibido nesta versão',
                        suffix: 'mg/dL',
                      ),
                      onChanged: (_) => _saveDraft(),
                      validator: (v) {
                        final x = double.tryParse(
                            (v ?? '').replaceAll(',', '.'));
                        if (x == null || x < 0 || x > 20) {
                          return '0–20 mg/dL';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _local,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Enfermaria',
                                  child: Text('Enfermaria')),
                              DropdownMenuItem(
                                  value: 'UTI', child: Text('UTI')),
                              DropdownMenuItem(
                                  value: 'Ambulatório',
                                  child: Text('Ambulatório')),
                            ],
                            onChanged: (v) {
                              setState(() => _local = v ?? _local);
                              _saveDraft();
                            },
                            decoration: _dec('Local'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _cenario,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Não crítico',
                                  child: Text('Não crítico')),
                              DropdownMenuItem(
                                  value: 'Crítico', child: Text('Crítico')),
                            ],
                            onChanged: (v) {
                              setState(() => _cenario = v ?? _cenario);
                              _saveDraft();
                            },
                            decoration: _dec('Cenário'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SlideIn(
                    delay: const Duration(milliseconds: 360),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.task_alt_rounded),
                        label: const Text('Gerar sugestão (simulado)'),
                        onPressed: _proceed,
                      ),
                    ),
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

// Resultado
class SuggestionPage extends StatelessWidget {
  final Patient patient;
  const SuggestionPage({super.key, required this.patient});

  String _buildSuggestion() {
    final b = StringBuffer();
    b.writeln('InsuGuia — Sugestão (SIMULADO)\\n');
    b.writeln(
        'Paciente: ${patient.nome} | Sexo: ${patient.sexo} | Idade: ${patient.idade}');
    b.writeln(
        'Cenário: ${patient.cenario} | Peso: ${patient.pesoKg.toStringAsFixed(1)} kg | Altura: ${patient.alturaCm.toStringAsFixed(0)} cm');
    b.writeln(
        'Creatinina: ${patient.creatinina.toStringAsFixed(2)} mg/dL | Local: ${patient.local}\\n');

    double? basal;
    if (patient.cenario == 'Não crítico') {
      basal = (patient.pesoKg * 0.2).clamp(0, 100);
    }

    b.writeln('1) Dieta: conforme avaliação da equipe (simulado).');
    b.writeln(
        '2) Monitorização: glicemias AC/HS; considerar 03:00 se necessário (simulado).');
    if (basal != null) {
      b.writeln(
          '3) Basal: dose inicial sugerida (simulada): ${basal.toStringAsFixed(1)} UI SC à noite (0,2 UI/kg).');
    } else {
      b.writeln(
          '3) Basal: definir conforme protocolo específico e avaliação clínica (simulado).');
    }
    b.writeln(
        '4) Correções: considerar esquema de correção conforme protocolo local (simulado).');
    b.writeln(
        '5) Reavaliar diariamente e ajustar conforme glicemias (simulado).');

    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final texto = _buildSuggestion();
    return Scaffold(
      appBar: AppBar(title: const Text('Sugestão (simulada)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SlideIn(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      texto,
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Baixar .txt'),
                        onPressed: () => downloadTxt(
                          texto,                      // conteúdo do arquivo
                          'sugestao_insuguia.txt',    // nome do arquivo
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.monitor_heart),
                        label: const Text(
                            'Acompanhamento diário (simulado)'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  FollowUpPage(patient: patient)),
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.local_hospital),
                        label: const Text('Alta hospitalar (simulado)'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  DischargePage(patient: patient)),
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Novo paciente'),
                        onPressed: () => Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '⚠️ Conteúdo apenas ilustrativo. Não substitui protocolos ou julgamento clínico.',
                  style:
                      TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    if (widget.patient.id.isNotEmpty) {
      _subscription = pacientesRef
          .doc(widget.patient.id)
          .collection('acompanhamentos')
          .orderBy('ts', descending: true)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _leituras
            ..clear()
            ..addAll(
              snapshot.docs
                  .map(
                    (doc) => GlycemiaReading.fromFirestore(
                        doc as DocumentSnapshot<Map<String, dynamic>>),
                  )
                  .toList(),
            );
        });
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _valorCtrl.dispose();
    super.dispose();
  }

  void _adicionar() async {
    final v = double.tryParse(_valorCtrl.text.replaceAll(',', '.'));
    if (v == null || v <= 0) return;

    if (widget.patient.id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Paciente sem ID, não é possível salvar acompanhamento.'),
        ),
      );
      return;
    }

    final leitura = GlycemiaReading(momento: _momento, valor: v);

    try {
      await addFollowUpReading(widget.patient.id, leitura);
      _valorCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar leitura: $e')),
      );
    }
  }

  String _sugestaoAjuste() {
    if (_leituras.isEmpty) return 'Sem leituras até o momento.';
    final jejum = _leituras
        .where((e) => e.momento == 'AC Café')
        .map((e) => e.valor)
        .toList();
    double? mediaJejum;
    if (jejum.isNotEmpty) {
      mediaJejum =
          jejum.reduce((a, b) => a + b) / jejum.length;
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
      appBar:
          AppBar(title: const Text('Acompanhamento diário (simulado)')),
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
                        DropdownMenuItem(
                            value: 'AC Café', child: Text('AC Café')),
                        DropdownMenuItem(
                            value: 'AC Almoço', child: Text('AC Almoço')),
                        DropdownMenuItem(
                            value: 'AC Jantar', child: Text('AC Jantar')),
                        DropdownMenuItem(
                            value: 'HS', child: Text('HS (ao deitar)')),
                        DropdownMenuItem(
                            value: '03:00',
                            child: Text('03:00 (se necessário)')),
                      ],
                      onChanged: (v) => setState(() => _momento = v!),
                      decoration:
                          const InputDecoration(labelText: 'Momento'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _valorCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9,\\.]'))
                      ],
                      decoration: const InputDecoration(
                          labelText: 'Glicemia (mg/dL)'),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: _leituras.isEmpty
                        ? const Center(
                            child: Text('Sem leituras ainda.'),
                          )
                        : ListView.separated(
                            itemCount: _leituras.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final e = _leituras[i];
                              return ListTile(
                                leading: Icon(Icons.bloodtype_outlined,
                                    color: cs.primary),
                                title: Text(
                                    '${e.momento} — ${e.valor.toStringAsFixed(0)} mg/dL'),
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
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: cs.onSecondaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _sugestaoAjuste(),
                          style: TextStyle(
                            color: cs.onSecondaryContainer,
                          ),
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

class DischargePage extends StatelessWidget {
  final Patient patient;
  const DischargePage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orientacoes = [
      'Orientações gerais — SIMULADO:\\n',
      '• Manter acompanhamento ambulatorial conforme equipe.\\n',
      '• Educar sobre sinais de hipoglicemia e condutas (15–15).\\n',
      '• Revisar técnica de aplicação e locais de aplicação.\\n',
      '• Plano de monitorização domiciliar (AC/HS) — simulado.\\n',
      '• Reforçar que este app é didático e não substitui conduta clínica.\\n',
    ].join('\\n');

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(orientacoes),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label:
                        const Text('Concluir alta e remover paciente'),
                    onPressed: patient.id.isEmpty
                        ? null
                        : () async {
                            try {
                              await deletePatientWithFollowUps(
                                  patient.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Paciente removido com sucesso.'),
                                  ),
                                );
                                Navigator.of(context).popUntil(
                                    (route) => route.isFirst);
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Erro ao remover paciente: $e'),
                                ),
                              );
                            }
                          },
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
