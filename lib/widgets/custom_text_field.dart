import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final IconData? icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? helperText;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.helperText,
    this.autofocus = false,
    this.textInputAction,
    this.onEditingComplete,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused = false;
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _errorText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      if (widget.validator != null) {
        _errorText = widget.validator!(widget.controller?.text);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              bottom: (widget.helperText != null || _errorText != null) ? 4 : 16,
            ),
            decoration: BoxDecoration(
              color: _isFocused 
                  ? (isLight ? Colors.white : theme.colorScheme.surface)
                  : (isLight 
                      ? theme.colorScheme.surface
                      : theme.colorScheme.surfaceVariant.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _errorText != null
                    ? theme.colorScheme.error
                    : _isFocused
                        ? theme.colorScheme.primary
                        : _isHovered
                            ? theme.colorScheme.onSurfaceVariant.withOpacity(0.3)
                            : theme.colorScheme.outline.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                if (_isFocused) ...[
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] else if (_isHovered) ...[
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ] else ...[
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.isPassword && _obscureText,
              keyboardType: widget.keyboardType,
              maxLength: widget.maxLength,
              validator: widget.validator,
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
                if (widget.validator != null) {
                  setState(() {
                    _errorText = widget.validator!(value);
                  });
                }
              },
              inputFormatters: widget.inputFormatters,
              autofocus: widget.autofocus,
              textInputAction: widget.textInputAction,
              onEditingComplete: widget.onEditingComplete,
              onFieldSubmitted: widget.onSubmitted,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15,
                height: 1.5,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                floatingLabelStyle: TextStyle(
                  color: _errorText != null
                      ? theme.colorScheme.error
                      : _isFocused
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  backgroundColor: _isFocused 
                      ? (isLight ? Colors.white : theme.colorScheme.surface)
                      : (isLight 
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                ),
                alignLabelWithHint: true,
                isDense: true,
                helperText: widget.helperText,
                helperMaxLines: 3,
                helperStyle: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
                errorText: _errorText,
                errorMaxLines: 3,
                errorStyle: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: widget.icon != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          widget.icon,
                          size: 20,
                          color: _errorText != null
                              ? theme.colorScheme.error
                              : _isFocused
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            key: ValueKey<bool>(_obscureText),
                            size: 20,
                            color: _errorText != null
                                ? theme.colorScheme.error
                                : _isFocused
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onPressed: () {
                          setState(() => _obscureText = !_obscureText);
                          HapticFeedback.lightImpact();
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: widget.icon != null ? 12 : 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 