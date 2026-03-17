#!/bin/bash

# Generiere eine Zufallszahl für global eindeutige Bucket-Namen
RAND_NUM=$RANDOM

IN_BUCKET="in-bucket-m346-$RAND_NUM"
OUT_BUCKET="out-bucket-m346-$RAND_NUM"

echo "Erstelle S3 Buckets..."
aws s3 mb s3://$IN_BUCKET --region us-east-1
aws s3 mb s3://$OUT_BUCKET --region us-east-1

# Kriterium A7: Ausgabe der generierten Namen in der Konsole
echo "Buckets erfolgreich erstellt:"
echo "- Input Bucket: $IN_BUCKET"
echo "- Output Bucket: $OUT_BUCKET"

# Speichere die Namen für das Test.sh Skript
echo $IN_BUCKET > buckets.txt
echo $OUT_BUCKET >> buckets.txt

# AWS Account ID für die LabRole ARN im Learner Lab holen
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region us-east-1)
LAB_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/LabRole"

echo "Verpacke Lambda Programmcode..."
zip -q lambda_function.zip lambda_function.py

echo "Erstelle Lambda-Funktion..."
aws lambda create-function \
    --function-name face-recognition-lambda \
    --runtime python3.9 \
    --role $LAB_ROLE_ARN \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://lambda_function.zip \
    --timeout 15 \
    --region us-east-1 \
    > /dev/null

echo "Füge Trigger-Berechtigung für S3 hinzu..."
aws lambda add-permission \
    --function-name face-recognition-lambda \
    --principal s3.amazonaws.com \
    --statement-id s3invoke \
    --action "lambda:InvokeFunction" \
    --source-arn "arn:aws:s3:::$IN_BUCKET" \
    --source-account $ACCOUNT_ID \
    --region us-east-1 \
    > /dev/null

LAMBDA_ARN=$(aws lambda get-function --function-name face-recognition-lambda --query 'Configuration.FunctionArn' --output text --region us-east-1)

echo "Konfiguriere S3 Trigger für .jpg Dateien..."
cat <<EOF > notification.json
{
  "LambdaFunctionConfigurations": [
    {
      "LambdaFunctionArn": "$LAMBDA_ARN",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            { "Name": "suffix", "Value": ".jpg" }
          ]
        }
      }
    }
  ]
}
EOF

aws s3api put-bucket-notification-configuration \
    --bucket $IN_BUCKET \
    --notification-configuration file://notification.json \
    --region us-east-1

rm notification.json

echo "Setup erfolgreich abgeschlossen!"
