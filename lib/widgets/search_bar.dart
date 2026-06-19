import 'dart:async';
import 'package:flutter/material.dart';
import '../config/constants.dart';

class AppSearchBar extends StatefulWidget {
  final Function(String) onChanged;
  final String? hintText;

  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Buscar trámite...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: Colors.grey.shade400,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_outlined,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () {
                    _controller.clear();
                    _debounce?.cancel();
                    widget.onChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.grisOscuro,
        ),
      ),
    );
  }
}
