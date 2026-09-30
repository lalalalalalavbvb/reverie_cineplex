part of 'booking_flow.dart';

extension _PaymentPage on _BookingFlowState {
  List<Widget> paymentPage() => [
    pad(heading('ช่องทางการชำระเงิน')),
    pad(const Text('เลือกช่องทางการชำระเงิน', style: TextStyle(fontSize: 17))),
    const SizedBox(height: 20),
    pad(
      LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 0; i < 4; i++)
              SizedBox(
                width: (constraints.maxWidth - 24) / 3,
                child: InkWell(
                  onTap: () {
                    if (i != 0) {
                      message('ช่องทางนี้ยังไม่เปิดให้บริการ');
                      return;
                    }
                    update(() => payment = i);
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: payment == i ? bookingGold : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          [
                            Icons.qr_code_2,
                            Icons.account_balance,
                            Icons.account_balance_wallet_outlined,
                            Icons.credit_card,
                          ][i],
                          size: 42,
                          color: i == 1 ? Colors.green : Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ['ไทยคิวอาร์', 'K PLUS', 'อี-วอลเล็ต', 'การ์ด'][i],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 40),
    totalBar(),
    pad(
      FilledButton(
        onPressed: payment == null ? null : startQr,
        child: const Text('ชำระเงิน'),
      ),
    ),
    pad(
      const Text(
        'โหมดตัวอย่าง • ยังไม่มีการเรียกเก็บเงิน',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    ),
  ];
}
