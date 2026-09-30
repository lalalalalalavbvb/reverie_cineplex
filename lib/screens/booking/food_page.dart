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
          '📍 ${_branches[branch]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    pad(heading('คอมโบเซ็ต')),
    pad(
      LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 14,
          runSpacing: 20,
          children: [
            for (int i = 0; i < _BookingFlowState.products.length; i++)
              SizedBox(
                width: (constraints.maxWidth - 14) / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ReferenceRegion(
                          asset: 'food_reference.png',
                          region: [
                            const Rect.fromLTWH(.037, .202, .445, .203),
                            const Rect.fromLTWH(.52, .202, .443, .203),
                            const Rect.fromLTWH(.037, .480, .445, .203),
                            const Rect.fromLTWH(.037, .79, .445, .09),
                            const Rect.fromLTWH(.52, .79, .443, .09),
                          ][i],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _BookingFlowState.products[i],
                      style: const TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_BookingFlowState.prices[i]} บาท',
                            style: const TextStyle(
                              color: bookingGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if ((quantities[i] ?? 0) > 0) ...[
                          InkWell(
                            onTap: () => update(
                              () => quantities[i] = quantities[i]! - 1,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.remove, size: 18),
                            ),
                          ),
                          Text('${quantities[i]}'),
                        ],
                        InkWell(
                          onTap: () => update(
                            () => quantities[i] = (quantities[i] ?? 0) + 1,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.add_circle, color: bookingGold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  ];
}
