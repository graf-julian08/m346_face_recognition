# Projekt: Cloud Face Recognition (AWS)

**Autor:** Julian Graf  
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

*(Konsolen-Ausgabe des automatischen Test-Durchlaufs)*
[Hier Screenshot vom Terminal (Ausführung von Init.sh und Test.sh) einfügen]

*(AWS Konsole - Buckets im Learner Lab)*
[Hier Screenshot der beiden AWS S3 Buckets aus dem Webbrowser einfügen]

*(AWS S3 Inhalte)*
[Hier Screenshot von S3 aus dem Out-Bucket mit der generierten testbild.jpg.json Datei einfügen]

## 6. Reflexion

**Was lief gut:**  
Die Anbindung von `boto3` an den AWS Rekognition Service in der Python Lambda-Funktion war überraschend einfach umzusetzen und verlangte nur sehr wenige Zeilen Code. Das Setup direkt in einem CLI-Skript (`Init.sh`) zu automatisieren, half beim Testen enorm: So konnte ich bei Fehlern die Ressourcen viel schneller neu generieren, ohne jedes Mal ewig in der AWS Web-Konsole herumklicken zu müssen.

**Was lief schlecht:**  
Am Anfang gab es Hindernisse mit den S3-Triggern und den IAM-Rollen, da im AWS Learner Lab sehr strenge Rechte herrschen und man keine eigenen Rollen erstellen kann. Die Lambda-Funktion durfte zu Beginn auch gar nicht von S3 ausgelöst werden, da im Skript der "add-permission"-Befehl (`lambda:InvokeFunction`) gefehlt hat. Auch die Übergabe des generierten Output-Bucket-Namens erschien anfangs etwas mühsam.

**Verbesserungsvorschläge (nächstes Mal):**  
In einer nächsten Version würde ich die Python-Funktion absichern, um zu prüfen, ob die Datei auch wirklich von Rekognition validiert werden kann (z. B. auf kaputte Dateien prüfen), statt dem Service blind zu vertrauen. Zusätzlich wäre eine Amazon SNS-Anbindung spannend: So könnte man eine SMS oder E-Mail auslösen, sobald eine Bildauswertung abgeschlossen ist.
