//tells about the payments done int the groups.
class SplitPaymentModel {
  final String title; //title eg Dinner At Mc D
  final double totalAmount;
  final Map<String, double> userSplits;
  final String paidBy;

  SplitPaymentModel({
    required this.title,
    required this.totalAmount,
    required this.userSplits,
    required this.paidBy
  });
}
