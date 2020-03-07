import 'package:flutter/material.dart';
import 'package:one_d_m/Components/ErrorText.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';

class ApiBuilder<E> extends StatelessWidget {
  Widget Function(BuildContext, E) success;
  Widget Function(BuildContext, String) error;
  Widget loading;
  Future<ApiResult> future;
  bool withAlertDialog;

  ApiBuilder(
      {@required this.success,
      @required this.future,
      this.error,
      this.loading,
      this.withAlertDialog = true});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<ApiResult> snapshot) {
          if (snapshot.hasData && !snapshot.data.hasError())
            return success(context, snapshot.data.getData());
          if (snapshot.hasData)
            return _showError(context, snapshot.data.getMessage());
          if (snapshot.hasError)
            return _showError(context, "No connection! Try again later!");
          return loading != null
              ? loading
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget _showError(BuildContext context, String message) {
    if (withAlertDialog) {
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: Text(message),
          ));
    }
    if (error != null) return error(context, message);
    return Center(child: ErrorText(message));
  }
}
