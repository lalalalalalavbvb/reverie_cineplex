part of 'booking_flow.dart';

extension _ShowtimePage on _BookingFlowState {
  List<Widget> showtimes() => [
    banner(large: true),
    pad(const Text('ก.ย.', style: TextStyle(fontWeight: FontWeight.bold))),
    SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (_, i) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => update(() => day = i),
          child: Container(
            width: 70,
            decoration: BoxDecoration(
              color: day == i ? bookingGold : _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: day == i ? bookingGold : Colors.white70,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ['วันนี้', 'เสาร์', 'อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ'][i],
                  style: TextStyle(
                    color: day == i ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${18 + i}',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: day == i ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    pad(
      Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => update(() => query = v),
              decoration: const InputDecoration(
                hintText: 'ค้นหา',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          IconButton(
            tooltip: 'แสดงเฉพาะสาขาที่ชอบ',
            onPressed: () => update(() => favoritesOnly = !favoritesOnly),
            icon: Icon(
              Icons.filter_list,
              color: favoritesOnly ? bookingGold : Colors.white,
            ),
          ),
        ],
      ),
    ),
    pad(
      const Text(
        'GLS          VIP Cinema',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    pad(heading('สาขาที่ชอบ / แนะนำ')),
    for (int i = 0; i < _branches.length; i++)
      if (_branches[i].contains(query) &&
          (!favoritesOnly || favorites.contains(i))) ...[
        pad(
          Row(
            children: [
              const Icon(
                Icons.account_balance,
                color: Color(0xFFBE6036),
                size: 35,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => update(
                    () => expandedBranch = expandedBranch == i ? -1 : i,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _branches[i],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        i == 0 ? '3.45 กม.' : '24.56 กม.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'สาขาที่ชอบ',
                onPressed: () => update(() {
                  favorites.contains(i)
                      ? favorites.remove(i)
                      : favorites.add(i);
                }),
                icon: Icon(
                  favorites.contains(i) ? Icons.star : Icons.star_border,
                  color: bookingGold,
                ),
              ),
              IconButton(
                onPressed: () =>
                    update(() => expandedBranch = expandedBranch == i ? -1 : i),
                icon: Icon(
                  expandedBranch == i ? Icons.expand_less : Icons.expand_more,
                ),
              ),
            ],
          ),
        ),
        if (expandedBranch == i) ...[
          pad(
            const Text(
              'Theatre 1  ◖)) TH  ▣ EN   G   2D',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          pad(
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in ['11:00', '14:00', '17:20', '20:00'])
                  OutlinedButton(
                    onPressed: () {
                      branch = i;
                      time = t;
                      seats.clear();
                      quantities.clear();
                      go(1);
                    },
                    child: Text(
                      t,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const Divider(indent: 16, endIndent: 16, height: 30),
      ],
    if (!_branches.asMap().entries.any(
      (e) =>
          e.value.contains(query) &&
          (!favoritesOnly || favorites.contains(e.key)),
    ))
      pad(const Text('ไม่พบสาขาที่ค้นหา')),
  ];
}
