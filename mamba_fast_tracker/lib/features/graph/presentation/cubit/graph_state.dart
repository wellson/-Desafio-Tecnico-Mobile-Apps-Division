import 'package:equatable/equatable.dart';

class GraphData {
  final DateTime date;
  final double calories;
  final double fastingHours;

  const GraphData({
    required this.date,
    required this.calories,
    required this.fastingHours,
  });
}

abstract class GraphState extends Equatable {
  const GraphState();
  @override
  List<Object?> get props => [];
}

class GraphInitial extends GraphState {}

class GraphLoading extends GraphState {}

class GraphLoaded extends GraphState {
  final List<GraphData> weeklyData;

  const GraphLoaded(this.weeklyData);

  @override
  List<Object?> get props => [weeklyData];
}

class GraphError extends GraphState {
  final String message;
  const GraphError(this.message);

  @override
  List<Object?> get props => [message];
}
