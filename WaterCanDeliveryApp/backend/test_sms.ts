
async function testSMS() {
  const fast2smsKey = '3pmsdKPBgLS9nGZq47faurkHzvteh6WFDViAjIJobl0N5QE1UXiTPxHU5nfyc2qXaZBm3D1s7ERFKpGO';
  const phone = '9486706646'; // user's phone from screenshot
  const otp = '1234';

  try {
    const response = await fetch('https://www.fast2sms.com/dev/bulkV2', {
      method: 'POST',
      headers: {
        'authorization': fast2smsKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        route: 'q',
        message: `Your WaterCan OTP is ${otp}. Valid for 5 minutes.`,
        numbers: phone,
      }),
    });
    const data = await response.json();
    console.log('Fast2SMS Response:', data);
  } catch (e) {
    console.error('Error:', e);
  }
}

testSMS();
