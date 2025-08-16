const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "habipbahceci30@gmail.com",
    pass: "kitw shfl ispi xukg",
  },
});

exports.sendVerificationEmailV2 = onDocumentWritten("verification_codes/{email}", async (event) => {
  const snap = event.data.after;
  const context = event;
  if (!snap) return; // Silme işlemi ise çık
  const data = snap.data();
  const email = context.params.email;
  const code = data.code;

  // 1 dakika bekleme kontrolü
  const now = Date.now();
  const lastSentAt = data.last_sent_at ? data.last_sent_at : 0;
  if (lastSentAt && now - lastSentAt < 60 * 1000) {
    console.log(`Kod gönderimi engellendi: ${email} için 1 dakika dolmadı.`);
    return;
  }

  // last_sent_at alanını güncelle
  await admin.firestore().collection('verification_codes').doc(email).update({
    last_sent_at: now
  });

  const mailOptions = {
    from: "Bonavias Cafe & Desserts",
    to: email,
    subject: "Doğrulama Kodunuz",
    text: `Doğrulama kodunuz: ${code}`,
    html: `
      <div style="max-width:480px;margin:0 auto;background:#fff;border-radius:12px;box-shadow:0 2px 8px rgba(0,0,0,0.07);padding:32px 24px;font-family: 'Segoe UI', 'Roboto', Arial, sans-serif;">
        <div style="text-align:center;margin-bottom:24px;">
          <img src="https://bonavias.com.tr/assets/img/logo-dark.png" alt="Bonavias Logo" style="height:48px;margin-bottom:8px;"/>
        </div>
        <h3 style="color:#181828;font-size:20px;font-weight:600;margin-bottom:8px;text-align:center;">Doğrulama Kodunuz</h3>
        <p style="color:#666670;font-size:16px;text-align:center;margin-bottom:24px;">Aşağıdaki kodu uygulamada ilgili alana girerek işleminizi tamamlayabilirsiniz.</p>
        <div style="background:#F7F6F3;border-radius:8px;padding:20px 0;margin:0 auto 24px auto;text-align:center;max-width:220px;">
          <span style="font-size:32px;letter-spacing:8px;color:#B8835A;font-weight:700;">${code}</span>
        </div>
        <p style="color:#A0A5BA;font-size:14px;text-align:center;margin-bottom:0;">Bu kodu kimseyle paylaşmayın. Yardım için <a href="mailto:destek@bonavias.com" style="color:#B8835A;text-decoration:none;">destek@bonavias.com</a> adresine yazabilirsiniz.</p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log("E-posta gönderildi:", email);
  } catch (error) {
    console.error("E-posta gönderilemedi:", error);
  }
});

