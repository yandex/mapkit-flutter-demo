enum RoutingType {
  driving(purpose: "driver"),
  pedestrian(purpose: "pedestrian"),
  publicTransport(purpose: "public transport");

  final String purpose;

  const RoutingType({required this.purpose});
}
