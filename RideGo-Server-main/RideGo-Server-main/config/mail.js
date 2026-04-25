import nodemailer from 'nodemailer';

class MailService {
  constructor() {
    this.transporter = null;
  }

  init() {
    const emailUser = process.env.EMAIL_USER;
    const emailPassword = process.env.EMAIL_PASSWORD;

    if (!emailUser || !emailPassword) {
      console.warn('Email credentials not configured. Emails will be mocked.');
      return;
    }

    this.transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: emailUser,
        pass: emailPassword,
      },
      // Development fix for environments with SSL interception/self-signed certs.
      tls: {
        rejectUnauthorized: false,
      },
    });
  }

  async sendOTP(email, code, type = 'login') {
    const subject = this.getSubject(type);
    const htmlContent = this.getEmailTemplate(code, type);

    const mailOptions = {
      from: process.env.EMAIL_USER || 'noreply@ridego.com',
      to: email,
      subject,
      html: htmlContent,
    };

    if (!this.transporter) {
      console.log(`[MOCK EMAIL] To: ${email}, Subject: ${subject}, Code: ${code}`);
      return { messageId: 'mock-' + Date.now() };
    }

    try {
      const info = await this.transporter.sendMail(mailOptions);
      console.log(`Email sent: ${info.messageId}`);
      return info;
    } catch (error) {
      console.error('Error sending email:', error);
      throw new Error('Failed to send OTP email');
    }
  }

  getSubject(type) {
    const subjects = {
      login: 'Your RideGO Login Code',
      account_creation: 'Verify Your RideGO Account',
      password_reset: 'Reset Your RideGO Password',
      email_verification: 'Verify Your Email Address',
    };
    return subjects[type] || 'Your RideGO Verification Code';
  }

  getEmailTemplate(code, type) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
          }
          .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
          .header {
            text-align: center;
            margin-bottom: 30px;
          }
          .logo {
            font-size: 28px;
            font-weight: bold;
            color: #ff6b35;
            margin-bottom: 10px;
          }
          .content {
            text-align: center;
            margin-bottom: 30px;
          }
          .content p {
            color: #333;
            line-height: 1.6;
            margin: 10px 0;
          }
          .code-box {
            background-color: #f0f0f0;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            border: 2px solid #ff6b35;
          }
          .code {
            font-size: 32px;
            font-weight: bold;
            color: #ff6b35;
            letter-spacing: 2px;
          }
          .expiry {
            color: #666;
            font-size: 12px;
            margin-top: 10px;
          }
          .footer {
            text-align: center;
            color: #999;
            font-size: 12px;
            margin-top: 30px;
            border-top: 1px solid #eee;
            padding-top: 20px;
          }
          .warning {
            background-color: #fff3cd;
            padding: 10px;
            border-radius: 4px;
            color: #856404;
            font-size: 12px;
            margin-top: 20px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <div class="logo">🚗 RideGO</div>
          </div>
          
          <div class="content">
            <p><strong>Your Verification Code</strong></p>
            <p>This code will help verify your identity. Do not share it with anyone.</p>
            
            <div class="code-box">
              <div class="code">${code}</div>
              <div class="expiry">This code expires in 10 minutes</div>
            </div>
            
            <div class="warning">
              ⚠️ If you didn't request this code, please ignore this email and your account will remain secure.
            </div>
          </div>
          
          <div class="footer">
            <p>&copy; 2025 RideGO. All rights reserved.</p>
            <p>This is an automated message, please do not reply to this email.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }
}

export const mailService = new MailService();
