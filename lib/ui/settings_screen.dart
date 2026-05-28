import 'package:flutter/material.dart';
import 'package:finance/components/my_gradient.dart';
import 'package:finance/services/privacy_service.dart';
import 'package:finance/services/settings_service.dart';
import 'package:finance/services/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isScreenshotProtected = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final darkTheme = await SettingsService.loadDarkTheme();
    final protection = await SettingsService.loadScreenshotProtection();
    if (mounted) {
      setState(() {
        _isDarkMode = darkTheme;
        _isScreenshotProtected = protection;
      });
    }
  }

  void _toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    ThemeService.setTheme(value);
    await SettingsService.saveDarkTheme(value);
  }

  void _toggleScreenshotProtection(bool value) async {
    setState(() {
      _isScreenshotProtected = value;
    });
    await PrivacyService.setScreenshotProtection(value);
    await SettingsService.saveScreenshotProtection(value);
  }

  Future<void> _openWhatsApp() async {
    // Вы можете заменить номер телефона на актуальный номер разработчика.
    final Uri url = Uri.parse('https://wa.me/996555000000?text=Здравствуйте!');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Адаптируем цвета к текущей теме
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: myGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Card
            _buildSettingsCard(
              cardColor: cardColor,
              child: SwitchListTile(
                title: Text("Темная тема", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                subtitle: Text("Переключить светлый/темный режим", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                secondary: Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: _isDarkMode ? Colors.amber : Colors.orange,
                ),
                activeColor: Colors.green,
                value: _isDarkMode,
                onChanged: _toggleTheme,
              ),
            ),
            const SizedBox(height: 16),
            
            // Privacy Card
            _buildSettingsCard(
              cardColor: cardColor,
              child: SwitchListTile(
                title: Text("Защита от скриншотов", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                subtitle: Text("Блокировка снимков экрана для безопасности", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                secondary: Icon(
                  Icons.security,
                  color: _isScreenshotProtected ? Colors.green : Colors.grey,
                ),
                activeColor: Colors.green,
                value: _isScreenshotProtected,
                onChanged: _toggleScreenshotProtection,
              ),
            ),
            const SizedBox(height: 32),
            
            // WhatsApp Button
            ElevatedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.chat, color: Colors.white),
              label: const Text(
                "Написать разработчику (WhatsApp)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // Официальный цвет WhatsApp
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child, required Color? cardColor}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}