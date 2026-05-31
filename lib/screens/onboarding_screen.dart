import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/account.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _selectedGoal;
  String? _selectedFrequency;
  bool? _selectedWantsGoal;

  static const int _totalPages = 9;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    _pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final settings = context.read<SettingsProvider>();
    if (_selectedGoal != null) {
      await settings.setOnboardingGoal(_selectedGoal);
    }
    if (_selectedFrequency != null) {
      await settings.setOnboardingFrequency(_selectedFrequency);
    }
    if (_selectedWantsGoal != null) {
      await settings.setOnboardingWantsGoal(_selectedWantsGoal);
    }
    await settings.setOnboardingCompleted(true);

    if (!mounted) return;
    context.go('/');
  }

  Future<void> _showCreateAccountDialog() async {
    final nameController = TextEditingController(text: 'Efectivo');
    final balanceController = TextEditingController();
    AccountType selectedType = AccountType.cash;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crear primera cuenta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nombre',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Efectivo, Débito',
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tipo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: AccountType.values.map((type) {
                      final isSelected = selectedType == type;
                      final labels = {
                        AccountType.cash: 'Efectivo',
                        AccountType.debit: 'Débito',
                        AccountType.credit: 'Crédito',
                        AccountType.savings: 'Ahorros',
                      };
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: type != AccountType.values.last ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                labels[type]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Saldo inicial',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final balance =
                            double.tryParse(balanceController.text) ?? 0;
                        Navigator.of(ctx).pop(true);
                        DatabaseHelper().insertAccount(
                          Account(
                            name: name,
                            balance: balance,
                            type: selectedType,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (created == true) {
      await _completeOnboarding();
    }
  }

  bool get _canProceed {
    if (_currentPage == 5) return _selectedGoal != null;
    if (_currentPage == 6) return _selectedFrequency != null;
    if (_currentPage == 7) return _selectedWantsGoal != null;
    return true;
  }

  String get _nextButtonText {
    if (_currentPage == 0) return 'Empezar';
    return 'Siguiente';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildWelcomePage(),
                  _buildProblemPage(),
                  _buildSolutionPage(),
                  _buildGoalsPage(),
                  _buildPersonalizationPage(),
                  _buildQuestion1Page(),
                  _buildQuestion2Page(),
                  _buildQuestion3Page(),
                  _buildActivationPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        children: [
          Expanded(child: _buildProgressBar()),
          if (_currentPage < _totalPages - 1)
            GestureDetector(
              onTap: _skip,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Saltar',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_totalPages, (index) {
        final isActive = index <= _currentPage;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            margin: EdgeInsets.only(right: index < _totalPages - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomBar() {
    if (_currentPage < _totalPages - 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: _canProceed ? _nextPage : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _nextButtonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _showCreateAccountDialog,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Crear mi primera cuenta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _completeOnboarding(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onSurfaceVariant,
            ),
            child: const Text(
              'Explorar primero',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset(
            'assets/images/zoe_sentada.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
          const Spacer(flex: 1),
          Text(
            'Hola, soy Zoe 🐶',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Voy a ayudarte a entender mejor tu dinero, ahorrar más y dejar de preguntarte dónde se fue tu sueldo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildProblemPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset(
            'assets/images/zoe_duda.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
          const Spacer(flex: 1),
          Text(
            '¿Te pasa esto?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Cobrás, gastás un poco acá, otro poco allá... y al final del mes no sabés en qué se fue la plata.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          _buildBulletItem('Compras pequeñas que se acumulan'),
          const SizedBox(height: 12),
          _buildBulletItem('Gastos que olvidás registrar'),
          const SizedBox(height: 12),
          _buildBulletItem('Metas de ahorro que nunca arrancan'),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: AppColors.primary,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSolutionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset(
            'assets/images/zoe_anteojos.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
          const Spacer(flex: 1),
          Text(
            'Finanze lo organiza por vos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Registrá movimientos, controlá tus cuentas y visualizá todo en un solo lugar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          _buildMiniBullet(Icons.account_balance_wallet_rounded, 'Saldo actualizado'),
          const SizedBox(height: 12),
          _buildMiniBullet(Icons.history_rounded, 'Historial completo'),
          const SizedBox(height: 12),
          _buildMiniBullet(Icons.bar_chart_rounded, 'Estadísticas automáticas'),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildMiniBullet(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const Spacer(flex: 1),
          Text(
            'Convertí objetivos en realidad',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Creá metas para viajes, una notebook nueva o tu fondo de emergencia y seguí tu progreso día a día.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildExampleChip('🏖 Vacaciones'),
              _buildExampleChip('💻 Notebook'),
              _buildExampleChip('🚗 Auto'),
              _buildExampleChip('🏠 Fondo emergencia'),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildPersonalizationPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const Spacer(flex: 1),
          Text(
            'Adaptada a vos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Elegí tu moneda, definí presupuestos, personalizá categorías y exportá tus datos cuando quieras.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconLabel(Icons.attach_money_rounded, 'Moneda'),
              _buildIconLabel(Icons.pie_chart_rounded, 'Presupuesto'),
              _buildIconLabel(Icons.file_download_rounded, 'Exportación'),
              _buildIconLabel(Icons.label_rounded, 'Categorías'),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion1Page() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            '¿Cuál es tu principal objetivo?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 32),
          _buildOptionButton(
            text: 'Ahorrar más',
            isSelected: _selectedGoal == 'Ahorrar más',
            onTap: () => setState(() => _selectedGoal = 'Ahorrar más'),
          ),
          _buildOptionButton(
            text: 'Controlar gastos',
            isSelected: _selectedGoal == 'Controlar gastos',
            onTap: () => setState(() => _selectedGoal = 'Controlar gastos'),
          ),
          _buildOptionButton(
            text: 'Organizar mis cuentas',
            isSelected: _selectedGoal == 'Organizar mis cuentas',
            onTap: () =>
                setState(() => _selectedGoal = 'Organizar mis cuentas'),
          ),
          _buildOptionButton(
            text: 'Salir de deudas',
            isSelected: _selectedGoal == 'Salir de deudas',
            onTap: () => setState(() => _selectedGoal = 'Salir de deudas'),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildQuestion2Page() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            '¿Con qué frecuencia registrás gastos?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 32),
          _buildOptionButton(
            text: 'Nunca',
            isSelected: _selectedFrequency == 'Nunca',
            onTap: () => setState(() => _selectedFrequency = 'Nunca'),
          ),
          _buildOptionButton(
            text: 'A veces',
            isSelected: _selectedFrequency == 'A veces',
            onTap: () => setState(() => _selectedFrequency = 'A veces'),
          ),
          _buildOptionButton(
            text: 'Casi siempre',
            isSelected: _selectedFrequency == 'Casi siempre',
            onTap: () => setState(() => _selectedFrequency = 'Casi siempre'),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildQuestion3Page() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            '¿Querés establecer una meta de ahorro ahora?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 32),
          _buildOptionButton(
            text: 'Sí',
            isSelected: _selectedWantsGoal == true,
            onTap: () => setState(() => _selectedWantsGoal = true),
          ),
          _buildOptionButton(
            text: 'Más tarde',
            isSelected: _selectedWantsGoal == false,
            onTap: () => setState(() => _selectedWantsGoal = false),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerHighest,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildActivationPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const Spacer(flex: 1),
          Text(
            'Empecemos con tu primera cuenta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Configurar Finanze lleva menos de un minuto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
