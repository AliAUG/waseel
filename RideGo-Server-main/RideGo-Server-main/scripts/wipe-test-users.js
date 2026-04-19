/**
 * One-off: remove all users + linked settings + verification codes (local dev reset).
 * Run: node scripts/wipe-test-users.js
 */
import 'dotenv/config';
import mongoose from 'mongoose';
import { User, UserSettings, VerificationCode } from '../models/index.js';

async function main() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('MONGODB_URI missing');
    process.exit(1);
  }
  await mongoose.connect(uri);
  const users = await User.find({}, { email: 1, _id: 1, settings: 1 });
  console.log('Users before:', users.map((u) => u.email || u._id.toString()).join(', ') || '(none)');

  const userIds = users.map((u) => u._id);
  const settingsIds = users.map((u) => u.settings).filter(Boolean);

  const r1 = await VerificationCode.deleteMany({});
  const r2 = await UserSettings.deleteMany({ $or: [{ user: { $in: userIds } }, { _id: { $in: settingsIds } }] });
  const r3 = await User.deleteMany({});

  console.log('Deleted verificationcodes:', r1.deletedCount);
  console.log('Deleted usersettings:', r2.deletedCount);
  console.log('Deleted users:', r3.deletedCount);
  await mongoose.disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
