// Lokasi: lib/features/quiz/presentation/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:pijar_baca/features/quiz/data/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  void _answerQuestion(int selectedIndex) {
    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;
      if (selectedIndex == widget.questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < widget.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
          _selectedAnswerIndex = null;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Kuis Selesai!'),
        content: Text('Skor Anda: $_score dari ${widget.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Kuis Buku (${_currentQuestionIndex + 1}/${widget.questions.length})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question.question, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            ...List.generate(question.options.length, (index) {
              
              Color buttonColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
              Color textColor = Theme.of(context).colorScheme.onSurface;

              // --- LOGIKA PEWARNAAN YANG LEBIH EKSPLISIT ---
              if (_isAnswered) {
                bool isCorrectAnswer = (index == question.correctAnswerIndex);
                bool isSelectedAnswer = (index == _selectedAnswerIndex);

                // Print untuk debugging, akan muncul di Debug Console
                print('Tombol ke-$index: isCorrect=$isCorrectAnswer, isSelected=$isSelectedAnswer');

                if (isCorrectAnswer) {
                  // Jawaban yang benar SELALU hijau
                  buttonColor = Colors.green.shade600;
                  textColor = Colors.white;
                } else if (isSelectedAnswer) {
                  // Jawaban yang dipilih dan salah, menjadi merah
                  buttonColor = Colors.red.shade600;
                  textColor = Colors.white;
                }
                // Tombol lain yang salah dan tidak dipilih akan tetap berwarna default
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: _isAnswered ? null : () => _answerQuestion(index),
                  child: Text(question.options[index], textAlign: TextAlign.center),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}