part of 'booking_flow.dart';

extension _FoodPage on _BookingFlowState {
  List<Widget> foodPage() => [
    pad(
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '📍 $selectedCinema',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    pad(heading('คอมโบเซ็ต')),
    pad(
      ListenableBuilder(
        listenable: CinemaCatalog.service,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 14,
            runSpacing: 20,
            children: [
              for (final food in foodMenu)
                SizedBox(
                  width: (constraints.maxWidth - 14) / 2,
                  child: _foodCard(food),
                ),
            ],
          ),
        ),
      ),
    ),
  ];

  Widget _foodCard(_FoodItem food) {
    final count = quantities[food.id] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: food.region != null
                ? ReferenceRegion(
                    asset: 'food_reference.png',
                    region: food.region!,
                  )
                : FoodImage(base64: food.image),
          ),
        ),
        const SizedBox(height: 8),
        Text(food.name, style: const TextStyle(fontSize: 16)),
        if (food.detail.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              food.detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${food.price} บาท',
                style: const TextStyle(
                  color: bookingGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (count > 0) ...[
              InkWell(
                onTap: () => update(() {
                  if (count <= 1) {
                    quantities.remove(food.id);
                  } else {
                    quantities[food.id] = count - 1;
                  }
                }),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.remove, size: 18),
                ),
              ),
              Text('$count'),
            ],
            InkWell(
              onTap: () => update(() => quantities[food.id] = count + 1),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.add_circle, color: bookingGold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}