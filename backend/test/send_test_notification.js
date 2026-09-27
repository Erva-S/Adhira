/**
 * Helper CLI script to trigger real test notifications to the Adhira application.
 *
 * Usage:
 *   node backend/test/send_test_notification.js [type] [userId]
 *
 * Examples:
 *   node backend/test/send_test_notification.js application TSS-2025-45678
 *   node backend/test/send_test_notification.js payment TSS-2025-45678
 *   node backend/test/send_test_notification.js document TSS-2025-45678
 */

const http = require('http');

const type = process.argv[2] || 'application';
const userId = process.argv[3] || 'TSS-2025-45678';

const payloadByType = {
  application: {
    title: 'Application Status: Under Verification',
    message: 'Your Post-Matric ST Scholarship application (PMS-2025-78432) has moved to District Verification.',
    type: 'application',
    actionRoute: '/applications/tracking',
    relatedId: 'app-pms-2025-001'
  },
  verification: {
    title: 'Verification Completed',
    message: 'Your ST Certificate (SC/OD/2023/12345) has been officially verified by MoTA portal.',
    type: 'verification',
    actionRoute: '/verification',
    relatedId: 'app-pms-2025-001'
  },
  document: {
    title: 'Action Required: Income Certificate',
    message: 'Income certificate is missing financial year 2024-25 seal. Please upload an updated certificate.',
    type: 'document',
    actionRoute: '/documents',
    relatedId: 'doc-income'
  },
  payment: {
    title: 'DBT Payment Disbursed: ₹70,000',
    message: 'Your Post-Matric Scholarship has been disbursed to Aadhaar-seeded bank account ****7890 (UTR: SBIN20250927001).',
    type: 'payment',
    actionRoute: '/payments',
    relatedId: 'pay-001'
  },
  jago: {
    title: 'JAGO Assistant Advisory',
    message: 'New Top Class Education scholarship deadline is approaching on 31st October. Check your eligibility now!',
    type: 'jago',
    actionRoute: '/jago',
    relatedId: 'sch-top-class'
  }
};

const payload = payloadByType[type] || payloadByType.application;
const postData = JSON.stringify({ userId, ...payload });

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/notifications/send',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log(`Sending ${type} notification to user ${userId}...`);

const req = http.request(options, (res) => {
  let responseData = '';
  res.on('data', (chunk) => { responseData += chunk; });
  res.on('end', () => {
    console.log(`Response [${res.statusCode}]:`, responseData);
  });
});

req.on('error', (e) => {
  console.log(`[Offline Notice] Server not running locally on port 3000 (${e.message}). In-app local event engine active.`);
});

req.write(postData);
req.end();
