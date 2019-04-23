import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:overlay_support/overlay_support.dart';
class VerifyValue<T>{

  VerifyValue.success(this.result);

  VerifyValue.errorMsg(this.errorMsg);

  T result;
  
  String errorMsg;
  
  bool get isSuccess=>errorMsg==null;
}

typedef TaskResultVerify<T>=VerifyValue Function(T result);

final TaskResultVerify _emptyVerify=(dynamic result){
  return VerifyValue.success(result);
};

TaskResultVerify<T> simgpleLoaderResultVerify<T>(bool test(T t),{String errorMsg="failed"}){
  assert(errorMsg != null);
  TaskResultVerify<T> verify = (result) {
    if (test(result)) {
      return VerifyValue.success(result);
    } else {
      return VerifyValue.errorMsg(errorMsg);
    }
  };
  return verify;
}

typedef LoaderWidgetBuilder<T> = Widget Function(
  BuildContext context,T result
);
typedef LoaderFailedWidgetBuilder<T> = Widget Function(BuildContext context,T result,String msg); 




class Loader<T> extends StatefulWidget{

  final FutureOr<T> initialData;

  ///task to load
  ///returned future'data will send by [LoaderWidgetBuilder]
  final Future<T> Function() loadTask;

  final LoaderWidgetBuilder<T> builder;

  final TaskResultVerify<T> resultVerify;

  ///if null, build a default error widget when load failed
  final LoaderFailedWidgetBuilder<T> failedWidgetBuilder;

  ///callback to handle error, could be null
  ///if [initialData] has been loaded, [failedWidgetBuilder] will never be invoked
  ///because current is showing initial data
  ///so we need send the error msg to callback, let caller handle it.
  final void Function<T>(BuildContext context, T result, String msg) onFailed;

  ///widget display when loading
  ///if null ,default to display a white background with a Circle Progress
  final WidgetBuilder loadingBuilder;
  
  const Loader({
     Key key,
     @required this.loadTask,
     @required this.builder,
     this.resultVerify,
     this.loadingBuilder,
     this.failedWidgetBuilder,
     this.initialData,
     this.onFailed=defaultFailedHandler})
     :assert (loadTask!=null),
     assert(builder!=null),
     super(key:key);


  
  static _LoaderState<T> of<T>(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<_LoaderState>());
  }

  static Widget buildSimpleFailedWidget<T>(
      BuildContext context, T result, String msg) {
        return Container(
         constraints: BoxConstraints(minHeight: 200),
          child: Center(
            child: Column(
               mainAxisSize: MainAxisSize.min,
          children: <Widget>[
                Text(msg),
                SizedBox(height: 8),
                RaisedButton(
                  child: Text("重试"),
                  onPressed: () {
                  Loader.of(context).refresh();
                })
          ],
        ),
      ),
    );
  }


  static Widget buildSimpleLoadingWidget<T>(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  static void defaultFailedHandler<T>(
      BuildContext context, T result, String msg) {
    showSimpleNotification(context, Text(msg));
  }

  @override
  State<StatefulWidget> createState()=>_LoaderState<T>();
  }

enum _LoadState {
  loading,
  success,
  failed,
}
class _LoaderState<T> extends State<Loader>{

  _LoadState state=_LoadState.loading;

  String _errorMsg;

  CancelableOperation task;

  T value;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.initialData!=null){
      _initData();
    }else{
      _loadData();
    }
  }

  _initData()async{
    try {
      final result=await widget.initialData;
      if (result!=null) {
        setState(() {
         this.value=result; 
        });
      }
    } catch (e) {
      debugPrint("Loader Initial data error $e");
    }
    _loadData();
  }

  _loadData(){
    if(state == _LoadState.loading && task != null){
         return task.value;
    }
    setState(() {
     state=_LoadState.loading; 
    });
    task?.cancel();
    task = CancelableOperation.fromFuture(widget.loadTask())
    ..value.then((v){
       var verify=(widget.resultVerify??_emptyVerify)(v);
       if (verify.isSuccess) {
         setState((){
         this.value=verify.result;
         state=_LoadState.success;
         });
       } else {
         setState(() {
          state=_LoadState.failed;
          _errorMsg=verify.errorMsg; 
         });
       }
    }).catchError((e,StackTrace stack){
      debugPrint('loadData error: $e');
      _errorMsg=e.toString()??'出错';
      state=_LoadState.failed;
      if (value!=null&&widget.onFailed!=null) {
        widget.onFailed(context,null,_errorMsg);
      }
      setState(() {});
    });

  }
  Future<void> refresh() async {
    await _loadData();
  }
  @override
  void dispose() { 
    task?.cancel();
    task=null;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (state == _LoadState.success || value != null) {
      return widget.builder(context, value);
    } else if (state == _LoadState.failed || _errorMsg != null) {
      return Builder(
          builder: (context) => (widget.failedWidgetBuilder ??
              Loader.buildSimpleFailedWidget)(context, value, _errorMsg));
    }
    return (widget.loadingBuilder ?? Loader.buildSimpleLoadingWidget)(context);
  }

}