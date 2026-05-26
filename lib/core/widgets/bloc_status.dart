enum BlocStatus {
  initial(0),
  loading(1),
  uploading(2),
  success(200),
  checking(3),
  error(500),
  validateError(400),
  accessDenied(40000000);

  final int value;
  const BlocStatus(this.value);
}

class BaseState {
  const BaseState({
    this.status = BlocStatus.initial,
    this.message,
  });

  final BlocStatus? status;
  final String? message;

  bool get isLoading => status == BlocStatus.loading;
  bool get isSuccess => status == BlocStatus.success;
  bool get isValidateError => status == BlocStatus.validateError;
  bool get isError => status == BlocStatus.error;
}
