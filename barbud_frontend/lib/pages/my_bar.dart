import 'package:flutter/material.dart';

import '../models/bar.dart';
import '../services/bar_service.dart';
import 'create_bar.dart';

class MyBarPage extends StatefulWidget {
  const MyBarPage({super.key});

  @override
  State<MyBarPage> createState() => _MyBarPageState();
}

class _MyBarPageState extends State<MyBarPage> {
  late Future<List<UserBar>> _barsFuture;

  @override
  void initState() {
    super.initState();
    _barsFuture = BarService.getMyBars();
  }

  Future<void> _refreshBars() async {
    setState(() {
      _barsFuture = BarService.getMyBars();
    });
  }

  Future<void> _goToCreateBar() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBarPage(),
      ),
    );

    if (created == true) {
      _refreshBars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F1),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshBars,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Bar",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1D1D1D),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Manage your home bars and ingredients.",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF77716A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _goToCreateBar,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D1D1D),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 10),
                  child: ElevatedButton.icon(
                    onPressed: _goToCreateBar,
                    icon: const Icon(Icons.local_bar_rounded),
                    label: const Text("Create new bar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D1D1D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              FutureBuilder<List<UserBar>>(
                future: _barsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            "Could not load your bars.\n${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final bars = snapshot.data ?? [];

                  if (bars.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_bar_rounded,
                                size: 44,
                                color: Color(0xFF1D1D1D),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "No bars yet",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Create your first bar and add the ingredients you have at home.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF77716A),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _goToCreateBar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D1D1D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                "Create bar",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 110),
                    sliver: SliverList.separated(
                      itemCount: bars.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final bar = bars[index];

                        return _BarCard(bar: bar);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarCard extends StatelessWidget {
  final UserBar bar;

  const _BarCard({
    required this.bar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF2E7D8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.local_bar_rounded,
              color: Color(0xFF1D1D1D),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bar.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1D1D),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${bar.ingredientCount} ingredients",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF77716A),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF1D1D1D),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}