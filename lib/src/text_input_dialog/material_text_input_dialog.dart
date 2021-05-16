import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/src/extensions/extensions.dart';

class MaterialTextInputDialog extends StatefulWidget {
  const MaterialTextInputDialog({
    required this.textFields,
    this.title,
    this.message,
    this.okLabel,
    this.cancelLabel,
    this.isDestructiveAction = false,
    this.style = AdaptiveStyle.adaptive,
    this.actionsOverflowDirection = VerticalDirection.up,
    this.useRootNavigator = true,
    this.fullyCapitalized = true,
  });
  @override
  _MaterialTextInputDialogState createState() =>
      _MaterialTextInputDialogState();

  final List<DialogTextField> textFields;
  final String? title;
  final String? message;
  final String? okLabel;
  final String? cancelLabel;
  final bool isDestructiveAction;
  final AdaptiveStyle style;
  final VerticalDirection actionsOverflowDirection;
  final bool useRootNavigator;
  final bool fullyCapitalized;
}

class _MaterialTextInputDialogState extends State<MaterialTextInputDialog> {
  late final List<TextEditingController> _textControllers = widget.textFields
      .map((tf) => TextEditingController(text: tf.initialText))
      .toList();
  final _formKey = GlobalKey<FormState>();
  var _autovalidateMode = AutovalidateMode.disabled;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final c in _textControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = widget.title;
    final message = widget.message;
    final navigator = Navigator.of(
      context,
      rootNavigator: widget.useRootNavigator,
    );
    void pop() => navigator.pop(
          _textControllers.map((c) => c.text).toList(),
        );
    void cancel() => navigator.pop();
    final titleText = title == null ? null : Text(title);
    final cancelLabel = widget.cancelLabel;
    final okLabel = widget.okLabel;
    final okText = Text(
      (widget.fullyCapitalized ? okLabel?.toUpperCase() : okLabel) ??
          MaterialLocalizations.of(context).okButtonLabel,
      style: TextStyle(
        color: widget.isDestructiveAction ? colorScheme.error : null,
      ),
    );
    final validationMessage = _validationMessage;
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: titleText,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Text(message),
                    ),
                  ),
                ),
              ),
            ..._textControllers.mapWithIndex((c, i) {
              final textField = widget.textFields[i];
              return TextFormField(
                controller: c,
                autofocus: i == 0,
                obscureText: textField.obscureText,
                keyboardType: textField.keyboardType,
                minLines: textField.minLines,
                maxLines: textField.maxLines,
                decoration: InputDecoration(
                  hintText: textField.hintText,
                  prefixText: textField.prefixText,
                  suffixText: textField.suffixText,
                ),
                validator: textField.validator,
                autovalidateMode: _autovalidateMode,
              );
              },
            ),
            validationMessage != null ? Container(
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.only(
                top: 4,
                left: 4,
              ),
              child: Text(
                validationMessage,
                style: const TextStyle(
                  color: Colors.redAccent,
                  height: 1.2,
                ),
                textAlign: TextAlign.start,
              ),
            ) : new Container()
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              (widget.fullyCapitalized
                      ? cancelLabel?.toUpperCase()
                      : cancelLabel) ??
                  MaterialLocalizations.of(context).cancelButtonLabel,
            ),
            onPressed: cancel,
          ),
          TextButton(
            child: okText,
            onPressed: () async{
              if (_formKey.currentState!.validate()) {
                if (await _validateAsync()) {
                  pop();
                }

              } else if (_autovalidateMode == AutovalidateMode.disabled) {
                setState(() {
                  _autovalidateMode = AutovalidateMode.always;
                });
              }
            },
          )
        ],
        actionsOverflowDirection: widget.actionsOverflowDirection,
      ),
    );
  }

  Future<bool> _validateAsync() async {
    var i = 0;
    final validations = <String>[];
    // ignore: avoid_function_literals_in_foreach_calls
    widget.textFields.forEach((element) async {
      final validator = element.validatorAsync;
      if (validator != null) {
        final result = await validator(_textControllers[i].text);
        if (result != null) {
          validations.add(result);
        }
      }
      i++;
    });
    setState(() {
      _validationMessage = validations.join('\n');
    });
    return validations.isEmpty;
  }
}
