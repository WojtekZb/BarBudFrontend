import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../services/bar_service.dart';

class CreateBarPage extends StatefulWidget {
  const CreateBarPage({super.key});

  @override
  State<CreateBarPage> createState() => _CreateBarPageState();
}

class _CreateBarPageState extends State<CreateBarPage> {
  final TextEditingController nameController = TextEditingController();
  final Set<int> selectedIngredientIds = {};

  late Future<List<BarIngredient>> _ingredientsFuture;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _ingredientsFuture = BarService.getAllIngredients();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _toggleIngredient(int id) {
    setState(() {
      if (selectedIngredientIds.contains(id)) {
        selectedIngredientIds.remove(id);
      } else {
        selectedIngredientIds.add(id);
      }
    });
  }

  Future<void> _createBar() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please give your bar a name."),
        ),
      );
      return;
    }

    if (selectedIngredientIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one ingredient."),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await BarService.createBar(
        name: name,
        ingredientIds: selectedIngredientIds.toList(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not create bar: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF1D1D1D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Create Bar",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D1D1D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<List<BarIngredient>>(
                future: _ingredientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          "Could not load ingredients.\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    );
                  }

                  final ingredients = snapshot.data ?? [];

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 120),
                    children: [
                      const Text(
                        "Bar name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D1D1D),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Example: My Home Bar",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 17,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Ingredients",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1D1D1D),
                              ),
                            ),
                          ),
                          Text(
                            "${selectedIngredientIds.length} selected",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF77716A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      ...ingredients.map((ingredient) {
                        final selected =
                            selectedIngredientIds.contains(ingredient.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => _toggleIngredient(ingredient.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF1D1D1D)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 14,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.white.withOpacity(0.14)
                                          : const Color(0xFFF2E7D8),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      selected
                                          ? Icons.check_rounded
                                          : Icons.local_bar_outlined,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF1D1D1D),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ingredient.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: selected
                                                ? Colors.white
                                                : const Color(0xFF1D1D1D),
                                          ),
                                        ),
                                        if (ingredient.category != null &&
                                            ingredient.category!.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              ingredient.category!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: selected
                                                    ? Colors.white70
                                                    : const Color(0xFF77716A),
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
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
          child: ElevatedButton(
            onPressed: isSaving ? null : _createBar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D1D1D),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.black26,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text("Create bar"),
          ),
        ),
      ),
    );
  }
}