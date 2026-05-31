import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../models/materia.dart';
import '../models/sessao.dart';
import '../widgets/stat_card.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ApiService _apiService;
  List<Materia> _materias = [];
  List<SessaoEstudo> _sessoes = [];
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;
  int _selectedTab = 0;

  // Controllers para formulários
  final TextEditingController _novaMateriaController = TextEditingController();
  final TextEditingController _editMateriaController = TextEditingController();
  
  // Controllers para sessão
  int? _materiaSelecionadaId;
  double _horas = 1.0;
  final TextEditingController _anotacoesController = TextEditingController();
  DateTime _dataSessao = DateTime.now();
  
  // Estado de edição
  Materia? _materiaEditando;
  SessaoEstudo? _sessaoEditando;
  final TextEditingController _editSessaoAnotacoesController = TextEditingController();
  double _editSessaoHoras = 1.0;
  DateTime _editSessaoData = DateTime.now();
  int? _editSessaoMateriaId;

  @override
  void initState() {
    super.initState();
    _inicializarApi();
  }

  Future<void> _inicializarApi() async {
    final token = await ApiService.getToken();
    if (token == null) {
      _logout();
      return;
    }
    _apiService = ApiService(token: token);
    await _carregarDados();
  }

  void _showMessage(String message, {bool isError = false}) {
    setState(() {
      if (isError) {
        _errorMessage = message;
        _successMessage = null;
      } else {
        _successMessage = message;
        _errorMessage = null;
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
          _successMessage = null;
        });
      }
    });
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    
    final materias = await _apiService.getMaterias();
    final sessoes = await _apiService.getSessoes();
    
    setState(() {
      _materias = materias;
      _sessoes = sessoes;
      _calcularEstatisticas();
      _isLoading = false;
    });
  }

  void _calcularEstatisticas() {
    final totalHoras = _sessoes.fold(0.0, (sum, s) => sum + s.horasEstudadas);
    final totalSessoes = _sessoes.length;
    final mediaPorSessao = totalSessoes > 0 ? totalHoras / totalSessoes : 0.0;

    final hoje = DateTime.now();
    final horasHoje = _sessoes
        .where((s) => s.data.year == hoje.year && 
                      s.data.month == hoje.month && 
                      s.data.day == hoje.day)
        .fold(0.0, (sum, s) => sum + s.horasEstudadas);

    Map<int, double> materiaHoras = {};
    for (var sessao in _sessoes) {
      materiaHoras[sessao.materiaId] = 
          (materiaHoras[sessao.materiaId] ?? 0) + sessao.horasEstudadas;
    }

    String materiaMaisEstudada = '-';
    double maxHoras = 0;
    for (var entry in materiaHoras.entries) {
      if (entry.value > maxHoras) {
        maxHoras = entry.value;
        final materia = _materias.firstWhere(
          (m) => m.id == entry.key,
          orElse: () => Materia(id: 0, nome: ''),
        );
        materiaMaisEstudada = materia.nome;
      }
    }

    setState(() {
      _stats = DashboardStats(
        totalHoras: totalHoras,
        totalSessoes: totalSessoes,
        mediaPorSessao: mediaPorSessao,
        materiaMaisEstudada: materiaMaisEstudada,
        horasHoje: horasHoje,
      );
    });
  }

  Future<void> _criarMateria() async {
    final nome = _novaMateriaController.text.trim();
    if (nome.isEmpty) {
      _showMessage('Digite o nome da matéria', isError: true);
      return;
    }

    final novaMateria = await _apiService.createMateria(nome);
    if (novaMateria != null && mounted) {
      _novaMateriaController.clear();
      await _carregarDados();
      _showMessage('Matéria criada com sucesso!');
      setState(() => _selectedTab = 0);
    } else {
      _showMessage('Erro ao criar matéria', isError: true);
    }
  }

  Future<void> _atualizarMateria() async {
    if (_materiaEditando == null) return;

    final nome = _editMateriaController.text.trim();
    if (nome.isEmpty) {
      _showMessage('Digite o nome da matéria', isError: true);
      return;
    }

    final materiaAtualizada = await _apiService.updateMateria(
      _materiaEditando!.id!,
      nome,
    );
    
    if (materiaAtualizada != null && mounted) {
      setState(() => _materiaEditando = null);
      await _carregarDados();
      _showMessage('Matéria atualizada com sucesso!');
    } else {
      _showMessage('Erro ao atualizar matéria', isError: true);
    }
  }

  Future<void> _deletarMateria(Materia materia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Matéria'),
        content: Text(
          'Tem certeza que deseja excluir "${materia.nome}"? '
          'Todas as sessões relacionadas também serão excluídas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final sucesso = await _apiService.deleteMateria(materia.id!);
    if (sucesso && mounted) {
      await _carregarDados();
      _showMessage('Matéria excluída com sucesso!');
    } else {
      _showMessage('Erro ao excluir matéria', isError: true);
    }
  }

  Future<void> _criarSessao() async {
    if (_materiaSelecionadaId == null) {
      _showMessage('Selecione uma matéria', isError: true);
      return;
    }
    if (_horas <= 0) {
      _showMessage('Horas estudadas deve ser maior que 0', isError: true);
      return;
    }

    final novaSessao = SessaoEstudo(
      materiaId: _materiaSelecionadaId!,
      data: _dataSessao,
      horasEstudadas: _horas,
      anotacoes: _anotacoesController.text,
    );

    final sessaoCriada = await _apiService.createSessao(novaSessao);
    
    if (sessaoCriada != null && mounted) {
      _materiaSelecionadaId = null;
      _horas = 1.0;
      _anotacoesController.clear();
      _dataSessao = DateTime.now();
      await _carregarDados();
      _showMessage('Sessão registrada com sucesso!');
      setState(() => _selectedTab = 0);
    } else {
      _showMessage('Erro ao criar sessão', isError: true);
    }
  }

  Future<void> _atualizarSessao() async {
    if (_sessaoEditando == null) return;

    final sessaoAtualizada = _sessaoEditando!.copyWith(
      materiaId: _editSessaoMateriaId,
      data: _editSessaoData,
      horasEstudadas: _editSessaoHoras,
      anotacoes: _editSessaoAnotacoesController.text,
    );

    final resultado = await _apiService.updateSessao(
      _sessaoEditando!.id!,
      sessaoAtualizada,
    );
    
    if (resultado != null && mounted) {
      setState(() => _sessaoEditando = null);
      await _carregarDados();
      _showMessage('Sessão atualizada com sucesso!');
    } else {
      _showMessage('Erro ao atualizar sessão', isError: true);
    }
  }

  Future<void> _deletarSessao(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Sessão'),
        content: const Text('Tem certeza que deseja excluir esta sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final sucesso = await _apiService.deleteSessao(id);
    if (sucesso && mounted) {
      await _carregarDados();
      _showMessage('Sessão excluída com sucesso!');
    } else {
      _showMessage('Erro ao excluir sessão', isError: true);
    }
  }

  Future<void> _logout() async {
    await ApiService.removeToken();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  String _getMateriaNome(int materiaId) {
    final materia = _materias.firstWhere(
      (m) => m.id == materiaId,
      orElse: () => Materia(id: 0, nome: 'Carregando...'),
    );
    return materia.nome;
  }

  // Widgets do Dashboard
  Widget _buildGraficoSemanal() {
    final Map<String, double> horasPorDia = {
      'Seg': 0.0, 'Ter': 0.0, 'Qua': 0.0, 'Qui': 0.0, 'Sex': 0.0, 'Sáb': 0.0, 'Dom': 0.0,
    };

    for (var sessao in _sessoes) {
      final weekday = DateFormat('E', 'pt_BR').format(sessao.data);
      horasPorDia[weekday] = (horasPorDia[weekday] ?? 0) + sessao.horasEstudadas;
    }

    final days = horasPorDia.keys.toList();
    final spots = List.generate(
      days.length,
      (index) => FlSpot(index.toDouble(), horasPorDia[days[index]]!),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresso Semanal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withAlpha(25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltimasSessoes() {
    final ultimasSessoes = _sessoes.reversed.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas Sessões',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (ultimasSessoes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhuma sessão registrada',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() => _selectedTab = 4),
                        child: const Text('Registrar primeira sessão →'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ultimasSessoes.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final sessao = ultimasSessoes[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.book, color: Colors.blue),
                    ),
                    title: Text(
                      _getMateriaNome(sessao.materiaId),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(sessao.data)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${sessao.horasEstudadas}h',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        if (sessao.anotacoes.isNotEmpty)
                          Text(
                            sessao.anotacoes.length > 20
                                ? '${sessao.anotacoes.substring(0, 20)}...'
                                : sessao.anotacoes,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _carregarDados,
                tooltip: 'Atualizar',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Visão geral do seu progresso',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 5 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                title: 'Total Horas',
                value: '${_stats!.totalHoras}h',
                icon: Icons.trending_up,
                color: Colors.blue,
              ),
              StatCard(
                title: 'Total Sessões',
                value: '${_stats!.totalSessoes}',
                icon: Icons.bar_chart,
                color: Colors.green,
              ),
              StatCard(
                title: 'Média por Sessão',
                value: '${_stats!.mediaPorSessao.toStringAsFixed(1)}h',
                icon: Icons.timer,
                color: Colors.orange,
              ),
              StatCard(
                title: 'Horas Hoje',
                value: '${_stats!.horasHoje}h',
                icon: Icons.calendar_today,
                color: Colors.purple,
              ),
              if (isWide)
                StatCard(
                  title: 'Matéria + Estudada',
                  value: _stats!.materiaMaisEstudada,
                  icon: Icons.book,
                  color: Colors.pink,
                ),
            ],
          ),
          if (!isWide)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: StatCard(
                title: 'Matéria + Estudada',
                value: _stats!.materiaMaisEstudada,
                icon: Icons.book,
                color: Colors.pink,
              ),
            ),
          const SizedBox(height: 16),
          _buildGraficoSemanal(),
          _buildUltimasSessoes(),
        ],
      ),
    );
  }

  Widget _buildMateriasTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Minhas Matérias',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _selectedTab = 2),
                tooltip: 'Nova Matéria',
              ),
            ],
          ),
        ),
        Expanded(
          child: _materias.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma matéria criada',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() => _selectedTab = 2),
                        child: const Text('Criar primeira matéria'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _materias.length,
                  itemBuilder: (context, index) {
                    final materia = _materias[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _materiaEditando?.id == materia.id
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _editMateriaController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Nome da matéria',
                                    ),
                                    autofocus: true,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _atualizarMateria,
                                          icon: const Icon(Icons.save, size: 18),
                                          label: const Text('Salvar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              setState(() => _materiaEditando = null),
                                          icon: const Icon(Icons.close, size: 18),
                                          label: const Text('Cancelar'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.book, color: Colors.blue),
                              ),
                              title: Text(
                                materia.nome,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'ID: ${materia.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _materiaEditando = materia;
                                        _editMateriaController.text = materia.nome;
                                      });
                                    },
                                    color: Colors.blue,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _deletarMateria(materia),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNovaMateriaTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Criar Nova Matéria',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _novaMateriaController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nome da matéria',
                        hintText: 'Ex: Matemática, Português...',
                      ),
                      onSubmitted: (_) => _criarMateria(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _criarMateria,
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Matéria'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editarSessao(SessaoEstudo sessao) {
    setState(() {
      _sessaoEditando = sessao;
      _editSessaoMateriaId = sessao.materiaId;
      _editSessaoData = sessao.data;
      _editSessaoHoras = sessao.horasEstudadas;
      _editSessaoAnotacoesController.text = sessao.anotacoes;
    });
  }

  Widget _buildSessoesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Sessões de Estudo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _selectedTab = 4),
                tooltip: 'Nova Sessão',
              ),
            ],
          ),
        ),
        Expanded(
          child: _sessoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma sessão registrada',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() => _selectedTab = 4),
                        child: const Text('Registrar primeira sessão'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessoes.length,
                  itemBuilder: (context, index) {
                    final sessao = _sessoes.reversed.toList()[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _sessaoEditando?.id == sessao.id
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  DropdownButtonFormField<int>(
                                    value: _editSessaoMateriaId,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Matéria',
                                    ),
                                    items: _materias.map((m) {
                                      return DropdownMenuItem(
                                        value: m.id,
                                        child: Text(m.nome),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        setState(() => _editSessaoMateriaId = value),
                                  ),
                                  const SizedBox(height: 12),
                                  ListTile(
                                    leading: const Icon(Icons.calendar_today),
                                    title: const Text('Data'),
                                    trailing: Text(
                                      DateFormat('dd/MM/yyyy').format(_editSessaoData),
                                    ),
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _editSessaoData,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      if (date != null) {
                                        setState(() => _editSessaoData = date);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Horas estudadas',
                                    ),
                                    onChanged: (value) => setState(() {
                                      _editSessaoHoras = double.tryParse(value) ?? 0;
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _editSessaoAnotacoesController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Anotações',
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _atualizarSessao,
                                          icon: const Icon(Icons.save),
                                          label: const Text('Salvar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              setState(() => _sessaoEditando = null),
                                          icon: const Icon(Icons.close),
                                          label: const Text('Cancelar'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.timer, color: Colors.blue),
                              ),
                              title: Text(
                                _getMateriaNome(sessao.materiaId),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(sessao.data),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  if (sessao.anotacoes.isNotEmpty)
                                    Text(
                                      sessao.anotacoes,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${sessao.horasEstudadas}h',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _editarSessao(sessao),
                                    color: Colors.blue,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _deletarSessao(sessao.id!),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNovaSessaoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Registrar Sessão de Estudo',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<int>(
                      value: _materiaSelecionadaId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Matéria',
                      ),
                      hint: const Text('Selecione uma matéria'),
                      items: _materias.map((m) {
                        return DropdownMenuItem(
                          value: m.id,
                          child: Text(m.nome),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _materiaSelecionadaId = value),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Data'),
                      trailing: Text(DateFormat('dd/MM/yyyy').format(_dataSessao)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dataSessao,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _dataSessao = date);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Horas estudadas',
                        suffixText: 'horas',
                      ),
                      onChanged: (value) =>
                          setState(() => _horas = double.tryParse(value) ?? 0),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _anotacoesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Anotações (opcional)',
                        hintText: 'O que você aprendeu? Dificuldades?',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _criarSessao,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Registrar Sessão'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusStudy'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.school, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'FocusStudy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Matérias'),
              selected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Nova Matéria'),
              selected: _selectedTab == 2,
              onTap: () => setState(() => _selectedTab = 2),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Sessões'),
              selected: _selectedTab == 3,
              onTap: () => setState(() => _selectedTab = 3),
            ),
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Registrar Estudo'),
              selected: _selectedTab == 4,
              onTap: () => setState(() => _selectedTab = 4),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            IndexedStack(
              index: _selectedTab,
              children: [
                _buildDashboardTab(),
                _buildMateriasTab(),
                _buildNovaMateriaTab(),
                _buildSessoesTab(),
                _buildNovaSessaoTab(),
              ],
            ),
          if (_successMessage != null)
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(_successMessage!, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}