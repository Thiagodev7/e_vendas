import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/auth/stores/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalStore globalStore = Modular.get<GlobalStore>();
  AuthStore authStore = Modular.get<AuthStore>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_white.png',
              width: 150,
              height: 66,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Notificações futuras
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              globalStore.logout();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Boas-vindas
              Text(
                'Olá, Thiago 👋',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aqui está seu resumo de vendas.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // 🟦 Primeira linha de cards
              Row(
                children: [
                  _buildDashboardCard(
                    title: 'Total Vendas',
                    value: '25',
                    color: AppColors.primary,
                    icon: Icons.attach_money,
                  ),
                  const SizedBox(width: 12),
                  _buildDashboardCard(
                    title: 'Abertas',
                    value: '7',
                    color: Colors.orange,
                    icon: Icons.pending_actions,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🟩 Segunda linha de cards
              Row(
                children: [
                  _buildDashboardCard(
                    title: 'Finalizadas',
                    value: '18',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(width: 12),
                  _buildDashboardCard(
                    title: 'Meta',
                    value: '83%',
                    color: Colors.blue,
                    icon: Icons.bar_chart,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🟨 Terceira linha de cards
              Row(
                children: [
                  _buildDashboardCard(
                    title: 'Faturamento',
                    value: 'R\$ 12.500',
                    color: Colors.purple,
                    icon: Icons.trending_up,
                  ),
                  const SizedBox(width: 12),
                  _buildDashboardCard(
                    title: 'Ticket Médio',
                    value: 'R\$ 500',
                    color: Colors.teal,
                    icon: Icons.pie_chart,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 🔥 Cabeçalho do Drawer com informações do usuário
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            accountName: const Text(
              'Thiago Ribeiro',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('dev7.thiago@gmail.com'),
          ),

          // 🏠 Itens do Drawer
          _buildDrawerItem(
            icon: Icons.dashboard,
            text: 'Dashboard',
            onTap: () {
              Modular.to.navigate('/home');
            },
          ),
          _buildDrawerItem(
            icon: Icons.workspace_premium,
            text: 'Planos',
            onTap: () {
              Modular.to.navigate('/planos/');
            },
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart,
            text: 'Vendas',
            onTap: () {
              Modular.to.navigate('/vendas');
            },
          ),
          _buildDrawerItem(
            icon: Icons.people,
            text: 'Clientes',
            onTap: () {
              Modular.to.navigate('/clientes');
            },
          ),
          _buildDrawerItem(
            icon: Icons.inventory,
            text: 'Produtos',
            onTap: () {
              Modular.to.navigate('/produtos');
            },
          ),

          const Spacer(),

          const Divider(),

          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Sair',
            onTap: () {
              globalStore.logout();
              Modular.to.navigate('/auth');
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  // 🔥 Componente de Card
  Widget _buildDashboardCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
