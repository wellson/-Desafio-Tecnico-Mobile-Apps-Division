import 'package:equatable/equatable.dart';
import 'package:mamba_fast_tracker/features/daily_summary/domain/entities/daily_summary.dart';

abstract class DailySummaryState extends Equatable {
  const DailySummaryState();
  @override
  List<Object?> get props => [];
}

class DailySummaryInitial extends DailySummaryState {}

class DailySummaryLoading extends DailySummaryState {}

class DailySummaryLoaded extends DailySummaryState {
  final DailySummary summary;

  const DailySummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class DailySummaryError extends DailySummaryState {
  final String message;
  const DailySummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
