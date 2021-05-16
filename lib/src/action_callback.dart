typedef ActionCallback<T> = void Function(T? key);
typedef FormFieldValidatorAsync<T> = Future<String?> Function(T? value);
