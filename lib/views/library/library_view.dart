import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();
    final books = provider.books;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Library Catalog & Circulation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Book repository, ISBN tracking, circulation and barcode scanning', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => context.read<LibraryProvider>().fetchBooks(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : books.isEmpty
                        ? const Center(child: Text('No books cataloged.'))
                        : ListView.separated(
                            itemCount: books.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final b = books[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.menu_book, color: AppTheme.primary),
                                ),
                                title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text('Author: ${b.author} | ISBN: ${b.isbn ?? "-"} | Barcode: ${b.barcode ?? "-"}', style: const TextStyle(fontSize: 12)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${b.availableCopies} / ${b.totalCopies} Available',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
