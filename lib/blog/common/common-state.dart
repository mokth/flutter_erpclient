import 'package:equatable/equatable.dart';


abstract class SearchState extends Equatable {}

class  SearchUninitialized extends  SearchState {
  @override
  String toString() => 'SearchUninitialized';
}

class  SearchError extends  SearchState {
  @override
  String toString() => 'SearchError';
}

class  SearchCompleted extends  SearchState {
  @override
  String toString() => 'SearchCompleted';
}


class SearchData extends  SearchState {
 
  @override
  String toString() => 'SearchData';
}


class  SearchLoading extends  SearchState {
  @override
  String toString() => 'SearchLoading';
}