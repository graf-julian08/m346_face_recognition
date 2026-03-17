#!/bin/bash

# Lese die Bucket-Namen, die vom Init.sh erstellt wurden, ein
if [ ! -f "buckets.txt" ]; then
    echo "Fehler: buckets.txt nicht gefunden. Bitte zuerst Init.sh ausführen."
    exit 1
fi

IN_BUCKET=$(sed -n '1p' buckets.txt)
OUT_BUCKET=$(sed -n '2p' buckets.txt)

TEST_BILD="testbild.jpg"

if [ ! -f "$TEST_BILD" ]; then
    echo "Fehler: Datei $TEST_BILD nicht gefunden. Bitte ein Foto im selben Ordner ablegen."
    exit 1
fi

echo "Lade $TEST_BILD in den Input-Bucket ($IN_BUCKET) hoch..."
aws s3 cp $TEST_BILD s3://$IN_BUCKET/ --region us-east-1

echo "Warte 10 Sekunden auf die Verarbeitung durch die AWS Cloud..."
sleep 10

echo "Lade generierte JSON-Datei herunter..."
aws s3 cp s3://$OUT_BUCKET/$TEST_BILD.json result.json --region us-east-1

echo "----------------------------------------------------"
echo "Ergebnis der Cloud Face Recognition:"

# Kriterium A7: Simpler Python-Einzeiler zum Auslesen, damit man kein "jq" installieren muss
python3 -c "
import json
try:
    with open('result.json') as f:
        data = json.load(f)
        if len(data['CelebrityFaces']) > 0:
            name = data['CelebrityFaces'][0]['Name']
            conf = data['CelebrityFaces'][0]['MatchConfidence']
            print(f'> Erkannte Person: {name} (Wahrscheinlichkeit: {conf:.2f}%)')
        else:
            print('> Es wurde keine prominente Person auf diesem Bild erkannt.')
except Exception as e:
    print('> Fehler beim Lesen der Analysedaten.')
"
echo "----------------------------------------------------"
