import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../bases/base_state_controller.dart';
import '../../states/app_state.dart';
import 'loading_indicator.dart';
import 'error_widget.dart';
import 'empty_state.dart';

/// Reactive widget that rebuilds based on [AppState] changes.
/// Provide [operationKey] matching the key used in [BaseStateController.handleState].
class StateBuilder<T> extends StatelessWidget {
  const StateBuilder({
    super.key,
    required this.controller,
    required this.operationKey,
    required this.onSuccess,
    this.onLoading,
    this.onError,
    this.onInitial,
  });

  final BaseStateController controller;
  final String operationKey;
  final Widget Function(T data, String? message) onSuccess;
  final Widget Function()? onLoading;
  final Widget Function(String message, VoidCallback retry)? onError;
  final Widget Function()? onInitial;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.getState<T>(operationKey);
      return state.when(
        onInitial: () => onInitial?.call() ?? const SizedBox.shrink(),
        onLoading: () =>
            onLoading?.call() ?? const LoadingIndicator(),
        onSuccess: (data, message) => onSuccess(data, message),
        onError: (message, code) =>
            onError?.call(
              message,
              () => controller.onInit(),
            ) ??
            BaseErrorWidget(
              message: message,
              onRetry: () => controller.onInit(),
            ),
      );
    });
  }
}

/// StateBuilder for lists with empty-state support.
class ListStateBuilder<T> extends StatelessWidget {
  const ListStateBuilder({
    super.key,
    required this.controller,
    required this.operationKey,
    required this.onSuccess,
    this.emptyMessage = 'No items found',
    this.emptyIcon,
    this.onLoading,
    this.onError,
  });

  final BaseStateController controller;
  final String operationKey;
  final Widget Function(List<T> data) onSuccess;
  final String emptyMessage;
  final IconData? emptyIcon;
  final Widget Function()? onLoading;
  final Widget Function(String message, VoidCallback retry)? onError;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.getState<List<T>>(operationKey);
      return state.when(
        onInitial: () => const SizedBox.shrink(),
        onLoading: () => onLoading?.call() ?? const LoadingIndicator(),
        onSuccess: (data, _) => data.isEmpty
            ? EmptyStateWidget(
                message: emptyMessage,
                icon: emptyIcon,
              )
            : onSuccess(data),
        onError: (message, _) =>
            onError?.call(message, () => controller.onInit()) ??
            BaseErrorWidget(
              message: message,
              onRetry: () => controller.onInit(),
            ),
      );
    });
  }
}

/// Overlay that shows loading indicator on top of content.
class StateLoadingOverlay extends StatelessWidget {
  const StateLoadingOverlay({
    super.key,
    required this.controller,
    required this.operationKey,
    required this.child,
  });

  final BaseStateController controller;
  final String operationKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading =
          controller.getState(operationKey).isLoading;
      return Stack(
        children: [
          child,
          if (isLoading)
            const ColoredBox(
              color: Color(0x40000000),
              child: Center(child: LoadingIndicator()),
            ),
        ],
      );
    });
  }
}

/// Inline error banner shown conditionally.
class StateErrorBanner extends StatelessWidget {
  const StateErrorBanner({
    super.key,
    required this.controller,
    required this.operationKey,
    this.onRetry,
  });

  final BaseStateController controller;
  final String operationKey;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.getState(operationKey);
      if (!state.isError) return const SizedBox.shrink();
      final message = (state as AppStateError).message;
      return Container(
        padding: const EdgeInsets.all(12),
        color: Colors.red.shade50,
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.red)),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    });
  }
}

/// Multi-key conditional builder.
class MultiStateBuilder extends StatelessWidget {
  const MultiStateBuilder({
    super.key,
    required this.controller,
    required this.keys,
    required this.onAllSuccess,
    this.onLoading,
    this.onError,
  });

  final BaseStateController controller;
  final List<String> keys;
  final Widget Function() onAllSuccess;
  final Widget Function()? onLoading;
  final Widget Function(String message)? onError;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final states = keys.map((k) => controller.getState(k)).toList();
      if (states.any((s) => s.isLoading || s.isInitial)) {
        return onLoading?.call() ?? const LoadingIndicator();
      }
      final errorState = states.whereType<AppStateError>().firstOrNull;
      if (errorState != null) {
        return onError?.call(errorState.message) ??
            BaseErrorWidget(message: errorState.message);
      }
      if (states.every((s) => s.isSuccess)) {
        return onAllSuccess();
      }
      return const SizedBox.shrink();
    });
  }
}
