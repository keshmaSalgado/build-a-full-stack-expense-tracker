import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080');

void main() {
  runApp(const ExpenseTrackerMobile());
}

class ExpenseTrackerMobile extends StatefulWidget {
  const ExpenseTrackerMobile({super.key});

  @override
  State<ExpenseTrackerMobile> createState() => _ExpenseTrackerMobileState();
}

class _ExpenseTrackerMobileState extends State<ExpenseTrackerMobile> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
          scaffoldBackgroundColor: const Color(0xFFF4F4F5),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981), brightness: Brightness.dark),
        ),
        home: RootScreen(
          darkMode: darkMode,
          onThemeChanged: (value) => setState(() => darkMode = value),
        ),
      ),
    );
  }
}

class AppScope extends StatefulWidget {
  const AppScope({super.key, required this.child});
  final Widget child;

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_AppInherited>()!.state;
  static AppState read(BuildContext context) => (context.getElementForInheritedWidgetOfExactType<_AppInherited>()!.widget as _AppInherited).state;

  @override
  State<AppScope> createState() => AppState();
}

class AppState extends State<AppScope> {
  final ApiClient api = ApiClient();
  UserDto? user;
  bool booting = true;

  @override
  void initState() {
    super.initState();
    bootstrap();
  }

  Future<void> bootstrap() async {
    await api.loadToken();
    if (api.hasToken) {
      try {
        user = await api.me();
      } catch (_) {
        await api.logout();
      }
    }
    setState(() => booting = false);
  }

  Future<void> login(String email, String password) async {
    final response = await api.login(email, password);
    setState(() => user = response.user);
  }

  Future<void> register(String name, String email, String password, String confirmPassword) async {
    final response = await api.register(name, email, password, confirmPassword);
    setState(() => user = response.user);
  }

  Future<void> logout() async {
    await api.logout();
    setState(() => user = null);
  }

  Future<void> updateProfile(String name, String profilePictureUrl, String currency) async {
    user = await api.updateProfile(name, profilePictureUrl, currency);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _AppInherited(state: this, child: widget.child);
}

class _AppInherited extends InheritedWidget {
  const _AppInherited({required this.state, required super.child});
  final AppState state;

  @override
  bool updateShouldNotify(_AppInherited oldWidget) => true;
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.darkMode, required this.onThemeChanged});
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (app.booting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (app.user == null) {
      return const AuthScreen();
    }
    return ShellScreen(darkMode: darkMode, onThemeChanged: onThemeChanged);
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool registerMode = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Expense Tracker', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.teal, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(registerMode ? 'Create account' : 'Welcome back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 20),
                        if (registerMode)
                          AppTextField(controller: name, label: 'Name', validator: requiredValidator),
                        AppTextField(controller: email, label: 'Email', keyboardType: TextInputType.emailAddress, validator: requiredValidator),
                        AppTextField(controller: password, label: 'Password', obscureText: true, validator: passwordValidator),
                        if (registerMode)
                          AppTextField(controller: confirmPassword, label: 'Confirm Password', obscureText: true, validator: (value) {
                            if (value != password.text) return 'Passwords must match';
                            return null;
                          }),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: loading ? null : () => submit(app),
                          child: loading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(registerMode ? 'Register' : 'Login'),
                        ),
                        TextButton(
                          onPressed: loading ? null : () => setState(() => registerMode = !registerMode),
                          child: Text(registerMode ? 'Already have an account? Login' : 'New here? Create account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submit(AppState app) async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      if (registerMode) {
        await app.register(name.text.trim(), email.text.trim(), password.text, confirmPassword.text);
      } else {
        await app.login(email.text.trim(), password.text);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.darkMode, required this.onThemeChanged});
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;
  final pages = const [DashboardPage(), TransactionsPage(), CategoriesPage(), ReportsPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(['Dashboard', 'Transactions', 'Categories', 'Reports', 'Profile'][index]),
        actions: [
          IconButton(
            onPressed: () => widget.onThemeChanged(!widget.darkMode),
            icon: Icon(widget.darkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(onPressed: app.logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.swap_vert), label: 'Txn'),
          NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<DashboardData> future;

  @override
  void initState() {
    super.initState();
    future = load();
  }

  Future<DashboardData> load() async {
    final api = AppScope.read(context).api;
    final results = await Future.wait([api.summary(), api.monthly(), api.categorySpending(), api.transactions(size: 5)]);
    return DashboardData(results[0] as SummaryDto, results[1] as List<MonthlyDto>, results[2] as List<CategorySpendDto>, results[3] as PageDto<TransactionDto>);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return RefreshIndicator(
      onRefresh: () async => setState(() => future = load()),
      child: FutureBuilder<DashboardData>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatTile(title: 'Income', value: money(data.summary.totalIncome, app.user?.currency), color: Colors.green),
                  StatTile(title: 'Expense', value: money(data.summary.totalExpenses, app.user?.currency), color: Colors.orange),
                  StatTile(title: 'Balance', value: money(data.summary.currentBalance, app.user?.currency), color: const Color(0xFFBE123C)),
                ],
              ),
              const SizedBox(height: 16),
              ChartCard(title: 'Income vs Expense', child: IncomeExpenseChart(monthly: data.monthly)),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Recent Transactions',
                child: data.recent.content.isEmpty
                    ? const EmptyText('No transactions yet')
                    : Column(children: data.recent.content.map((item) => TransactionListTile(item: item)).toList()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final search = TextEditingController();
  List<CategoryDto> categories = [];
  PageDto<TransactionDto>? page;
  int pageIndex = 0;
  String? categoryId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({int page = 0}) async {
    setState(() => loading = true);
    final api = AppScope.read(context).api;
    final results = await Future.wait([
      api.categories(),
      api.transactions(page: page, search: search.text, categoryId: categoryId),
    ]);
    setState(() {
      categories = results[0] as List<CategoryDto>;
      this.page = results[1] as PageDto<TransactionDto>;
      pageIndex = page;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: loading && page == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search'), onSubmitted: (_) => load())),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(onPressed: () => load(), icon: const Icon(Icons.tune)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All categories')),
                    ...categories.map((category) => DropdownMenuItem<String?>(value: category.id, child: Text(category.name))),
                  ],
                  onChanged: (value) {
                    categoryId = value;
                    load();
                  },
                ),
                const SizedBox(height: 12),
                if (page?.content.isEmpty ?? true)
                  const EmptyText('No transactions found')
                else
                  ...page!.content.map((item) => TransactionListTile(
                        item: item,
                        onTap: () => openForm(item: item),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => delete(item.id)),
                      )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: pageIndex == 0 ? null : () => load(page: pageIndex - 1), child: const Text('Previous')),
                    Text('Page ${pageIndex + 1} of ${page?.totalPages ?? 1}'),
                    TextButton(onPressed: (page == null || pageIndex + 1 >= page!.totalPages) ? null : () => load(page: pageIndex + 1), child: const Text('Next')),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> openForm({TransactionDto? item}) async {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create a category first')));
      return;
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionForm(categories: categories, item: item),
    );
    if (saved == true) load(page: pageIndex);
  }

  Future<void> delete(String id) async {
    await AppScope.read(context).api.deleteTransaction(id);
    await load(page: pageIndex);
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<CategoryDto>> future;

  @override
  void initState() {
    super.initState();
    future = AppScope.read(context).api.categories();
  }

  void refresh() => setState(() => future = AppScope.read(context).api.categories());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(onPressed: () => openForm(), icon: const Icon(Icons.add), label: const Text('Add')),
      body: FutureBuilder<List<CategoryDto>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final categories = snapshot.data!;
          if (categories.isEmpty) return const EmptyText('No categories');
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: CircleAvatar(backgroundColor: parseColor(category.color)),
                title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Wrap(
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => openForm(category: category)),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                      await AppScope.read(context).api.deleteCategory(category.id);
                      refresh();
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> openForm({CategoryDto? category}) async {
    final saved = await showDialog<bool>(context: context, builder: (_) => CategoryForm(category: category));
    if (saved == true) refresh();
  }
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final profilePictureUrl = TextEditingController();
  String currency = 'USD';
  bool saving = false;

  static const currencies = ['USD', 'EUR', 'GBP', 'LKR', 'INR', 'AUD', 'CAD', 'JPY'];

  @override
  void initState() {
    super.initState();
    final user = AppScope.read(context).user;
    name.text = user?.name ?? '';
    profilePictureUrl.text = user?.profilePictureUrl ?? '';
    currency = currencies.contains(user?.currency) ? user!.currency : 'USD';
  }

  @override
  void dispose() {
    name.dispose();
    profilePictureUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.teal,
                  backgroundImage: user?.profilePictureUrl?.isNotEmpty == true ? NetworkImage(user!.profilePictureUrl!) : null,
                  child: user?.profilePictureUrl?.isNotEmpty == true ? null : Text((user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'User', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Profile Settings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: profilePictureUrl,
                    decoration: const InputDecoration(labelText: 'Profile Picture URL', prefixIcon: Icon(Icons.image_outlined)),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: currency,
                    decoration: const InputDecoration(labelText: 'Currency', prefixIcon: Icon(Icons.payments_outlined)),
                    items: currencies.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                    onChanged: (value) => setState(() => currency = value ?? 'USD'),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: saving ? null : save,
                    icon: saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
                    label: const Text('Save Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await AppScope.read(context).updateProfile(name.text.trim(), profilePictureUrl.text.trim(), currency);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

class _ReportsPageState extends State<ReportsPage> {
  late Future<DashboardData> future;

  @override
  void initState() {
    super.initState();
    future = load();
  }

  Future<DashboardData> load() async {
    final api = AppScope.read(context).api;
    final results = await Future.wait([api.summary(), api.monthly(), api.categorySpending(), api.transactions(size: 1)]);
    return DashboardData(results[0] as SummaryDto, results[1] as List<MonthlyDto>, results[2] as List<CategorySpendDto>, results[3] as PageDto<TransactionDto>);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardData>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ChartCard(title: 'Monthly Trends', child: IncomeExpenseChart(monthly: data.monthly)),
            const SizedBox(height: 16),
            ChartCard(title: 'Spending by Category', child: CategoryPieChart(items: data.categories)),
          ],
        );
      },
    );
  }
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key, required this.categories, this.item});
  final List<CategoryDto> categories;
  final TransactionDto? item;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final title = TextEditingController();
  final description = TextEditingController();
  final amount = TextEditingController();
  late DateTime date;
  late String type;
  late String categoryId;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    title.text = item?.title ?? '';
    description.text = item?.description ?? '';
    amount.text = item?.amount.toString() ?? '';
    date = item?.date ?? DateTime.now();
    type = item?.type ?? 'EXPENSE';
    categoryId = item?.category.id ?? widget.categories.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.item == null ? 'Add Transaction' : 'Edit Transaction', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: amount, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'EXPENSE', label: Text('Expense')), ButtonSegment(value: 'INCOME', label: Text('Income'))],
              selected: {type},
              onSelectionChanged: (value) => setState(() => type = value.first),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: widget.categories.map((category) => DropdownMenuItem(value: category.id, child: Text(category.name))).toList(),
              onChanged: (value) => setState(() => categoryId = value!),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: date);
                if (picked != null) setState(() => date = picked);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat.yMMMd().format(date)),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    final payload = {
      'title': title.text.trim(),
      'description': description.text.trim(),
      'amount': double.tryParse(amount.text) ?? 0,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'type': type,
      'categoryId': categoryId,
    };
    final api = AppScope.read(context).api;
    if (widget.item == null) {
      await api.createTransaction(payload);
    } else {
      await api.updateTransaction(widget.item!.id, payload);
    }
    if (mounted) Navigator.pop(context, true);
  }
}

class CategoryForm extends StatefulWidget {
  const CategoryForm({super.key, this.category});
  final CategoryDto? category;

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final name = TextEditingController();
  Color color = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    name.text = widget.category?.name ?? '';
    color = parseColor(widget.category?.color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [Colors.green, Colors.orange, Colors.blue, Colors.red, Colors.purple, Colors.teal].map((value) {
              return ChoiceChip(
                label: const SizedBox.shrink(),
                selectedColor: value,
                backgroundColor: value.withOpacity(.5),
                selected: color.value == value.value,
                onSelected: (_) => setState(() => color = value),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: save, child: const Text('Save')),
      ],
    );
  }

  Future<void> save() async {
    final payload = {'name': name.text.trim(), 'color': colorToHex(color)};
    final api = AppScope.read(context).api;
    if (widget.category == null) {
      await api.createCategory(payload);
    } else {
      await api.updateCategory(widget.category!.id, payload);
    }
    if (mounted) Navigator.pop(context, true);
  }
}

class ApiClient {
  String? token;

  bool get hasToken => token != null && token!.isNotEmpty;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('expense_tracker_token');
  }

  Future<void> saveToken(String value) async {
    token = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expense_tracker_token', value);
  }

  Future<void> logout() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('expense_tracker_token');
  }

  Future<AuthResponseDto> register(String name, String email, String password, String confirmPassword) async {
    final data = await post('/api/auth/register', {'name': name, 'email': email, 'password': password, 'confirmPassword': confirmPassword}, auth: false);
    final response = AuthResponseDto.fromJson(data);
    await saveToken(response.token);
    return response;
  }

  Future<AuthResponseDto> login(String email, String password) async {
    final data = await post('/api/auth/login', {'email': email, 'password': password}, auth: false);
    final response = AuthResponseDto.fromJson(data);
    await saveToken(response.token);
    return response;
  }

  Future<UserDto> me() async => UserDto.fromJson(await get('/api/users/me'));
  Future<UserDto> updateProfile(String name, String profilePictureUrl, String currency) async {
    return UserDto.fromJson(await put('/api/users/me', {
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'currency': currency,
    }));
  }
  Future<SummaryDto> summary() async => SummaryDto.fromJson(await get('/api/reports/summary'));
  Future<List<MonthlyDto>> monthly() async => (await getList('/api/reports/monthly')).map(MonthlyDto.fromJson).toList();
  Future<List<CategorySpendDto>> categorySpending() async => (await getList('/api/reports/categories')).map(CategorySpendDto.fromJson).toList();
  Future<List<CategoryDto>> categories() async => (await getList('/api/categories')).map(CategoryDto.fromJson).toList();
  Future<void> createCategory(Map<String, dynamic> body) async => post('/api/categories', body);
  Future<void> updateCategory(String id, Map<String, dynamic> body) async => put('/api/categories/$id', body);
  Future<void> deleteCategory(String id) async => delete('/api/categories/$id');
  Future<PageDto<TransactionDto>> transactions({int page = 0, int size = 10, String? search, String? categoryId}) async {
    final params = {'page': '$page', 'size': '$size', 'sort': 'date,desc'};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null && categoryId.isNotEmpty) params['categoryId'] = categoryId;
    final data = await get('/api/transactions', params: params);
    return PageDto.fromJson(data, TransactionDto.fromJson);
  }

  Future<void> createTransaction(Map<String, dynamic> body) async => post('/api/transactions', body);
  Future<void> updateTransaction(String id, Map<String, dynamic> body) async => put('/api/transactions/$id', body);
  Future<void> deleteTransaction(String id) async => delete('/api/transactions/$id');

  Future<dynamic> get(String path, {Map<String, String>? params}) => request('GET', path, params: params);
  Future<List<dynamic>> getList(String path) async => await get(path) as List<dynamic>;
  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) => request('POST', path, body: body, auth: auth);
  Future<dynamic> put(String path, Map<String, dynamic> body) => request('PUT', path, body: body);
  Future<void> delete(String path) async => request('DELETE', path);

  Future<dynamic> request(String method, String path, {Map<String, String>? params, Map<String, dynamic>? body, bool auth = true}) async {
    final uri = Uri.parse('$apiBaseUrl$path').replace(queryParameters: params);
    final headers = {'Content-Type': 'application/json'};
    if (auth && token != null) headers['Authorization'] = 'Bearer $token';
    final response = await switch (method) {
      'GET' => http.get(uri, headers: headers),
      'POST' => http.post(uri, headers: headers, body: jsonEncode(body)),
      'PUT' => http.put(uri, headers: headers, body: jsonEncode(body)),
      'DELETE' => http.delete(uri, headers: headers),
      _ => throw Exception('Unsupported request method'),
    };
    if (response.statusCode >= 400) {
      final message = response.body.isEmpty ? 'Request failed' : (jsonDecode(response.body)['message'] ?? 'Request failed');
      throw Exception(message);
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}

class AuthResponseDto {
  AuthResponseDto(this.token, this.user);
  final String token;
  final UserDto user;

  factory AuthResponseDto.fromJson(dynamic json) => AuthResponseDto(json['token'], UserDto.fromJson(json['user']));
}

class UserDto {
  UserDto({required this.id, required this.name, required this.email, required this.currency, this.profilePictureUrl});
  final String id;
  final String name;
  final String email;
  final String currency;
  final String? profilePictureUrl;

  factory UserDto.fromJson(dynamic json) => UserDto(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        currency: json['currency'] ?? 'USD',
        profilePictureUrl: json['profilePictureUrl'],
      );
}

class CategoryDto {
  CategoryDto({required this.id, required this.name, required this.color});
  final String id;
  final String name;
  final String? color;

  factory CategoryDto.fromJson(dynamic json) => CategoryDto(id: json['id'], name: json['name'], color: json['color']);
}

class TransactionDto {
  TransactionDto({required this.id, required this.title, required this.description, required this.amount, required this.date, required this.type, required this.category});
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final String type;
  final CategoryDto category;

  factory TransactionDto.fromJson(dynamic json) => TransactionDto(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        amount: NumberFormat().parse(json['amount'].toString()).toDouble(),
        date: DateTime.parse(json['date']),
        type: json['type'],
        category: CategoryDto.fromJson(json['category']),
      );
}

class SummaryDto {
  SummaryDto(this.totalIncome, this.totalExpenses, this.currentBalance);
  final double totalIncome;
  final double totalExpenses;
  final double currentBalance;

  factory SummaryDto.fromJson(dynamic json) => SummaryDto(toDouble(json['totalIncome']), toDouble(json['totalExpenses']), toDouble(json['currentBalance']));
}

class MonthlyDto {
  MonthlyDto(this.month, this.year, this.income, this.expense);
  final int month;
  final int year;
  final double income;
  final double expense;

  String get label => DateFormat.MMM().format(DateTime(year, month));
  factory MonthlyDto.fromJson(dynamic json) => MonthlyDto(json['month'], json['year'], toDouble(json['income']), toDouble(json['expense']));
}

class CategorySpendDto {
  CategorySpendDto(this.category, this.amount);
  final String category;
  final double amount;

  factory CategorySpendDto.fromJson(dynamic json) => CategorySpendDto(json['category'], toDouble(json['amount']));
}

class PageDto<T> {
  PageDto(this.content, this.totalPages);
  final List<T> content;
  final int totalPages;

  factory PageDto.fromJson(dynamic json, T Function(dynamic) mapper) => PageDto((json['content'] as List).map(mapper).toList(), json['totalPages'] ?? 1);
}

class DashboardData {
  DashboardData(this.summary, this.monthly, this.categories, this.recent);
  final SummaryDto summary;
  final List<MonthlyDto> monthly;
  final List<CategorySpendDto> categories;
  final PageDto<TransactionDto> recent;
}

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, required this.label, this.obscureText = false, this.keyboardType, this.validator});
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(controller: controller, decoration: InputDecoration(labelText: label), obscureText: obscureText, keyboardType: keyboardType, validator: validator),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.title, required this.value, required this.color});
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 22,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          ]),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}

class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SectionCard(title: title, child: SizedBox(height: 240, child: child));
}

class IncomeExpenseChart extends StatelessWidget {
  const IncomeExpenseChart({super.key, required this.monthly});
  final List<MonthlyDto> monthly;

  @override
  Widget build(BuildContext context) {
    if (monthly.isEmpty) return const EmptyText('No report data yet');
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
            final index = value.toInt();
            if (index < 0 || index >= monthly.length) return const SizedBox.shrink();
            return Text(monthly[index].label, style: const TextStyle(fontSize: 10));
          })),
        ),
        barGroups: [
          for (var i = 0; i < monthly.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: monthly[i].income, color: Colors.green, width: 8),
              BarChartRodData(toY: monthly[i].expense, color: Colors.orange, width: 8),
            ]),
        ],
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key, required this.items});
  final List<CategorySpendDto> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const EmptyText('No category spending yet');
    final colors = [Colors.green, Colors.orange, Colors.blue, Colors.red, Colors.purple, Colors.teal];
    return PieChart(
      PieChartData(
        sections: [
          for (var i = 0; i < items.length; i++)
            PieChartSectionData(value: items[i].amount, title: items[i].category, color: colors[i % colors.length], radius: 80, titleStyle: const TextStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({super.key, required this.item, this.onTap, this.trailing});
  final TransactionDto item;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final income = item.type == 'INCOME';
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(backgroundColor: parseColor(item.category.color), child: Icon(income ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white)),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${item.category.name} · ${DateFormat.yMMMd().format(item.date)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 112),
            child: Text(
              money(item.amount, AppScope.of(context).user?.currency),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(color: income ? Colors.green : Colors.orange, fontWeight: FontWeight.w800),
            ),
          ),
    );
  }
}

class EmptyText extends StatelessWidget {
  const EmptyText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(text, textAlign: TextAlign.center)));
}

String? requiredValidator(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
String? passwordValidator(String? value) => value == null || value.length < 8 ? 'Use at least 8 characters' : null;
double toDouble(dynamic value) => NumberFormat().parse(value.toString()).toDouble();
String money(num value, String? currency) => NumberFormat.simpleCurrency(name: currency ?? 'USD').format(value);
String colorToHex(Color color) => '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

Color parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF10B981);
  final clean = hex.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}
