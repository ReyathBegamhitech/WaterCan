async function test2Factor() {
  const twoFactorKey = '9b25c36e-b1a9-11f1-90d7-0200cd936042';
  const phone = '9486706646'; // user's phone
  const otp = '1234';

  try {
    const url = `https://2factor.in/API/V1/${twoFactorKey}/SMS/${phone}/${otp}/OTP1`;
    const response = await fetch(url);
    const data = await response.json();
    console.log('2Factor Response (V1):', data);
  } catch (e) {
    console.error('Error V1:', e);
  }

  try {
    const url = `https://2factor.in/v2/SMS/${twoFactorKey}/SMS/${phone}/${otp}/OTP1`;
    const response = await fetch(url);
    const data = await response.json();
    console.log('2Factor Response (v2):', data);
  } catch (e) {
    console.error('Error v2:', e);
  }
}

test2Factor();
