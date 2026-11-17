import 'package:fixhome/features/customer/activity/model/quote_model.dart';

abstract class QuoteDetailState {}

class QuoteDetailInitial extends QuoteDetailState {}

class QuoteDetailLoading extends QuoteDetailState {}

class QuoteDetailLoaded extends QuoteDetailState {
  final QuoteModel quote;
  QuoteDetailLoaded(this.quote);
}

class QuoteDetailError extends QuoteDetailState {
  final String message;
  QuoteDetailError(this.message);
}
