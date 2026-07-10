abstract class CoreReplatementServiceState {}

class CoreReplatementServiceInitialState extends CoreReplatementServiceState {}

class CoreReplacementServiceUploadPaymentProofSuccessState extends CoreReplatementServiceState {}

class CoreReplacementServiceUploadPaymentProofFailState extends CoreReplatementServiceState {
  final String message;
  CoreReplacementServiceUploadPaymentProofFailState(this.message);
}
