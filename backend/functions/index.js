/**
 * Firebase Cloud Functions for Adhira Real-Time Push Notifications.
 *
 * Implements real-time database event triggers:
 * 1. onApplicationStatusUpdated: Triggers on application status/stage changes.
 * 2. onDeficiencyCreated: Triggers when an officer flags a missing/defective document.
 * 3. onDbtDisbursed: Triggers when PFMS/DBT releases funds to the student bank account.
 * 4. onNewScholarshipAnnounced: Broadcasts newly opened MoTA schemes to eligible students.
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * 1. Application Status Trigger:
 * Fires whenever an application document in Firestore is modified.
 */
exports.onApplicationStatusUpdated = functions.firestore
  .document('applications/{applicationId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if status or stage actually changed
    if (beforeData.status === afterData.status && beforeData.currentStage === afterData.currentStage) {
      return null;
    }

    const userId = afterData.userId || afterData.studentId;
    if (!userId) return null;

    // Look up active FCM tokens for this user
    const tokensSnapshot = await db.collection('user_tokens').doc(userId).get();
    if (!tokensSnapshot.exists) {
      console.log(`No device tokens found for user: ${userId}`);
      return null;
    }

    const { tokens } = tokensSnapshot.data();
    if (!tokens || tokens.length === 0) return null;

    const schemeName = afterData.scholarshipName || 'MoTA Scholarship';
    const appNumber = afterData.applicationNumber || context.params.applicationId;
    const newStatus = afterData.statusLabel || afterData.status;

    const payload = {
      tokens,
      notification: {
        title: 'Application Status Updated',
        body: `Your application (${appNumber}) for ${schemeName} is now: ${newStatus}.`
      },
      data: {
        id: `notif-${Date.now()}`,
        type: 'application',
        action_route: '/applications/tracking',
        related_id: context.params.applicationId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'adhira_high_importance_channel',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true
        }
      },
      apns: {
        payload: {
          aps: { sound: 'default', badge: 1 }
        }
      }
    };

    // Store notification record in Firestore user notifications subcollection
    await db.collection('users').doc(userId).collection('notifications').add({
      title: payload.notification.title,
      message: payload.notification.body,
      type: 'application',
      actionRoute: '/applications/tracking',
      relatedId: context.params.applicationId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false
    });

    // Send FCM push
    return admin.messaging().sendEachForMulticast(payload);
  });

/**
 * 2. Document Deficiency Trigger:
 * Fires when an officer records a document deficiency or action item.
 */
exports.onDeficiencyCreated = functions.firestore
  .document('deficiencies/{deficiencyId}')
  .onCreate(async (snap, context) => {
    const deficiency = snap.data();
    const userId = deficiency.userId;
    if (!userId) return null;

    const tokensSnapshot = await db.collection('user_tokens').doc(userId).get();
    if (!tokensSnapshot.exists) return null;

    const { tokens } = tokensSnapshot.data();
    if (!tokens || tokens.length === 0) return null;

    const docName = deficiency.documentName || 'Required Document';
    const reason = deficiency.reason || 'Verification incomplete';

    const payload = {
      tokens,
      notification: {
        title: 'Action Required: Document Missing/Rejected',
        body: `Please re-upload your ${docName}. Reason: ${reason}`
      },
      data: {
        id: `notif-${Date.now()}`,
        type: 'document',
        action_route: '/documents',
        related_id: deficiency.applicationId || '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'adhira_high_importance_channel',
          priority: 'high',
          defaultSound: true
        }
      }
    };

    await db.collection('users').doc(userId).collection('notifications').add({
      title: payload.notification.title,
      message: payload.notification.body,
      type: 'document',
      actionRoute: '/documents',
      relatedId: deficiency.applicationId || '',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false
    });

    return admin.messaging().sendEachForMulticast(payload);
  });

/**
 * 3. DBT Payment Disbursed Trigger:
 * Fires when a payment disbursement is recorded.
 */
exports.onDbtDisbursed = functions.firestore
  .document('payments/{paymentId}')
  .onCreate(async (snap, context) => {
    const payment = snap.data();
    const userId = payment.userId;
    if (!userId) return null;

    const tokensSnapshot = await db.collection('user_tokens').doc(userId).get();
    if (!tokensSnapshot.exists) return null;

    const { tokens } = tokensSnapshot.data();
    if (!tokens || tokens.length === 0) return null;

    const amount = payment.amount ? `₹${Number(payment.amount).toLocaleString('en-IN')}` : 'Scholarship Amount';
    const utr = payment.utrNumber || 'N/A';

    const payload = {
      tokens,
      notification: {
        title: 'DBT Scholarship Disbursed',
        body: `Disbursement of ${amount} has been credited to your Aadhaar-linked bank account (UTR: ${utr}).`
      },
      data: {
        id: `notif-${Date.now()}`,
        type: 'payment',
        action_route: '/payments',
        related_id: context.params.paymentId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'adhira_high_importance_channel',
          priority: 'high',
          defaultSound: true
        }
      }
    };

    await db.collection('users').doc(userId).collection('notifications').add({
      title: payload.notification.title,
      message: payload.notification.body,
      type: 'payment',
      actionRoute: '/payments',
      relatedId: context.params.paymentId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false
    });

    return admin.messaging().sendEachForMulticast(payload);
  });
