import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/formato.dart';
import 'input_formatters.dart';

/// Campo de moneda en pesos colombianos. Muestra "$ " como prefix y formatea
/// con puntos de miles en vivo. El controller almacena el texto formateado;
/// para leer el valor entero usar [parsePesos] sobre `controller.text`.
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.allowZero = true,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final bool required;
  final bool enabled;

  /// Si false, valida que el monto sea > 0 (útil para "Valor recibido").
  final bool allowZero;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        MoneyInputFormatter(),
      ],
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixText: r'$ ',
        helperText: helperText,
      ),
      validator: (v) {
        final s = (v ?? '').trim();
        if (s.isEmpty) {
          return required ? 'Campo obligatorio' : null;
        }
        final n = parsePesos(s);
        if (n == null) return 'Debe ser un número';
        if (n < 0) return 'No puede ser negativo';
        if (!allowZero && n == 0) return 'Debe ser mayor a cero';
        return null;
      },
    );
  }
}

/// Campo de cédula colombiana. Formatea con puntos en vivo.
class CedulaField extends StatelessWidget {
  const CedulaField({
    super.key,
    required this.controller,
    this.label = 'Cédula',
    this.required = true,
    this.enabled = true,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final bool enabled;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: const [AutofillHints.creditCardNumber], // mejor que nada
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CedulaInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        helperText: helperText ?? 'Solo números',
        prefixIcon: const Icon(Icons.badge_outlined),
      ),
      validator: (v) {
        final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.isEmpty) {
          return required ? 'Campo obligatorio' : null;
        }
        if (digits.length < 4) return 'Cédula muy corta';
        if (digits.length > 12) return 'Cédula muy larga';
        return null;
      },
    );
  }
}

/// Campo de teléfono. Formatea como "300 123 4567".
class TelefonoField extends StatelessWidget {
  const TelefonoField({
    super.key,
    required this.controller,
    this.label = 'Teléfono',
    this.required = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TelefonoInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: const Icon(Icons.phone_outlined),
        hintText: '300 123 4567',
      ),
      validator: (v) {
        final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.isEmpty) {
          return required ? 'Campo obligatorio' : null;
        }
        if (digits.length < 7) return 'Teléfono muy corto';
        if (digits.length > 10) return 'Teléfono muy largo';
        return null;
      },
    );
  }
}
