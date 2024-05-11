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

 exports.sendNotification = functions.firestore.document('item_requests/{documentId}')
     .onUpdate((change, context) => {
         const newValue = change.after.data();
         const previousValue = change.before.data();

         // Check if completed status changed
         if (newValue.completed !== previousValue.completed) {
             const donatorID = newValue.donatorID;
             const requestorID = newValue.requestorID;
             const messageDonator = newValue.completed ? 'Your donated item for ' + newValue.itemName + ' has been successfully delivered.' : 'Your donated item for ' + newValue.itemName + ' has not been delivered yet.';
             const messageRequestor = newValue.completed ? 'Thanks for ordering ' + newValue.itemName + '!' : 'Your order for ' + newValue.itemName + ' has not been delivered yet.';

             // Retrieve FCM tokens and user details from Firestore for both donator and requestor
             const donatorPromise = admin.firestore().collection('users').doc(donatorID).get();
             const requestorPromise = admin.firestore().collection('users').doc(requestorID).get();

             return Promise.all([donatorPromise, requestorPromise])
                 .then(docs => {
                     const donatorDoc = docs[0];
                     const requestorDoc = docs[1];

                     // Check if both donator and requestor documents exist and contain FCM tokens
                     if (donatorDoc.exists && donatorDoc.data().fcmToken && requestorDoc.exists && requestorDoc.data().fcmToken) {
                         const donatorToken = donatorDoc.data().fcmToken;
                         const requestorToken = requestorDoc.data().fcmToken;

                         // Send notifications to both donator and requestor
                         const donatorPayload = {
                             notification: {
                                 title: 'Item Donation Status',
                                 body: messageDonator
                             }
                         };

                         const requestorPayload = {
                             notification: {
                                 title: 'Order Status',
                                 body: messageRequestor
                             }
                         };

                         // Save notification details in Firestore for both donator and requestor
                         const donatorNotificationData = {
                             title: 'Item Donation Status',
                             body: messageDonator,
                             timestamp: admin.firestore.FieldValue.serverTimestamp(),
                             userId: donatorID
                         };

                         const requestorNotificationData = {
                             title: 'Order Status',
                             body: messageRequestor,
                             timestamp: admin.firestore.FieldValue.serverTimestamp(),
                             userId: requestorID
                         };

                         const donatorNotificationPromise = admin.messaging().sendToDevice(donatorToken, donatorPayload);
                         const requestorNotificationPromise = admin.messaging().sendToDevice(requestorToken, requestorPayload);

                         const donatorFirestorePromise = admin.firestore().collection('notifications').add(donatorNotificationData);
                         const requestorFirestorePromise = admin.firestore().collection('notifications').add(requestorNotificationData);

                         return Promise.all([donatorNotificationPromise, requestorNotificationPromise, donatorFirestorePromise, requestorFirestorePromise])
                             .then(() => {
                                 console.log('Notifications sent successfully');
                                 return null;
                             })
                             .catch(error => {
                                 console.error('Error sending notifications:', error);
                                 return null;
                             });
                     } else {
                         console.log('FCM tokens not found for both donator and requestor');
                         return null;
                     }
                 })
                 .catch(error => {
                     console.error('Error retrieving FCM tokens:', error);
                     return null;
                 });
         } else {
             return null;
         }
     });




