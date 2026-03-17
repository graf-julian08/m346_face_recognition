# Autor: Julian Graf
# Datum: 17.03.2026
# Quelle: AWS Boto3 Dokumentation (rekognition)

import boto3
import json

def lambda_handler(event, context):
    # AWS Clients für S3 und Rekognition erstellen
    s3 = boto3.client('s3')
    rekognition = boto3.client('rekognition')
    
    # Bucket und Dateiname aus dem S3-Upload Event auslesen
    bucket = event['Records'][0]['s3']['bucket']['name']
    image_name = event['Records'][0]['s3']['object']['key']
    
    # Den Namen für den Output-Bucket berechnen (aus "in-bucket..." wird "out-bucket...")
    out_bucket = bucket.replace('in-bucket', 'out-bucket')
    
    # Bild mit AWS Rekognition analysieren (Suchfunktion für Prominente)
    response = rekognition.recognize_celebrities(
        Image={
            'S3Object': {
                'Bucket': bucket,
                'Name': image_name
            }
        }
    )
    
    # Antwort als JSON-Text formatieren
    json_data = json.dumps(response, indent=4)
    out_file_name = image_name + '.json'
    
    # Resultat in den Out-Bucket speichern
    s3.put_object(
        Bucket=out_bucket,
        Key=out_file_name,
        Body=json_data
    )
    
    # Erfolgreichen Status an AWS zurückmelden
    return {
        'statusCode': 200,
        'body': 'Bild erfolgreich analysiert!'
    }
