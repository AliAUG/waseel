# RideGO - Complete API Flow Documentation

> **📧 Updated:** All authentication now uses email-based OTP instead of SMS/phone-based OTP. Users can register and authenticate using a secure email-verified account.

---

## 📋 Table of Contents
1. [Authentication Flow](#authentication-flow)
2. [Passenger Ride Flow](#passenger-ride-flow)
3. [Passenger Delivery Flow](#passenger-delivery-flow)
4. [Driver Flow](#driver-flow)
5. [User Profile & Settings](#user-profile--settings)
6. [Wallet & Payment](#wallet--payment)
7. [Notifications](#notifications)

---

## 🔐 Authentication Flow

### Diagram
```
On-Boarding → Choose Role → Create Account → Email OTP → Verify → Login
```

### Step 1: Register User with Email
**Endpoint:** `POST /auth/register/email`
**Authentication:** None
**Request Body:**
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "Driver" // or "Passenger"
}
```
**Response (201):**
```json
{
  "message": "Verification code sent to your email",
  "expiresAt": "2024-03-05T10:45:00Z"
}
```

### Step 2: Verify Registration OTP
**Endpoint:** `POST /auth/verify-registration/email`
**Authentication:** None
**Request Body:**
```json
{
  "email": "john@example.com",
  "code": "123456"
}
```
**Response (200):**
```json
{
  "user": {
    "_id": "user123",
    "fullName": "John Doe",
    "email": "john@example.com",
    "role": "Driver",
    "isEmailVerified": true
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Alternative: Login with Email & Password
**Endpoint:** `POST /auth/login/email`
**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```
**Response (200):**
```json
{
  "user": { ... },
  "token": "..."
}
```

### Alternative: Login with Email OTP
**Step 1:** Request OTP
**Endpoint:** `POST /auth/login/email/otp`
```json
{
  "email": "john@example.com"
}
```
**Response:** OTP sent to email

**Step 2:** Verify OTP
**Endpoint:** `POST /auth/login/email/otp/verify`
```json
{
  "email": "john@example.com",
  "code": "123456"
}
```
**Response:** User object + JWT token

### Password Reset Flow
**Step 1:** Request Password Reset Code
**Endpoint:** `POST /auth/reset-password/email`
```json
{
  "email": "john@example.com"
}
```
**Response:** Password reset code sent to email

**Step 2:** Reset Password with Code
**Endpoint:** `POST /auth/reset-password/email/verify`
```json
{
  "email": "john@example.com",
  "code": "123456",
  "newPassword": "newPassword123"
}
```
**Response:** User object + JWT token

### Get User Profile
**Endpoint:** `GET /auth/profile`
**Authentication:** ✅ Required (JWT Token)
**Response (200):**
```json
{
  "_id": "user123",
  "fullName": "John Doe",
  "email": "john@example.com",
  "role": "Driver",
  "rating": 4.9,
  "tripsCount": 125,
  "isEmailVerified": true,
  "profilePicture": "..."
}
```

---

## 🚗 Passenger Ride Flow

### Diagram
```
Home Page → Select Ride Type → Enter Location → Search → Driver Info → Start Trip → Complete Trip → Rating
```

### Step 1: Get Available Ride Types
**Endpoint:** `GET /trips/ride-types`
**Authentication:** None
**Response (200):**
```json
[
  {
    "_id": "type1",
    "name": "Economy",
    "basePrice": 30000,
    "timeEstimateMinutes": 3,
    "currency": "LBP"
  },
  {
    "_id": "type2",
    "name": "Comfort",
    "basePrice": 60000,
    "timeEstimateMinutes": 5
  },
  {
    "_id": "type3",
    "name": "Luxury",
    "basePrice": 80000,
    "timeEstimateMinutes": 8
  }
]
```

### Step 2: Create Ride Request
**Endpoint:** `POST /trips`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "pickupLocation": {
    "address": "123 Main St",
    "latitude": 33.8547,
    "longitude": 35.8623,
    "details": "Near the blue car"
  },
  "dropoffLocation": {
    "address": "Downtown Dubai",
    "latitude": 25.2048,
    "longitude": 55.2708,
    "details": "Business Tower"
  },
  "rideTypeId": "type1",
  "estimatedFare": 35000,
  "paymentMethod": "cash" // or "wallet", "card"
}
```
**Response (201):**
```json
{
  "_id": "trip123",
  "passenger": "user123",
  "status": "searching_driver",
  "rideType": {
    "name": "Economy",
    "basePrice": 30000
  },
  "estimatedFare": 35000,
  "pickupLocation": { ... },
  "dropoffLocation": { ... },
  "createdAt": "2024-03-05T10:00:00Z"
}
```

### Step 3: View Driver Info (Real-time Update)
**Endpoint:** `GET /trips/:id`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "_id": "trip123",
  "status": "driver_en_route",
  "driver": {
    "_id": "driver456",
    "fullName": "Ahmed Al-Mansoori",
    "rating": 4.9,
    "phoneNumber": "+961234567",
    "profilePicture": "https://example.com/picture.jpg"
  },
  "vehicle": {
    "makeModel": "Toyota Camry",
    "color": "White",
    "plateNumber": "ABC-123",
    "region": "Lebanon - Tripoli"
  },
  "rideType": { "name": "Economy" },
  "estimatedArrivalMinutes": 3,
  "pickupLocation": { "latitude": 33.8547, "longitude": 35.8623 },
  "dropoffLocation": { "latitude": 25.2048, "longitude": 55.2708 },
  "startedAt": null,
  "completedAt": null
}
```

### Step 4: Start Trip (Driver Arrives)
**Status Updates (Automatic via WebSocket or Polling)**
- `status`: `driver_arrived` → Driver has arrives at pickup
- Open Map & Show Driver Location

### Step 5: Trip in Progress
**Status:** `en_route`
- Show countdown timer
- Show estimated arrival at destination
- Allow Call/Chat with driver

### Step 6: Complete Trip
**Endpoint:** `PUT /drivers/trips/:id/status` (Driver marks complete)
**Authentication:** ✅ Required (Driver only)
**Request Body:**
```json
{
  "status": "completed"
}
```
**Status:** `completed`
- Show final fare breakdown

### Step 7: Rate Trip
**Endpoint:** `POST /trips/:id/rate`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "stars": 5,
  "comment": "Great driver, smooth ride!",
  "feedbackTags": ["clean_car", "safe_driving", "polite"]
}
```
**Response (200):**
```json
{
  "_id": "rating123",
  "user": "user123",
  "driver": "driver456",
  "trip": "trip123",
  "stars": 5,
  "comment": "Great driver, smooth ride!",
  "createdAt": "2024-03-05T10:30:00Z"
}
```

### Get Trip History
**Endpoint:** `GET /trips?page=1&limit=20`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "trips": [
    {
      "_id": "trip123",
      "status": "completed",
      "driver": { "fullName": "Ahmed", "rating": 4.9 },
      "rideType": { "name": "Economy" },
      "estimatedFare": 35000,
      "actualFare": 36500,
      "createdAt": "2024-03-05T10:00:00Z"
    }
  ],
  "total": 45,
  "page": 1,
  "totalPages": 3
}
```

### Get Trip Details
**Endpoint:** `GET /trips/:id/details`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "_id": "trip123",
  "driver": {
    "_id": "driver456",
    "fullName": "Ahmed Al-Mansoori",
    "rating": 4.9,
    "profilePicture": "https://example.com/picture.jpg"
  },
  "vehicle": {
    "makeModel": "Toyota Camry",
    "color": "White",
    "plateNumber": "ABC-123",
    "region": "Lebanon - Tripoli"
  },
  "rideType": { "name": "Economy" },
  "pickupLocation": {
    "address": "123 Main St",
    "latitude": 33.8547,
    "longitude": 35.8623
  },
  "dropoffLocation": {
    "address": "Downtown Dubai",
    "latitude": 25.2048,
    "longitude": 55.2708
  },
  "estimatedFare": 35000,
  "actualFare": 36500,
  "fareBreakdown": {
    "baseFare": 30000,
    "distanceCost": 5000,
    "distanceKm": 8.5,
    "timeCost": 1500,
    "timeMinutes": 12,
    "total": 36500,
    "currency": "LBP"
  },
  "status": "completed",
  "startedAt": "2024-03-05T10:05:00Z",
  "completedAt": "2024-03-05T10:30:00Z"
}
```

---

## 📦 Passenger Delivery Flow

### Diagram
```
Home (Delivery Tab) → Request Delivery → Search for Delivery → Waiting → Start Trip → Complete → Rating
```

### Step 1: Request Delivery
**Endpoint:** `POST /deliveries`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "pickupLocation": {
    "address": "Sender Location",
    "latitude": 33.8547,
    "longitude": 35.8623
  },
  "dropoffLocation": {
    "address": "Recipient Location",
    "latitude": 33.8650,
    "longitude": 35.8700
  },
  "packageDetails": "Electronics package",
  "estimatedDeliveryTimeMinutes": 25,
  "deliveryFee": 25000,
  "currency": "LBP"
}
```
**Response (201):**
```json
{
  "_id": "delivery123",
  "customer": "user123",
  "status": "searching",
  "deliveryFee": 25000,
  "pickupLocation": { ... },
  "dropoffLocation": { ... }
}
```

### Step 2: View Driver
**Endpoint:** `GET /deliveries/:id`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "_id": "delivery123",
  "customer": "user123",
  "status": "driver_en_route",
  "driver": {
    "fullName": "Ahmed Al-Mansoori",
    "rating": 4.7,
    "phoneNumber": "+961234567"
  },
  "vehicle": {
    "makeModel": "Toyota Camry",
    "color": "White"
  },
  "estimatedArrivalMinutes": 3,
  "packageDetails": "Electronics package"
}
```

### Step 3: Complete Delivery & Rate
**Endpoint:** `POST /deliveries/:id/rate`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "stars": 4,
  "comment": "Fast and safe delivery",
  "feedbackTags": ["on_time", "careful_handling"]
}
```

### Get Delivery History
**Endpoint:** `GET /deliveries?page=1&limit=20`
**Authentication:** ✅ Required

---

## 🏎️ Driver Flow

### Diagram
```
Driver Home → Online Status → Receive Ride Requests → Accept → En Route → Arrive → Complete → Earnings
```

### Step 1: Get Driver Dashboard
**Endpoint:** `GET /drivers/dashboard`
**Authentication:** ✅ Required (Driver only)
**Response (200):**
```json
{
  "profile": {
    "fullName": "Ahmed Al-Mansoori",
    "rating": 4.9,
    "tripsCompleted": 156,
    "totalEarnings": 5200000
  },
  "todayStats": {
    "tripsCount": 12,
    "earningsToday": 450000,
    "acceptanceRate": 95
  },
  "vehicle": {
    "makeModel": "Toyota Camry",
    "color": "White",
    "plateNumber": "ABC-123"
  },
  "onlineStatus": true
}
```

### Step 2: Get Available Ride Requests
**Endpoint:** `GET /drivers/ride-requests`
**Authentication:** ✅ Required (Driver only)
**Response (200):**
```json
[
  {
    "_id": "trip123",
    "passenger": {
      "fullName": "Saad Ahmed",
      "rating": 4.8,
      "profilePicture": "..."
    },
    "pickupLocation": {
      "address": "123 Main St",
      "latitude": 33.8547,
      "longitude": 35.8623
    },
    "dropoffLocation": {
      "address": "Downtown",
      "latitude": 25.2048,
      "longitude": 55.2708
    },
    "rideType": { "name": "Economy" },
    "estimatedFare": 35000,
    "estimatedDuration": "12 minutes"
  }
]
```

### Step 3: Accept Ride Request
**Endpoint:** `POST /drivers/ride-requests/:id/accept`
**Authentication:** ✅ Required (Driver only)
**Response (200):**
```json
{
  "_id": "trip123",
  "status": "driver_assigned",
  "driver": "driver456",
  "estimatedArrivalMinutes": 5,
  "message": "Ride accepted"
}
```

### Step 4: Update Trip Status - On the Way
**Endpoint:** `PUT /drivers/trips/:id/status`
**Authentication:** ✅ Required (Driver only)
**Request Body:**
```json
{
  "status": "driver_en_route"
}
```
**Response (200):**
```json
{
  "_id": "trip123",
  "status": "driver_en_route",
  "message": "Driver is on the way"
}
```

### Step 5: Update Trip Status - Arrived
**Request Body:**
```json
{
  "status": "driver_arrived"
}
```
**Response (200):**
```json
{
  "_id": "trip123",
  "status": "driver_arrived",
  "message": "Driver has arrived"
}
```

### Step 6: Update Trip Status - Trip Started
**Request Body:**
```json
{
  "status": "en_route"
}
```
**Response (200):**
```json
{
  "_id": "trip123",
  "status": "en_route",
  "startedAt": "2024-03-05T10:05:00Z"
}
```

### Step 7: Complete Trip
**Request Body:**
```json
{
  "status": "completed"
}
```
**Response (200):**
```json
{
  "_id": "trip123",
  "status": "completed",
  "actualFare": 36500,
  "earnedAmount": 32850,
  "completedAt": "2024-03-05T10:30:00Z"
}
```

### Decline Ride Request
**Endpoint:** `POST /drivers/ride-requests/:id/decline`
**Authentication:** ✅ Required (Driver only)
**Response (200):**
```json
{
  "declined": true,
  "message": "Ride request declined"
}
```

### Get Driver Trip History
**Endpoint:** `GET /drivers/trips?page=1&limit=20`
**Authentication:** ✅ Required (Driver only)
**Response (200):**
```json
{
  "trips": [
    {
      "_id": "trip123",
      "passenger": { "fullName": "Saad Ahmed", "rating": 4.8 },
      "estimatedFare": 35000,
      "actualFare": 36500,
      "earnedAmount": 32850,
      "status": "completed",
      "createdAt": "2024-03-05T10:00:00Z"
    }
  ],
  "total": 156,
  "page": 1,
  "totalPages": 8
}
```

### Get Driver Trip Details
**Endpoint:** `GET /drivers/trips/:id`
**Authentication:** ✅ Required (Driver only)
**Response (200):**
```json
{
  "_id": "trip123",
  "passenger": {
    "_id": "user456",
    "fullName": "Saad Ahmed",
    "rating": 4.8,
    "phoneNumber": "+961234567",
    "profilePicture": "https://example.com/picture.jpg"
  },
  "rideType": { "name": "Economy" },
  "vehicle": {
    "makeModel": "Toyota Camry",
    "color": "White",
    "plateNumber": "ABC-123",
    "region": "Lebanon - Tripoli"
  },
  "pickupLocation": { ... },
  "dropoffLocation": { ... },
  "estimatedFare": 35000,
  "actualFare": 36500,
  "status": "completed",
  "startedAt": "2024-03-05T10:05:00Z",
  "completedAt": "2024-03-05T10:30:00Z"
}
```

---

## 👤 User Profile & Settings

### Step 1: Update Profile
**Endpoint:** `PUT /users/profile`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "profilePicture": "https://...",
  "phoneNumber": "+961234567"
}
```
**Response (200):**
```json
{
  "_id": "user123",
  "fullName": "John Doe",
  "email": "john@example.com",
  "profilePicture": "..."
}
```

### Step 2: Get Settings
**Endpoint:** `GET /users/settings`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "language": "en",
  "notifications": {
    "rideRequests": true,
    "messages": true,
    "promotions": false
  },
  "privacy": {
    "shareLocation": true,
    "showProfile": true
  }
}
```

### Step 3: Update Settings
**Endpoint:** `PUT /users/settings`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "language": "ar",
  "notifications": {
    "rideRequests": true,
    "messages": true,
    "promotions": false
  },
  "privacy": {
    "shareLocation": true,
    "showProfile": true
  }
}
```

### Get Saved Places
**Endpoint:** `GET /users/saved-places`
**Authentication:** ✅ Required
**Response (200):**
```json
[
  {
    "_id": "place1",
    "label": "Home",
    "address": "123 Main St",
    "latitude": 33.8547,
    "longitude": 35.8623
  },
  {
    "_id": "place2",
    "label": "Work",
    "address": "Business Tower",
    "latitude": 33.8650,
    "longitude": 35.8700
  }
]
```

### Add Saved Place
**Endpoint:** `POST /users/saved-places`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "label": "Gym",
  "address": "Fitness Center",
  "latitude": 33.8500,
  "longitude": 35.8600
}
```
**Response (201):**
```json
{
  "_id": "place3",
  "label": "Gym",
  "address": "Fitness Center",
  "latitude": 33.8500,
  "longitude": 35.8600
}
```

### Update Saved Place
**Endpoint:** `PUT /users/saved-places/:id`
**Authentication:** ✅ Required
**Request Body:** (same as above)

### Delete Saved Place
**Endpoint:** `DELETE /users/saved-places/:id`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "deleted": true
}
```

---

## 💰 Wallet & Payment

### Step 1: Get Wallet
**Endpoint:** `GET /wallets`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "_id": "wallet123",
  "user": "user123",
  "balance": 425000,
  "currency": "LBP",
  "lastUpdated": "2024-03-05T10:00:00Z"
}
```

### Step 2: Add Balance
**Endpoint:** `POST /wallets/add-balance`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "amount": 425000,
  "paymentMethod": "Mastercard" // or "Visa", "Apple Pay"
}
```
**Response (200):**
```json
{
  "wallet": {
    "_id": "wallet123",
    "balance": 850000
  },
  "transaction": {
    "_id": "trans123",
    "type": "top_up",
    "amount": 425000,
    "status": "completed",
    "createdAt": "2024-03-05T10:05:00Z"
  },
  "message": "Balance added"
}
```

### Step 3: Get Transactions
**Endpoint:** `GET /wallets/transactions?page=1&limit=20`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "transactions": [
    {
      "_id": "trans1",
      "type": "ride_payment",
      "amount": 36500,
      "description": "Ride to Downtown",
      "status": "completed",
      "createdAt": "2024-03-05T10:30:00Z"
    },
    {
      "_id": "trans2",
      "type": "top_up",
      "amount": 425000,
      "paymentMethod": "Mastercard",
      "status": "completed",
      "createdAt": "2024-03-05T09:00:00Z"
    }
  ],
  "total": 45,
  "page": 1,
  "totalPages": 3
}
```

### Get Payment Methods
**Endpoint:** `GET /wallets/payment-methods`
**Authentication:** ✅ Required
**Response (200):**
```json
[
  {
    "_id": "method1",
    "type": "card",
    "cardType": "Mastercard",
    "last4": "1234",
    "isDefault": true
  },
  {
    "_id": "method2",
    "type": "card",
    "cardType": "Visa",
    "last4": "5678",
    "isDefault": false
  }
]
```

### Add Payment Method
**Endpoint:** `POST /wallets/payment-methods`
**Authentication:** ✅ Required
**Request Body:**
```json
{
  "cardType": "Visa",
  "cardNumber": "4532123456789010",
  "expiryMonth": 12,
  "expiryYear": 2026,
  "cvv": "123"
}
```
**Response (201):**
```json
{
  "_id": "method3",
  "type": "card",
  "cardType": "Visa",
  "last4": "9010",
  "isDefault": false
}
```

### Set Default Payment Method
**Endpoint:** `PUT /wallets/payment-methods/:id/default`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "_id": "method3",
  "isDefault": true
}
```

---

## 🔔 Notifications

### Get Notifications
**Endpoint:** `GET /notifications?page=1&limit=20`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "notifications": [
    {
      "_id": "notif1",
      "type": "new_ride_request",
      "title": "New Ride Request",
      "message": "Saad Ahmed requested a ride",
      "isRead": false,
      "data": {
        "rideId": "trip123",
        "passengerId": "user456"
      },
      "createdAt": "2024-03-05T10:20:00Z"
    },
    {
      "_id": "notif2",
      "type": "document_approved",
      "title": "Document Approved",
      "message": "Your license has been verified",
      "isRead": true,
      "createdAt": "2024-03-04T15:00:00Z"
    }
  ],
  "total": 25,
  "page": 1,
  "totalPages": 2
}
```

### Mark as Read
**Endpoint:** `PUT /notifications/:id/read`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "_id": "notif1",
  "isRead": true
}
```

### Mark All as Read
**Endpoint:** `PUT /notifications/mark-all-read`
**Authentication:** ✅ Required
**Response (200):**
```json
{
  "updated": 5,
  "message": "All notifications marked as read"
}
```

---

## 🚗 Driver Documents & Verification

### Get Documents
**Endpoint:** `GET /drivers/documents`
**Authentication:** ✅ Required (Driver only)
**Response (200):**
```json
[
  {
    "_id": "doc1",
    "type": "license",
    "documentName": "Driver License",
    "files": ["url1", "url2"],
    "approvalStatus": "Approved",
    "approvedAt": "2024-01-15T10:00:00Z"
  },
  {
    "_id": "doc2",
    "type": "vehicle_registration",
    "documentName": "Vehicle Registration",
    "files": ["url3"],
    "approvalStatus": "Pending",
    "submittedAt": "2024-03-01T10:00:00Z"
  }
]
```

### Upload Document
**Endpoint:** `POST /drivers/documents`
**Authentication:** ✅ Required (Driver only)
**Request Body:**
```json
{
  "documentType": "insurance",
  "documentFiles": ["base64_file_1", "base64_file_2"],
  "approvalStatus": "Pending"
}
```
**Response (201):**
```json
{
  "_id": "doc3",
  "type": "insurance",
  "documentName": "Insurance Certificate",
  "files": ["url4", "url5"],
  "approvalStatus": "Pending"
}
```

---

## 💸 Driver Earnings & Payout

### Get Driver Wallet
**Endpoint:** `GET /drivers/wallet`
**Authentication:** ✅ Required (Driver only)
**Response (200):**
```json
{
  "_id": "wallet456",
  "driver": "driver456",
  "totalEarnings": 5200000,
  "availableBalance": 1200000,
  "pendingBalance": 4000000,
  "currency": "LBP"
}
```

### Get Driver Transactions
**Endpoint:** `GET /drivers/transactions?page=1&limit=20&type=ride_payment`
**Authentication:** ✅ Required (Driver only)
**Query Parameters:**
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20)
- `type` - Filter by type (optional): `ride_payment`, `withdrawal`, `adjustment`, etc.
**Response (200):**
```json
[
  {
    "_id": "trans123",
    "trip": "trip123",
    "type": "ride_payment",
    "fareAmount": 36500,
    "platformFee": 3650,
    "tax": 365,
    "earnedAmount": 32485,
    "status": "completed",
    "completedAt": "2024-03-05T10:30:00Z"
  },
  {
    "_id": "trans124",
    "type": "withdrawal",
    "amount": 50000,
    "status": "processing",
    "createdAt": "2024-03-05T15:00:00Z"
  }
]
```

### Request Payout
**Endpoint:** `POST /drivers/payout`
**Authentication:** ✅ Required (Driver only)
**Request Body:**
```json
{
  "amount": 1200000,
  "bankAccount": {
    "accountName": "Ahmed Al-Mansoori",
    "accountNumber": "123456789",
    "bankName": "Bank of Lebanon",
    "iban": "LB123456789"
  }
}
```
**Response (200):**
```json
{
  "_id": "payout1",
  "driver": "driver456",
  "amount": 1200000,
  "status": "Requested",
  "bankAccount": { ... },
  "requestedAt": "2024-03-05T10:45:00Z",
  "expectedCompletionDate": "2024-03-07T00:00:00Z"
}
```

---

## 📊 Summary Table

| Feature | Endpoint | Method | Auth | Status |
|---------|----------|--------|------|--------|
| **Authentication** | | | | |
| Register with Email | `/auth/register/email` | POST | ❌ | ✅ |
| Verify Email Registration | `/auth/verify-registration/email` | POST | ❌ | ✅ |
| Send Email OTP | `/auth/send-otp/email` | POST | ❌ | ✅ |
| Login with Email OTP | `/auth/login/email/otp` | POST | ❌ | ✅ |
| Verify Email OTP Login | `/auth/login/email/otp/verify` | POST | ❌ | ✅ |
| Login with Email & Password | `/auth/login/email` | POST | ❌ | ✅ |
| Reset Password | `/auth/reset-password/email` | POST | ❌ | ✅ |
| Verify Password Reset | `/auth/reset-password/email/verify` | POST | ❌ | ✅ |
| Get Profile | `/auth/profile` | GET | ✅ | ✅ |
| **Passenger Rides** | | | | |
| Get Ride Types | `/trips/ride-types` | GET | ❌ | ✅ |
| Create Trip | `/trips` | POST | ✅ | ✅ |
| Get Trip | `/trips/:id` | GET | ✅ | ✅ |
| Get Trip History | `/trips` | GET | ✅ | ✅ |
| Get Trip Details | `/trips/:id/details` | GET | ✅ | ✅ |
| Rate Trip | `/trips/:id/rate` | POST | ✅ | ✅ |
| **Passenger Deliveries** | | | | |
| Create Delivery | `/deliveries` | POST | ✅ | ✅ |
| Get Delivery | `/deliveries/:id` | GET | ✅ | ✅ |
| Get Delivery History | `/deliveries` | GET | ✅ | ✅ |
| Rate Delivery | `/deliveries/:id/rate` | POST | ✅ | ✅ |
| **Driver Operations** | | | | |
| Get Dashboard | `/drivers/dashboard` | GET | ✅ | ✅ |
| Get Ride Requests | `/drivers/ride-requests` | GET | ✅ | ✅ |
| Accept Ride | `/drivers/ride-requests/:id/accept` | POST | ✅ | ✅ |
| Decline Ride | `/drivers/ride-requests/:id/decline` | POST | ✅ | ✅ |
| Update Trip Status | `/drivers/trips/:id/status` | PUT | ✅ | ✅ |
| Get Trip History | `/drivers/trips` | GET | ✅ | ✅ |
| Get Trip | `/drivers/trips/:id` | GET | ✅ | ✅ |
| Upload Document | `/drivers/documents` | POST | ✅ | ✅ |
| Get Documents | `/drivers/documents` | GET | ✅ | ✅ |
| Get Wallet | `/drivers/wallet` | GET | ✅ | ✅ |
| Get Transactions | `/drivers/transactions` | GET | ✅ | ✅ |
| Request Payout | `/drivers/payout` | POST | ✅ | ✅ |
| **User Settings** | | | | |
| Update Profile | `/users/profile` | PUT | ✅ | ✅ |
| Get Settings | `/users/settings` | GET | ✅ | ✅ |
| Update Settings | `/users/settings` | PUT | ✅ | ✅ |
| Get Saved Places | `/users/saved-places` | GET | ✅ | ✅ |
| Add Saved Place | `/users/saved-places` | POST | ✅ | ✅ |
| Update Saved Place | `/users/saved-places/:id` | PUT | ✅ | ✅ |
| Delete Saved Place | `/users/saved-places/:id` | DELETE | ✅ | ✅ |
| **Wallet & Payments** | | | | |
| Get Wallet | `/wallets` | GET | ✅ | ✅ |
| Add Balance | `/wallets/add-balance` | POST | ✅ | ✅ |
| Get Transactions | `/wallets/transactions` | GET | ✅ | ✅ |
| Get Payment Methods | `/wallets/payment-methods` | GET | ✅ | ✅ |
| Add Payment Method | `/wallets/payment-methods` | POST | ✅ | ✅ |
| Set Default Method | `/wallets/payment-methods/:id/default` | PUT | ✅ | ✅ |
| **Notifications** | | | | |
| Get Notifications | `/notifications` | GET | ✅ | ✅ |
| Mark as Read | `/notifications/:id/read` | PUT | ✅ | ✅ |
| Mark All Read | `/notifications/mark-all-read` | PUT | ✅ | ✅ |

---

## 🔑 Authentication Header
All endpoints marked with ✅ require:
```
Authorization: Bearer <JWT_TOKEN>
```

---

## 📍 Base URL
```
http://localhost:3000/api/v1
```

---

## 🎯 Complete User Journeys

### 📱 Passenger Journey
1. **On-Board & Register** → Auth endpoints
2. **Book a Ride** → GET `/trips/ride-types` → POST `/trips`
3. **Wait for Driver** → GET `/trips/:id` (polling)
4. **During Ride** → Monitor status updates
5. **Complete & Rate** → GET `/trips/:id/details` → POST `/trips/:id/rate`
6. **View History** → GET `/trips`

### 🚗 Driver Journey
1. **Register as Driver** → POST `/auth/register/email` with `role: "Driver"`
2. **Go Online** → Implied status in GET `/drivers/dashboard`
3. **Receive Requests** → GET `/drivers/ride-requests` (polling/WebSocket)
4. **Accept Ride** → POST `/drivers/ride-requests/:id/accept`
5. **Update Status** → PUT `/drivers/trips/:id/status`
6. **Complete Trip** → PUT `/drivers/trips/:id/status` (status: "completed")
7. **View Earnings** → GET `/drivers/wallet` → GET `/drivers/transactions`
8. **Request Payout** → POST `/drivers/payout`

### 💰 Wallet Journey
1. **Check Balance** → GET `/wallets`
2. **Add Payment Method** → POST `/wallets/payment-methods`
3. **Top Up Balance** → POST `/wallets/add-balance`
4. **View Transactions** → GET `/wallets/transactions`
5. **Pay via Wallet** → POST `/trips` with `paymentMethod: "wallet"`

---

---

## ✨ Recently Added Fields (Mar 5, 2026)

Based on Figma design review, the following fields have been added to API responses:

### Driver Information
- ✅ **profilePicture** - Driver's profile photo URL (in all driver response objects)
- ✅ **Vehicle Details** - Complete vehicle info including `plateNumber` now included in trip responses

### Transaction Filtering
- ✅ **type** query parameter - Filter driver transactions by type (ride_payment, withdrawal, etc.)

### Response Consistency
- All driver-related endpoints now include complete vehicle details
- All trip endpoints now return driver's profile picture
- Vehicle plate number visible on trip details for passenger/driver

---
All endpoints return standard error responses:
```json
{
  "success": false,
  "error": "Error message",
  "statusCode": 400
}
```

Common Status Codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `404`: Not Found
- `500`: Server Error
