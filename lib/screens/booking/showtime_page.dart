part of 'booking_flow.dart';

const _branchDistances = {
  'เมเจอร์ โลตัส กำแพงแสน': '3.45 กม.',
  'เมเจอร์ โลตัส นครปฐม': '24.56 กม.',
  'เมเจอร์ เซ็นทรัล นครปฐม': '26.10 กม.',
};

extension _ShowtimePage on _BookingFlowState {
  List<Widget> showtimes() {
    final entries = availableShowtimes;
    final branches = entries
        .map((e) => e.detail.split('|').first)
        .toSet()
        .toList();
    List<AdminItem> showsAt(String branchName) =>
        entries.where((e) => e.detail.split('|').first == branchName).toList()
          ..sort(
            (a, b) =>
                a.detail.split('|')[2].compareTo(b.detail.split('|')[2]),
          );
    final hasVisibleBranch = branches.asMap().entries.any(
      (e) =>
          e.value.toLowerCase().contains(query.toLowerCase()) &&
          (!favoritesOnly || favorites.contains(e.key)),
    );

    return [
      banner(large: true),
      pad(
        Text(
          _thaiMonths[selectedDate.month - 1],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 90,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: _dayCount,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
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
                    i == 0 ? 'วันนี้' : _thaiWeekdays[dateAt(i).weekday - 1],
                    style: TextStyle(
                      color: day == i ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${dateAt(i).day}',
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
      for (int i = 0; i < branches.length; i++)
        if (branches[i].toLowerCase().contains(query.toLowerCase()) &&
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
                          branches[i],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        if (_branchDistances[branches[i]] != null)
                          Text(
                            _branchDistances[branches[i]]!,
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
                  onPressed: () => update(
                    () => expandedBranch = expandedBranch == i ? -1 : i,
                  ),
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
                  for (final show in showsAt(branches[i]))
                    OutlinedButton(
                      onPressed: () async {
                        if (!await ensureLoggedIn()) return;
                        branch = i;
                        selectedCinema = branches[i];
                        showtimePrice = show.price;
                        selectedLegacyShowtime = show.id.startsWith('legacy:');
                        time = show.detail.split('|')[2];
                        seats.clear();
                        quantities.clear();
                        go(1);
                      },
                      child: Text(
                        show.detail.split('|')[2],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const Divider(indent: 16, endIndent: 16, height: 30),
        ],
      if (entries.isEmpty)
        pad(const Text('ยังไม่มีรอบฉายสำหรับภาพยนตร์นี้ในวันที่เลือก'))
      else if (!hasVisibleBranch)
        pad(const Text('ไม่พบสาขาที่ค้นหา')),
    ];
  }
}