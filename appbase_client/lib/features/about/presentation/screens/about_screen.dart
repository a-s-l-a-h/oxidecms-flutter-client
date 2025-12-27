// lib/features/about/presentation/screens/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('About ibtwil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/ibtwil.webp', height: 120),
                const SizedBox(height: 24),
                Text(
                  'We are a DIY Support Hub 🛠️',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: textTheme.titleLarge?.copyWith(height: 1.4),
                    children: const <TextSpan>[
                      TextSpan(text: 'ibtwil — i built the way i like 😊.'),
                      TextSpan(text: '\n\nA friendly space for makers, learners, and tech enthusiasts.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Services Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What We Offer',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _ServiceCard(
                  icon: Icons.build,
                  title: 'DIY Support Hub',
                  description: 'Guidance, resources, and community support for your DIY journey',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                
                const SizedBox(height: 32),

                _ServiceCard(
                  icon: Icons.store,
                  title: 'Maker\'s Tools',
                  description: 'Electronics, tools, and equipment sales & rentals, plus a community makerspace with maker tools',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                
                _ServiceCard(
                  icon: Icons.event,
                  title: 'Technical Event Management',
                  description: 'Tech fests, competitions, workshops, classes, and awareness programs',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                
                
                
          /*      _ServiceCard(
                  icon: Icons.science,
                  title: 'Research & Development',
                  description: 'Automation solutions, and innovative tech projects',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12), */
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}