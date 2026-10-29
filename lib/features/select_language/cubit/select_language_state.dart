import 'package:equatable/equatable.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {
  final String selectedCode; // 'vi' hoặc 'en'

  const LanguageInitial({required this.selectedCode});

  @override
  List<Object?> get props => [selectedCode];
}

class LanguageLoading extends LanguageState {
  const LanguageLoading();
}

class LanguageChangedSuccess extends LanguageState {
  final String selectedCode;
  const LanguageChangedSuccess(this.selectedCode);

  @override
  List<Object?> get props => [selectedCode];
}
