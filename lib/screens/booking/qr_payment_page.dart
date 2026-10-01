part of 'booking_flow.dart';

extension _QrPaymentPage on _BookingFlowState {
  List<Widget> qrPage() => [
    const SizedBox(height: 22),
    pad(
      const Text(
        'กรุณาชำระเงินผ่าน โมบายแบงก์กิ้ง แอปพลิเคชันของคุณ',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    ),
    const SizedBox(height: 15),
    pad(
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Container(
              color: _surface,
              padding: const EdgeInsets.all(20),
              child: pair(
                seconds == 0 ? 'หมดเวลาตัวอย่าง' : 'รอการชำระเงิน',
                countdown,
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'ตัวอย่างหน้าชำระเงิน',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFF1B3960),
              padding: const EdgeInsets.all(18),
              child: const Text(
                '▣  THAI QR\n     PAYMENT',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'PromptPay',
                    style: TextStyle(
                      color: Color(0xFF124873),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        color: Color(0xFFBBBBBB),
                        size: 175,
                      ),
                      ColoredBox(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'ตัวอย่างเท่านั้น',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'รวม: $total บาท',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'REVERIE CINEPLEX',
                    style: TextStyle(
                      color: Color(0xFF9E6923),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    pad(
      const Text(
        'QR Code นี้เป็นการจำลองเท่านั้น',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    ),
    if (seconds == 0)
      pad(
        TextButton(onPressed: startQr, child: const Text('เริ่มตัวอย่างใหม่')),
      ),
  ];
}