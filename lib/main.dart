import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scientific Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldClearDisplay = false;
  bool _isDegrees = true; // DEG / RAD toggle

  void _onNumberPressed(String value) {
    setState(() {
      if (_shouldClearDisplay || _display == '0') {
        _display = value == '.' ? '0.' : value;
        _shouldClearDisplay = false;
      } else {
        if (value == '.' && _display.contains('.')) return;
        _display += value;
      }
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      if (_firstOperand == null) {
        _firstOperand = double.tryParse(_display) ?? 0.0;
      } else if (_operator != null && !_shouldClearDisplay) {
        _firstOperand = _calculate(_firstOperand!, double.tryParse(_display) ?? 0.0, _operator!);
        _display = _formatResult(_firstOperand!);
      }
      _operator = op;
      _shouldClearDisplay = true;
    });
  }

  void _onEqualsPressed() {
    setState(() {
      if (_operator == null || _firstOperand == null) return;
      final second = double.tryParse(_display) ?? 0.0;
      final result = _calculate(_firstOperand!, second, _operator!);
      _display = _formatResult(result);
      _firstOperand = null;
      _operator = null;
      _shouldClearDisplay = true;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _shouldClearDisplay = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_shouldClearDisplay) {
        _display = '0';
        _shouldClearDisplay = false;
        return;
      }
      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  // Unary scientific operations that act immediately on the current display
  void _applyUnary(String op) {
    setState(() {
      final val = double.tryParse(_display) ?? 0.0;
      double res;
      switch (op) {
        case 'sin':
          final radians = _isDegrees ? val * math.pi / 180.0 : val;
          res = math.sin(radians);
          break;
        case 'cos':
          final radians = _isDegrees ? val * math.pi / 180.0 : val;
          res = math.cos(radians);
          break;
        case 'tan':
          final radians = _isDegrees ? val * math.pi / 180.0 : val;
          res = math.tan(radians);
          break;
        case 'sqrt':
          res = val < 0 ? double.nan : math.sqrt(val);
          break;
        case 'ln':
          res = val <= 0 ? double.nan : math.log(val);
          break;
        case 'log':
          res = val <= 0 ? double.nan : math.log(val) / math.ln10;
          break;
        case '1/x':
          res = val == 0 ? double.nan : 1 / val;
          break;
        case '+/-':
          res = -val;
          break;
        case 'x!':
        // simple factorial for integers up to 20
          if (val < 0 || val % 1 != 0 || val > 20) {
            res = double.nan;
          } else {
            res = 1;
            for (int i = 1; i <= val.toInt(); i++) res *= i;
          }
          break;
        default:
          res = val;
      }
      _display = _formatResult(res);
      _shouldClearDisplay = true;
    });
  }

  double _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
      case 'x':
      case '*':
        return a * b;
      case '÷':
      case '/':
        if (b == 0) return double.nan;
        return a / b;
      case '^':
        return math.pow(a, b).toDouble();
      default:
        return b;
    }
  }

  String _formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value.isNegative ? '-Infinity' : 'Infinity';
    if (value % 1 == 0) return value.toInt().toString();
    // trim long doubles
    return value.toStringAsPrecision(12).replaceAll(RegExp(r"\.?0+\$"), "");
  }

  Widget _buildButton(String text, {double? flex, VoidCallback? onTap, Color? textColor}) {
    return Expanded(
      flex: (flex ?? 1).toInt(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: CalculatorButton(
          label: text,
          onTap: onTap,
          textColor: textColor ?? Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Calculator'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                const Text('DEG'),
                Switch(
                  value: _isDegrees,
                  onChanged: (v) => setState(() => _isDegrees = v),
                ),
                const Text('RAD'),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.bottomRight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation);
                    return SlideTransition(position: offset, child: FadeTransition(opacity: animation, child: child));
                  },
                  child: Text(
                    _display,
                    key: ValueKey<String>(_display),
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                    maxLines: 3,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),

            // Scientific buttons row block
            Container(
              color: Colors.black12,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton('sin', onTap: () => _applyUnary('sin')),
                      _buildButton('cos', onTap: () => _applyUnary('cos')),
                      _buildButton('tan', onTap: () => _applyUnary('tan')),
                      _buildButton('^', onTap: () => _onOperatorPressed('^')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('ln', onTap: () => _applyUnary('ln')),
                      _buildButton('log', onTap: () => _applyUnary('log')),
                      _buildButton('√', onTap: () => _applyUnary('sqrt')),
                      _buildButton('x!', onTap: () => _applyUnary('x!')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1/x', onTap: () => _applyUnary('1/x')),
                      _buildButton('+/-', onTap: () => _applyUnary('+/-')),
                      _buildButton('%', onTap: () {
                        setState(() {
                          final val = double.tryParse(_display) ?? 0.0;
                          _display = _formatResult(val / 100.0);
                          _shouldClearDisplay = true;
                        });
                      }),
                      _buildButton('(', onTap: () => _onNumberPressed('('), textColor: Colors.black),
                    ],
                  ),
                ],
              ),
            ),

            // Basic keypad
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton('C', onTap: _onClear, textColor: Colors.black),
                      _buildButton('⌫', onTap: _onBackspace, textColor: Colors.black),
                      _buildButton('÷', onTap: () => _onOperatorPressed('/')),
                      _buildButton('×', onTap: () => _onOperatorPressed('*')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('7', onTap: () => _onNumberPressed('7')),
                      _buildButton('8', onTap: () => _onNumberPressed('8')),
                      _buildButton('9', onTap: () => _onNumberPressed('9')),
                      _buildButton('-', onTap: () => _onOperatorPressed('-')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('4', onTap: () => _onNumberPressed('4')),
                      _buildButton('5', onTap: () => _onNumberPressed('5')),
                      _buildButton('6', onTap: () => _onNumberPressed('6')),
                      _buildButton('+', onTap: () => _onOperatorPressed('+')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1', onTap: () => _onNumberPressed('1')),
                      _buildButton('2', onTap: () => _onNumberPressed('2')),
                      _buildButton('3', onTap: () => _onNumberPressed('3')),
                      _buildButton('=', onTap: _onEqualsPressed),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('0', flex: 2, onTap: () => _onNumberPressed('0')),
                      _buildButton('.', onTap: () => _onNumberPressed('.')),
                      _buildButton(')', onTap: () => _onNumberPressed(')'), textColor: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color textColor;

  const CalculatorButton({super.key, required this.label, this.onTap, this.textColor = Colors.white});

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    widget.onTap?.call();
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _pressed
                ? null
                : [BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(0, 6), blurRadius: 8)],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(fontSize: 20, color: widget.textColor),
          ),
        ),
      ),
    );
  }
}
