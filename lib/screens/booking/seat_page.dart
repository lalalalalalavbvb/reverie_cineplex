part of 'booking_flow.dart';

extension _SeatPage on _BookingFlowState {
  List<Widget> seatPage() => [
    banner(),
    pad(heading(selectedCinema)),
    pad(const Text('Theatre 1  ◖)) TH  ▣ EN\n\nG    2D')),
    pad(heading(date)),
    pad(
      Wrap(
        spacing: 8,
        children: [
          for (final t in ['11:00', '14:00', '17:20', '20:00'])
            ChoiceChip(
              label: Text(t),
              selected: time == t,
              onSelected: (_) => update(() {
                time = t;
                seats.clear();
              }),
            ),
        ],
      ),
    ),
    const SizedBox(height: 25),
    pad(
      Container(
        height: 80,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFAE9465), width: 4)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF554538), Color(0xFF111111)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.elliptical(200, 30)),
        ),
        child: const Text('หน้าจอ'),
      ),
    ),
    pad(
      LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            for (int r = 0; r < 11; r++)
              Padding(
                padding: EdgeInsets.only(bottom: r == 2 ? 26 : 4),
                child: Row(
                  children: [
                    for (int c = 1; c <= 13; c++)
                      Expanded(
                        child: Builder(
                          builder: (_) {
                            final id = '${String.fromCharCode(75 - r)}$c';
                            final occupied = r == 5 && c >= 10;
                            final selected = seats.contains(id);
                            return Semantics(
                              button: true,
                              selected: selected,
                              label: 'ที่นั่ง $id${occupied ? ' จองแล้ว' : ''}',
                              child: Tooltip(
                                message:
                                    '$id • ${selectedLegacyShowtime && r >= 7 ? 180 : showtimePrice} บาท',
                                child: InkWell(
                                  key: ValueKey('seat-$id'),
                                  onTap: occupied
                                      ? null
                                      : () => update(() {
                                          selected
                                              ? seats.remove(id)
                                              : seats.add(id);
                                        }),
                                  child: SizedBox(
                                    height: constraints.maxWidth / 13,
                                    child: selected
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: bookingGold,
                                            size: 23,
                                          )
                                        : CustomPaint(
                                            painter: SeatPainter(
                                              occupied
                                                  ? Colors.grey.shade700
                                                  : r >= 7
                                                  ? const Color(0xFF69359B)
                                                  : const Color(0xFFB42417),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 54),
    pad(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (selectedLegacyShowtime) ...[
            seatLegend('Normal', 160, const Color(0xFFB42417)),
            seatLegend('Honeymoon', 180, const Color(0xFF69359B)),
          ] else
            seatLegend('Ticket', showtimePrice, const Color(0xFFB42417)),
        ],
      ),
    ),
    const SizedBox(height: 20),
    pad(
      pair(
        'ที่นั่งที่เลือก\n${seats.isEmpty ? 'กรุณาเลือกที่นั่ง' : seatNames}',
        '$ticketTotal บาท',
        gold: true,
      ),
    ),
    pad(
      Form(
        key: form,
        child: TextFormField(
          controller: phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'เบอร์โทรศัพท์',
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              RegExp(
                r'^0\d{8,9}$',
              ).hasMatch((v ?? '').replaceAll(RegExp(r'[\s-]'), ''))
              ? null
              : 'กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง',
        ),
      ),
    ),
  ];
  Widget seatLegend(String label, int price, Color color) => Container(
    width: 120,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF383838),
      border: Border.all(color: color, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(painter: SeatPainter(color)),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
          '$price บาท',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    ),
  );
}
