/// Values sent to `POST /reports` as `category` (snake_case for JSON APIs).
enum ReportCategory {
  safety,
  behavior,
  paymentFare,
  other,
}

extension ReportCategoryApi on ReportCategory {
  String get apiValue => switch (this) {
        ReportCategory.safety => 'safety',
        ReportCategory.behavior => 'behavior',
        ReportCategory.paymentFare => 'payment_fare',
        ReportCategory.other => 'other',
      };
}
