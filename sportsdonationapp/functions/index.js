const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Cloud Firestore triggers ref: https://firebase.google.com/docs/functions/firestore-events
exports.myFunction = functions.firestore
  .document("chat/{messageId}")
  .onCreate((snapshot, context) => {
    // Return this function's promise, so this ensures the firebase function
    // will keep running, until the notification is scheduled.
    return admin.messaging().sendToTopic("chat", {
      // Sending a notification message.
      notification: {
        title: snapshot.data()["username"],
        body: snapshot.data()["text"],
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    });
  });

exports.sendNotification = functions.firestore.document('items/{documentId}')
    .onUpdate((change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();

        // Check if approval status changed
        if (newValue.approved !== previousValue.approved) {
            const donatorID = newValue.donatorID;
            const message = newValue.approved ? 'Your donation request for ' + newValue.itemName + ' has been approved.' : 'Your donation request for ' + newValue.itemName + ' has been rejected.';

            // Retrieve FCM token and user details from Firestore
            return admin.firestore().collection('users').doc(donatorID).get()
                .then(userDoc => {
                    if (userDoc.exists && userDoc.data().fcmToken) {
                        const fcmToken = userDoc.data().fcmToken;

                        // Send notification
                        const payload = {
                            notification: {
                                title: 'Item donation Status',
                                body: message
                            }
                        };

                        // Save notification details in Firestore
                        const notificationData = {
                            title: 'Item donation Status',
                            body: message,
                            timestamp: admin.firestore.FieldValue.serverTimestamp(),
                            userId: donatorID // Store the donatorID as userId
                        };

                        return admin.messaging().sendToDevice(fcmToken, payload)
                            .then(() => {
                                console.log('Notification sent successfully');
                                // Store notification in Firestore
                                return admin.firestore().collection('notifications').add(notificationData);
                            })
                            .catch(error => {
                                console.error('Error sending notification:', error);
                                return null;
                            });
                    } else {
                        console.log('Donator token not found in database or fcmToken is missing');
                        return null;
                    }
                })
                .catch(error => {
                    console.error('Error retrieving FCM token:', error);
                    return null;
                });
        } else {
            return null;
        }
    });



exports.item_requestsNotification = functions.firestore.document('item_requests/{documentId}')
    .onUpdate((change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();

        // Check if approval status changed
        if (newValue.approved !== previousValue.approved) {
            const requestorID = newValue.requestorID;
            const message = newValue.approved ? 'Your item request' + newValue.itemName + 'has been approved.' : 'Your item request' + newValue.itemName + 'has been rejected.';

            // Retrieve FCM token from Firestore
            return admin.firestore().collection('users').doc(requestorID).get()
                .then(doc => {
                    if (doc.exists && doc.data().fcmToken) {
                        const fcmToken = doc.data().fcmToken;

                        // Send notification
                        const payload = {
                            notification: {
                                title: 'Item request Status',
                                body: message
                            }
                        };
                         const notificationData = {
                                                     title: 'Item request Status',
                                                     body: message,
                                                     timestamp: admin.firestore.FieldValue.serverTimestamp(),
                                                     userId: requestorID
                                                 };
                        return admin.messaging().sendToDevice(fcmToken, payload)
                            .then(() => {
                                console.log('Notification sent successfully');
                                return admin.firestore().collection('notifications').add(notificationData);
                                return null; // No need to return anything from the Cloud Function
                            })
                            .catch(error => {
                                console.error('Error sending notification:', error);
                                return null; // Return null to indicate that the Cloud Function completed successfully despite the error
                            });
                    } else {
                        console.log('Donator token not found in database or fcmToken is missing');
                        return null; // No need to return anything from the Cloud Function
                    }
                })
                .catch(error => {
                    console.error('Error retrieving FCM token:', error);
                    return null; // Return null to indicate that the Cloud Function completed successfully despite the error
                });
        } else {
            return null; // No need to send notification if approval status didn't change
        }
    });



