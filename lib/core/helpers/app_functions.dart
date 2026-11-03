import 'package:flutter/material.dart';

class AppFunctions {
  // Exibição padronizada de mensagens (SnackBar)
  static void mostrarSnackBar(BuildContext context, String mensagem, {bool ehErro = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: ehErro ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Validações de Formulário reutilizáveis
  static String? validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o e-mail';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Informe um e-mail válido';
    }
    return null;
  }

  static String? validarSenha(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < minLength) {
      return 'A senha deve ter no mínimo $minLength caracteres';
    }
    return null;
  }

  static String? validarCampoObrigatorio(String? value, String nomeCampo) {
    if (value == null || value.trim().isEmpty) {
      return 'O campo $nomeCampo é obrigatório';
    }
    return null;
  }

  // Caixa de diálogo de confirmação genérica
  static Future<bool> confirmarAcao(
    BuildContext context, {
    required String titulo,
    required String mensagem,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }
}