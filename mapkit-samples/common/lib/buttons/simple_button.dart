import 'package:flutter/material.dart';

final class SimpleButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final TextStyle? textStyle;
  final double? size;
  final VoidCallback? onPressed;

  const SimpleButton({
    super.key,
    required this.text,
    this.isEnabled = true,
    this.textStyle,
    this.size = 20.0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: isEnabled ? onPressed : null,
      color: Theme.of(context).colorScheme.secondary,
      disabledColor: Colors.grey[700],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      padding: const EdgeInsets.all(10.0),
      minWidth: 0,
      height: size,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Text(
        text,
        style: (textStyle ?? Theme.of(context).textTheme.labelMedium)
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
