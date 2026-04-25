🟢 1. Admin Dashboard (List Screen)

👉 Screen: Admin Dashboard

Call:

GET /api/admin?page=1&pageSize=10

Optional filters:

GET /api/admin?status=completed&type=ride
🟢 2. Add Service Screen

👉 Before opening form:

Load dropdowns:
GET /api/admin/passengers
GET /api/admin/drivers
Submit form:
POST /api/admin

Body (Figma-based):

{
  "passenger": "USER_ID",
  "driver": "USER_ID",
  "type": "ride",
  "pickupLocation": {
    "address": "Tripoli"
  },
  "dropoffLocation": {
    "address": "Beirut"
  },
  "estimatedFare": 120000,
  "status": "pending"
}
🟢 3. Edit Service Screen

👉 Load data:

GET /api/admin/:id

👉 Update:

PUT /api/admin/:id

Example:

{
  "status": "completed",
  "actualFare": 150000
}
🟢 4. Delete Service Screen

👉 Confirm delete:

DELETE /api/admin/:id
🟢 5. Assign Driver (Optional UI Action)
PATCH /api/admin/:id/assign-driver
{
  "driverId": "USER_ID"
}
🟢 6. Update Status (Dropdown / Button)
PATCH /api/admin/:id/status
{
  "status": "completed"
}
✅ 3. Headers (IMPORTANT)

All requests require:

Authorization: Bearer YOUR_TOKEN
Content-Type: application/json
🔥 4. Response Format (What Frontend Gets)

Example:

{
  "success": true,
  "data": [
    {
      "_id": "123",
      "type": "ride",
      "status": "completed",
      "passenger": {
        "firstName": "Ahmad"
      },
      "driver": {
        "firstName": "Ali"
      }
    }
  ],
  "page": 1,
  "pageSize": 10,
  "total": 25
}