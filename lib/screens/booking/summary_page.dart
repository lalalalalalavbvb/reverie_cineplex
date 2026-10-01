part of 'booking_flow.dart';

extension _SummaryPage on _BookingFlowState {
  List<Widget> summary() => [
    banner(),
    pad(heading(selectedCinema)),
    pad(pair(date, time)),
    const Divider(indent: 16, endIndent: 16),
    pad(heading('ชำระเงิน')),
    pad(heading('ที่นั่งที่เลือก')),
    pad(
      pair(
        seatNames,
        seats.every((s) => 'ABCD'.contains(s[0]))
            ? 'Honeymoon'
            : 'Normal / Honeymoon',
      ),
    ),
    pad(pair('จำนวน', '${seats.length}')),
    pad(pair('ยอดชำระตั๋ว', '$ticketTotal บาท')),
    for (final e in quantities.entries)
      if (e.value > 0 && foodById(e.key) != null)
        pad(
          pair(
            '${foodById(e.key)!.name} × ${e.value}',
            '${foodById(e.key)!.price * e.value} บาท',
          ),
        ),
    const Divider(indent: 16, endIndent: 16),
    pad(heading('ส่วนลด')),
    pad(
      const ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        title: Text('M PASS'),
        trailing: Switch(value: false, onChanged: null),
      ),
    ),
    pad(
      OutlinedButton(
        onPressed: () => message('ยังไม่มีส่วนลดที่ใช้ได้สำหรับรอบนี้'),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ใช้ส่วนลด', style: TextStyle(fontSize: 20)),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    ),
    const SizedBox(height: 16),
    totalBar(),
    pad(
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'อีเมล (ไม่บังคับ)'),
      ),
    ),
  ];
}