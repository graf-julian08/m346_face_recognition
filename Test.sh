#!/bin/bash

echo "=============================================="
echo "Cloud Face Recognition Test wird gestartet..."
echo "=============================================="

# Prüfen, ob buckets.txt existiert
if [ ! -f "buckets.txt" ]; then
    echo "Fehler: buckets.txt wurde nicht gefunden."
    echo "Bitte zuerst das Setup-Skript Init.sh ausführen."
    exit 1
fi

# Bucket-Namen auslesen
IN_BUCKET=$(sed -n '1p' buckets.txt)
OUT_BUCKET=$(sed -n '2p' buckets.txt)

TEST_BILD="testbild.jpg"

# Prüfen, ob das Testbild existiert
if [ ! -f "$TEST_BILD" ]; then
    echo "Fehler: Die Datei $TEST_BILD wurde nicht gefunden."
    echo "Bitte legen Sie ein Testbild im selben Ordner ab."
    exit 1
fi

START=$(date +%s)

echo "[1/4] Upload (завантаження) des Testbildes in den Input-S3-Bucket..."
aws s3 cp "$TEST_BILD" "s3://$IN_BUCKET/" --region us-east-1

if [ $? -ne 0 ]; then
    echo "Fehler: Upload in den Input-Bucket ist fehlgeschlagen."
    exit 1
fi

echo "[2/4] Verarbeitung (обробка) durch AWS Lambda und Rekognition wird abgewartet..."
sleep 10

echo "[3/4] Download (завантаження результату) der generierten JSON-Datei aus dem Output-S3-Bucket..."
aws s3 cp "s3://$OUT_BUCKET/$TEST_BILD.json" result.json --region us-east-1

if [ $? -ne 0 ]; then
    echo "Fehler: Die Resultat-Datei konnte nicht aus dem Output-Bucket heruntergeladen werden."
    exit 1
fi

echo "----------------------------------------------------"
echo "[4/4] Analyseergebnis (результат аналізу):"

python3 -c "
import json
try:
    with open('result.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    if len(data.get('CelebrityFaces', [])) > 0:
        name = data['CelebrityFaces'][0]['Name']
        conf = data['CelebrityFaces'][0]['MatchConfidence']
        print(f'> Erkannte Person: {name}')
        print(f'> Match-Confidence (точність збігу): {conf:.2f}%')
    else:
        print('> Es wurde keine prominente Person auf diesem Bild erkannt.')

except Exception as e:
    print('> Fehler beim Lesen oder Verarbeiten der Analysedaten.')
"

END=$(date +%s)
DAUER=$((END - START))

echo "----------------------------------------------------"
echo "Test erfolgreich abgeschlossen."
echo "Ausführungszeit (час виконання): ${DAUER} Sekunden"
echo "=============================================="
