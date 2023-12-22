# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import firestore_fn, https_fn

# The Firebase Admin SDK to access Cloud Firestore.
from firebase_admin import initialize_app, firestore
import google.cloud.firestore

app = initialize_app()


@https_fn.on_request()
def addmessage(req: https_fn.Request) -> https_fn.Response:
    """Take the text parameter passed to this HTTP endpoint and insert it into
    a new document in the messages collection."""
    # Grab the text parameter.
    original = req.args.get("text")
    if original is None:
        return https_fn.Response("No text parameter provided", status=400)

    firestore_client: google.cloud.firestore.Client = firestore.client()

    # Push the new message into Cloud Firestore using the Firebase Admin SDK.
    _, doc_ref = firestore_client.collection("messages").add({"original": original})

    # Send back a message that we've successfully written the message
    return https_fn.Response(f"Message with ID {doc_ref.id} added.")


@firestore_fn.on_document_created(document="messages/{pushId}")
def makeuppercase(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """Listens for new documents to be added to /messages. If the document has
    an "original" field, creates an "uppercase" field containg the contents of
    "original" in upper case."""

    # Get the value of "original" if it exists.
    if event.data is None:
        return
    try:
        original = event.data.get("original")
    except KeyError:
        # No "original" field, so do nothing.
        return

    # Set the "uppercase" field.
    print(f"Uppercasing {event.params['pushId']}: {original}")
    upper = original.upper()
    event.data.reference.update({"uppercase": upper})
    
    
import firebase_admin
from firebase_admin import credentials, messaging, firestore 

try:
    cred = credentials.Certificate("/Users/gahana/Desktop/PersonalProject/MyCloset/mycloset-e2492-firebase-adminsdk-f6f3b-0440522fb6.json")
    firebase_admin.initialize_app(cred)
except ValueError as e:
    if 'The default Firebase app already exists' in str(e):
        pass
    else:
        print(e)

db = firestore.client()

previous_data = {}

def on_auth_change2(doc_snapshot, changes, read_time):
    global previous_data
    
    for change in changes:
        try:
            # Get document ID
            document_id = change.document.id
            
            # Get the previous data from the cache or default to an empty dictionary
            old_data = previous_data.get(document_id, {})
            
            # Get the current data
            new_data = change.document.to_dict()
            
            # Update the cache with the current data
            previous_data[document_id] = new_data
            
            if 'notification' in old_data and 'notification' in new_data and 'fmc' in new_data:
                old_notifications = old_data['notification']
                new_notifications = new_data['notification']
                fmc_token = new_data['fmc']
                
                if len(new_notifications) > len(old_notifications) and fmc_token:
                    added_notification = new_notifications[-1]
                    message = messaging.Message(
                        notification=messaging.Notification(
                            title='MyCloset',
                            body=added_notification['name'] + ' ' + added_notification['comment']
                        ),
                        token=fmc_token,
                    )
                    response = messaging.send(message)
                    print('Successfully sent message:', response)
                    
                    
            if 'pending' in old_data and 'pending' in new_data and 'fmc' in new_data:
                old_pending = old_data['pending']
                new_pending = new_data['pending']
                fmc_token = new_data['fmc']
                
                if len(new_pending) > len(old_pending) and fmc_token:
                    message = messaging.Message(
                        notification=messaging.Notification(
                            title='MyCloset',
                            body= 'Someone just asked to follow you'
                        ),
                        token=fmc_token,
                    )
                    response = messaging.send(message)
                    print('Successfully sent message:', response)
        except Exception as e:
            print(f'Error processing change: {e}')

# Watch the 'auth' collection for changes
auth_collection = db.collection('auth')

# Get the initial snapshot
initial_snapshot = auth_collection.get()

# Process the initial snapshot
for doc in initial_snapshot:
    on_auth_change2(None, [doc], None)

# Attach the listener for ongoing changes
doc_watch = auth_collection.on_snapshot(on_auth_change2)


try:
    while True:
        pass
except KeyboardInterrupt:
    doc_watch()
