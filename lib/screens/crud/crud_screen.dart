// lib/screens/crud/crud_screen.dart
// Halaman CRUD dengan dua tab: Orang dan Acara (PRD F5)

import 'package:flutter/material.dart';

import 'orang_list_screen.dart';
import 'acara_list_screen.dart';

class CrudScreen extends StatelessWidget {
  const CrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Data Orang & Acara'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person_outlined), text: 'Orang'),
              Tab(icon: Icon(Icons.event_outlined), text: 'Acara'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrangListScreen(),
            AcaraListScreen(),
          ],
        ),
      ),
    );
  }
}
