class Question {
  final int id;
  final String text;
  final List<String> options;

  const Question({required this.id, required this.text, required this.options});

  Map<String, dynamic> toMsgpackMap() => {'i': id, 'x': text, 'o': options};

  factory Question.fromMsgpackMap(Map<String, dynamic> map) => Question(
    id: map['i'] as int,
    text: map['x'] as String,
    options: List<String>.from(map['o'] as List),
  );

  static const List<Question> defaults = [
    Question(
      id: 1,
      text: 'What is the capital of France?',
      options: ['London', 'Berlin', 'Paris', 'Madrid'],
    ),
    Question(
      id: 2,
      text: 'Which planet is closest to the Sun?',
      options: ['Venus', 'Mercury', 'Mars', 'Earth'],
    ),
    Question(id: 3, text: 'What is 2 + 2?', options: ['3', '4', '5', '6']),
    Question(
      id: 4,
      text: 'What color is the sky on a clear day?',
      options: ['Red', 'Green', 'Blue', 'Yellow'],
    ),
    Question(
      id: 5,
      text: 'Which ocean is the largest?',
      options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
    ),
  ];
}
