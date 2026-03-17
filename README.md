# Projekt: Cloud Face Recognition (AWS)

**Autoren:** Olha Vilkhova, Philipp Crista, Julian Graf  
**Modul:** 346 - Cloud Computing (GBS St. Gallen)

---

## 📑 Inhaltsverzeichnis
1. [Einleitung](#1-einleitung)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Inbetriebnahme (Init.sh)](#3-inbetriebnahme-initsh)
4. [Testen der Anwendung (Test.sh)](#4-testen-der-anwendung-testsh)
5. [Testprotokolle](#5-testprotokolle)
6. [Reflexion](#6-reflexion)

---

## 1. Einleitung
In diesem Projekt wird eine serverlose Cloud-Architektur auf AWS aufgebaut, welche in der Lage ist, Gesichter von prominenten Personen auf Bildern automatisch zu erkennen. Wird ein Bild via Konsole in den S3 Input-Bucket hochgeladen, löst dies im Hintergrund eine AWS Lambda-Funktion aus. Diese kontaktiert den Machine Learning Service (AWS Rekognition) und speichert die genaue Resultat-Auswertung anschliessend als konfigurierte JSON-Datei in einem Output-Bucket ab.

## 2. Voraussetzungen
- Eine aktive **AWS Learner Lab** Umgebung.
- Die AWS CLI muss konfiguriert und eingeloggt sein.
- Die standardmässige `LabRole` ARN existiert im Account.
- Bash-Terminal (macOS / Linux) sowie lokal installiertes Python 3.

## 3. Inbetriebnahme (Init.sh)
Die gesamte Infrastruktur kann per Knopfdruck ("Infrastructure as Code" durch die CLI) angelegt werden. 

1. Öffne das Terminal in diesem Ordner.
2. Gib dem Setup-Skript die nötigen Rechte: `chmod +x Init.sh`
3. Führe das Skript aus: `./Init.sh`

**Das passiert im Hintergrund:** Es werden zwei global eindeutige S3-Buckets erstellt, sowie der Python-Code in ein ZIP gepackt. Danach wird die Lambda-Funktion eingerichtet und konfiguriert, sodass sie sofort auf `.jpg`-Dateien im Input-Bucket reagiert.

## 4. Testen der Anwendung (Test.sh)
Das Testskript validiert, ob der gesamte Prozess fehlerfrei funktioniert.

1. Lege ein Testfoto mit einem klaren Gesicht in diesen Ordner und nenne es `testbild.jpg`.
2. Mache das Test-Skript ausführbar: `chmod +x Test.sh`
3. Starte den Durchlauf: `./Test.sh`

**Erklärung zur Funktionsweise:**  
Das Skript lädt das Bild in den korrekten Input-Bucket hoch, wartet anschliessend ca. 10 Sekunden ab, bis die Lambda-Funktion ihre Auswertung durchgeführt hat. Zum Schluss lädt es die fertig berechnete JSON-Datei direkt wieder aus dem Output-Bucket herunter und gibt den erkannten Prominenten-Namen benutzerfreundlich im Terminal aus.

## 5. Testprotokolle

*Konsolen-Ausgabe des automatischen Test-Durchlaufs*
![Screenshot des Terminals](screenshot_console.png)

*AWS Konsole - in-Bucket*
![Screenshot S3 in-Bucket](screenshot_s3_in-bucket.png)

*AWS Konsole - out-Bucket*
![Screenshot S3 out-Bucket](screenshot_s3_out-bucket.png)

```json
{
    "CelebrityFaces": [
        {
            "Urls": [
                "www.wikidata.org/wiki/Q312556",
                "www.imdb.com/name/nm1757263"
            ],
            "Name": "Jeff Bezos",
            "Id": "1SK7cR8M",
            "Face": {
                "BoundingBox": {
                    "Width": 0.47121626138687134,
                    "Height": 0.47573384642601013,
                    "Left": 0.25664907693862915,
                    "Top": 0.16509905457496643
                },
                "Confidence": 99.99126434326172,
                "Landmarks": [
                    {
                        "Type": "eyeRight",
                        "X": 0.5219948291778564,
                        "Y": 0.3610323965549469
                    },
                    {
                        "Type": "mouthRight",
                        "X": 0.4940885901451111,
                        "Y": 0.5189938545227051
                    },
                    {
                        "Type": "eyeLeft",
                        "X": 0.33557432889938354,
                        "Y": 0.3498147428035736
                    },
                    {
                        "Type": "nose",
                        "X": 0.36760419607162476,
                        "Y": 0.4371366798877716
                    },
                    {
                        "Type": "mouthLeft",
                        "X": 0.3390909433364868,
                        "Y": 0.5089998841285706
                    }
                ],
                "Pose": {
                    "Roll": 1.629677176475525,
                    "Yaw": -20.523847579956055,
                    "Pitch": 0.5295497179031372
                },
                "Quality": {
                    "Brightness": 85.7474136352539,
                    "Sharpness": 53.330047607421875
                },
                "Emotions": [
                    {
                        "Type": "HAPPY",
                        "Confidence": 96.41926574707031
                    },
                    {
                        "Type": "CALM",
                        "Confidence": 0.88958740234375
                    },
                    {
                        "Type": "DISGUSTED",
                        "Confidence": 0.1018524169921875
                    },
                    {
                        "Type": "CONFUSED",
                        "Confidence": 0.05412101745605469
                    },
                    {
                        "Type": "SURPRISED",
                        "Confidence": 0.025957822799682617
                    },
                    {
                        "Type": "SAD",
                        "Confidence": 0.01862049102783203
                    },
                    {
                        "Type": "FEAR",
                        "Confidence": 0.001722574234008789
                    },
                    {
                        "Type": "ANGRY",
                        "Confidence": 0.0012099742889404297
                    }
                ],
                "Smile": {
                    "Value": true,
                    "Confidence": 96.80350494384766
                }
            },
            "MatchConfidence": 99.99794006347656,
            "KnownGender": {
                "Type": "Male"
            }
        }
    ],
    "UnrecognizedFaces": [],
    "ResponseMetadata": {
        "RequestId": "f02c0f6a-4968-4ffc-b922-7d783b43a189",
        "HTTPStatusCode": 200,
        "HTTPHeaders": {
            "x-amzn-requestid": "f02c0f6a-4968-4ffc-b922-7d783b43a189",
            "content-type": "application/x-amz-json-1.1",
            "content-length": "1360",
            "date": "Tue, 17 Mar 2026 08:33:22 GMT"
        },
        "RetryAttempts": 0
    }
}
```

## 6. Reflexion

**Was lief gut:**  
Die Anbindung von `boto3` an den AWS Rekognition Service in der Python Lambda-Funktion war überraschend einfach umzusetzen und verlangte nur sehr wenige Zeilen Code. Das Setup direkt in einem CLI-Skript (`Init.sh`) zu automatisieren, half beim Testen enorm: So konnten wir bei Fehlern die Ressourcen viel schneller neu generieren, ohne jedes Mal ewig in der AWS Web-Konsole herumklicken zu müssen.

**Was lief schlecht:**  
Am Anfang gab es Hindernisse mit den S3-Triggern und den IAM-Rollen, da im AWS Learner Lab sehr strenge Rechte herrschen und man keine eigenen Rollen erstellen kann. Die Lambda-Funktion durfte zu Beginn auch gar nicht von S3 ausgelöst werden, da im Skript der "add-permission"-Befehl (`lambda:InvokeFunction`) gefehlt hat. Auch die Übergabe des generierten Output-Bucket-Namens war am Anfang etwas mühsam.

**Verbesserungsvorschläge (nächstes Mal):**  
In einer nächsten Version würden wir die Python-Funktion absichern, um zu prüfen, ob die Datei auch wirklich von Rekognition validiert werden kann (z. B. auf kaputte Dateien prüfen), statt dem Service blind zu vertrauen. Zusätzlich wäre eine Amazon SNS-Anbindung spannend: So könnte man eine SMS oder E-Mail auslösen, sobald eine Bildauswertung abgeschlossen ist.