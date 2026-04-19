# Email OTP Configuration Guide

This guide explains how to set up and use email-based OTP (One-Time Password) verification in the RideGO API using Nodemailer.

## Setup Steps

### 1. Install Dependencies

Nodemailer has already been added to `package.json`. Install it by running:

```bash
npm install
```

### 2. Configure Environment Variables

Add the following email configuration variables to your `.env` file:

```env
# Email Configuration (Nodemailer - for OTP via email)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_specific_password
```

### 3. Setting Up Gmail (Recommended for Development)

If using Gmail, follow these steps:

1. **Enable 2-Step Verification**
   - Go to [Google Account Security](https://myaccount.google.com/security)
   - Click on "2-Step Verification"
   - Follow the setup process

2. **Generate App Password**
   - Go to [App Passwords](https://myaccount.google.com/apppasswords)
   - Select "Mail" and "Windows Computer" (or your device)
   - Google will generate a 16-character password
   - Copy this password and use it as `EMAIL_PASSWORD` in your `.env`

3. **Update `.env`**
   ```env
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASSWORD=xxxx xxxx xxxx xxxx
   ```

### 4. Alternative Email Providers

#### Outlook/Hotmail
```env
EMAIL_HOST=smtp.office365.com
EMAIL_PORT=587
EMAIL_USER=your-email@outlook.com
EMAIL_PASSWORD=your_password
```

#### SendGrid
```env
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_USER=apikey
EMAIL_PASSWORD=your_sendgrid_api_key
```

#### AWS SES
```env
EMAIL_HOST=email-smtp.region.amazonaws.com
EMAIL_PORT=587
EMAIL_USER=your_ses_username
EMAIL_PASSWORD=your_ses_password
```

## API Endpoints

### Email-Based OTP Authentication

#### 1. Send OTP by Email
```http
POST /api/auth/send-otp/email
Content-Type: application/json

{
  "email": "user@example.com",
  "type": "login" // or "account_creation", "password_reset"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Verification code sent to your email"
}
```

#### 2. Register with Email
```http
POST /api/auth/register/email
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123",
  "role": "Passenger"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Verification code sent to your email",
  "data": {
    "requiresVerification": true
  }
}
```

#### 3. Verify Email Registration
```http
POST /api/auth/verify-registration/email
Content-Type: application/json

{
  "email": "john@example.com",
  "code": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "_id": "...",
      "fullName": "John Doe",
      "email": "john@example.com",
      "isEmailVerified": true
    },
    "token": "jwt_token_here"
  }
}
```

#### 4. Login with Email OTP
```http
POST /api/auth/login/email/otp
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Verification code sent to your email"
}
```

#### 5. Verify Email Login
```http
POST /api/auth/login/email/otp/verify
Content-Type: application/json

{
  "email": "user@example.com",
  "code": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "jwt_token_here"
  }
}
```

#### 6. Request Password Reset
```http
POST /api/auth/reset-password/email
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset code sent to your email"
}
```

#### 7. Reset Password with OTP
```http
POST /api/auth/reset-password/email/verify
Content-Type: application/json

{
  "email": "user@example.com",
  "code": "123456",
  "newPassword": "newSecurePassword123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "jwt_token_here"
  }
}
```

## Features

### Email Template
- Professional HTML email template with RideGO branding
- Clear OTP code display
- 10-minute expiration timer notification
- Security warning about not sharing the code

### OTP Properties
- **Length:** 6 digits
- **Expiration:** 10 minutes
- **Types Supported:**
  - `login` - Standard login
  - `account_creation` - New account verification
  - `password_reset` - Password reset
  - `email_verification` - Email verification

### Database Schema
The `VerificationCode` model stores OTP records with:
- Email address
- 6-digit code
- Type of verification
- Expiration timestamp
- Usage status
- Auto-deletion after expiration (TTL index)

## Testing

### Using Mock Mode
If email credentials are not configured, the system runs in mock mode:
```
[MOCK EMAIL] To: user@example.com, Subject: Your RideGO Login Code, Code: 123456
```

This is useful for development and testing without actual email sending.

### Testing with Real Email (Gmail)

1. Configure your Gmail credentials as described above
2. Send an OTP request to any endpoint
3. Check your email inbox for the verification code
4. Use the code to complete the authentication flow

## Troubleshooting

### "Failed to send OTP email" Error
1. Check if `EMAIL_USER` and `EMAIL_PASSWORD` are correctly set
2. Verify email provider credentials
3. For Gmail, ensure you're using an App Password, not your regular password
4. Check if 2-Step Verification is enabled for Gmail

### Email Not Received
1. Check spam/junk folder
2. Verify the email address is correct
3. Check email server logs for delivery failures
4. Ensure EMAIL_HOST and EMAIL_PORT are correct for your provider

### Connection Refused
1. Verify `EMAIL_HOST` and `EMAIL_PORT` are correct
2. Check firewall settings - port 587 should be open
3. Ensure `tls.rejectUnauthorized` is set correctly in mail config

## Email Configuration Files

- **Config File:** `config/mail.js` - Nodemailer initialization and email sending
- **Service Class:** `services/AuthService.js` - Authentication logic with email OTP methods
- **Controller:** `controllers/AuthController.js` - API endpoint handlers
- **Routes:** `routes/AuthRoutes.js` - Route definitions

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| EMAIL_HOST | SMTP server hostname | smtp.gmail.com |
| EMAIL_PORT | SMTP server port | 587 |
| EMAIL_USER | Email account username | your-email@gmail.com |
| EMAIL_PASSWORD | Email account password/app password | xxxx xxxx xxxx xxxx |

## Security Notes

1. **Never hardcode credentials** - Always use environment variables
2. **Use App Passwords** - For Gmail, use app-specific passwords instead of your main password
3. **Secure .env file** - Add `.env` to `.gitignore` to prevent accidental commits
4. **HTTPS in Production** - Always use HTTPS in production to protect OTP in transit
5. **Rate Limiting** - Consider implementing rate limiting on OTP endpoints in production

## Next Steps

1. Update your `.env` file with email credentials
2. Test the endpoints using Postman or another API client
3. Integrate email OTP into your frontend application
4. Consider adding SMS fallback for improved accessibility

