class ChatStep {
  final String question;
  final List<String> options;
  final bool expectsImage;

  ChatStep({
    required this.question,
    required this.options,
    this.expectsImage = false,
  });
}
