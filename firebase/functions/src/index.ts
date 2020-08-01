import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// import { user } from 'firebase-functions/lib/providers/auth';

admin.initializeApp();
const db = admin.firestore();

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const getSubCollections = functions.region("us-east1").https.onCall(async (data, context) => {
    const docPath = data.path;

    const collections = await db.doc(docPath).listCollections();
    const collectionIds = collections.map(col => col.id);
    return { collections: collectionIds };
});

export const deleteCollection = functions.region("us-east1").https.onCall(async (data, context) => {
    const colPath = data.path;

    const collectionRef = await db.collection(colPath);
    const promises: any[] = [];

    return collectionRef.get()
        .then(snapshot => {
            snapshot.forEach(docSnapshot => {
                promises.push(docSnapshot.ref.delete());
            });

            return Promise.all(promises);
        })
        .catch(error => {
            console.log(error);
            return false;
        });
});

export const renameCollection = functions.region("us-east1").https.onCall(async (data, context) => {
    const colPath = data.path;
    const newName = data.name;

    const oldRef = await db.collection(colPath);
    const newRef = await db.collection(newName);

    let promises: any[] = [];

    return oldRef.get()
        .then(snapshot => {
            snapshot.forEach(docSnapshot => {
                promises.push(newRef.add(docSnapshot.data));
            });

            return Promise.all(promises)
                .then(() => {
                    promises = []
                    return oldRef.get()
                        .then(snapshot2 => {
                            snapshot2.forEach(docSnapshot2 => {
                                promises.push(docSnapshot2.ref.delete());
                            });

                            return Promise.all(promises);
                        })
                        .catch(error => {
                            console.log(error);
                            return false;
                        });
                })
        })
        .catch(error => {
            console.log(error);
            return false;
        });


});

export const deleteUser = functions.region("us-east1").https.onCall(async (data, context) => {
    const userPath = data.path;

    const client = require('firebase-tools');
    return await client.firestore
        .delete(userPath, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            token: "1//01PRUx4NdaxEbCgYIARAAGAESNwF-L9IrPT13mBqEPUYTQYCeXVF_WYwtb4OfF9bN7ULszAfRkt_EpihRQe3hxh86KiIOEKE1jqI"
            // token: functions.config().fb.token
        }); 


    // const functions = require("firebase-functions");

    // for (let col of await db.doc(userPath).listCollections()) {
    //     const promises: any[] = [];

    //     col.get()
    //     .then(async snapshot => {
    //         snapshot.forEach(docSnapshot => {
    //             require("firebase-functions").logger.log("docSnapshot:", docSnapshot)
    //             promises.push(docSnapshot.ref.delete());
    //         });

    //         await Promise.all(promises);
    //     })
    //     .catch(error => {
    //         console.log(error);
    //         return false;
    //     });
    // }

    
});