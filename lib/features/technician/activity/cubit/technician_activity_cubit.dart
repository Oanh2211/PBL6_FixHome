import 'package:fixhome/features/technician/activity/api/technician_activity_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/technician_order_model.dart';

abstract class TechnicianActivityState {}

class TechnicianActivityInitial extends TechnicianActivityState {}

class TechnicianActivityLoading extends TechnicianActivityState {}

class TechnicianActivityLoaded extends TechnicianActivityState {
  final List<TechnicianOrderModel> orders;
  final List<TechnicianOrderModel> filteredOrders;
  final String currentScope; // ACTIVE, CANCELLED, COMPLETED
  final String searchQuery;

  TechnicianActivityLoaded({
    required this.orders,
    required this.filteredOrders,
    required this.currentScope,
    this.searchQuery = '',
  });
}

class TechnicianActivityError extends TechnicianActivityState {
  final String message;
  TechnicianActivityError(this.message);
}

class TechnicianActivityCubit extends Cubit<TechnicianActivityState> {
  final TechnicianActivityApi _api;

  TechnicianActivityCubit(this._api) : super(TechnicianActivityInitial());

  String _currentScope = 'ACTIVE';
  String _searchQuery = '';
  List<TechnicianOrderModel> _allOrders = [];

  Future<void> loadOrders({String? scope}) async {
    if (scope != null) _currentScope = scope;
    emit(TechnicianActivityLoading());
    try {
      _allOrders = await _api.getAssignedOrders(scope: _currentScope);
      _applySearchAndEmit();
    } catch (e) {
      emit(TechnicianActivityError(e.toString()));
    }
  }

  void searchOrders(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearchAndEmit();
  }

  void _applySearchAndEmit() {
    final filtered = _searchQuery.isEmpty
        ? _allOrders
        : _allOrders.where((o) {
            return o.orderCode.toLowerCase().contains(_searchQuery) ||
                o.contactName.toLowerCase().contains(_searchQuery) ||
                o.contactPhone.toLowerCase().contains(_searchQuery) ||
                o.deviceName.toLowerCase().contains(_searchQuery);
          }).toList();

    emit(
      TechnicianActivityLoaded(
        orders: _allOrders,
        filteredOrders: filtered,
        currentScope: _currentScope,
        searchQuery: _searchQuery,
      ),
    );
  }
}
