#!/bin/bash

# ===============================
# Konfiguration
# ===============================
REMOTE_URL="https://domain.tld/pfad/blocklist.txt"
REMOTE_FILE="/tmp/remote_blocklist.txt"
REMOTE_LAST="/tmp/remote_blocklist_last.txt"
LOCAL_FILE="/local/pfad/new_blocklist.txt"
MERGED_FILE="/local/pfad/blocklist.txt"

echo "=== Starte Aktualisierung der IP-Blockliste ==="
echo "Ziel: $MERGED_FILE"
echo "Hole entfernte Liste von: $REMOTE_URL"
chmod 
# ===============================
# Herunterladen der entfernten Datei
# ===============================
curl -s -o "$REMOTE_FILE" "$REMOTE_URL"

if [[ ! -s "$REMOTE_FILE" ]]; then
  echo "❌ Fehler: Die heruntergeladene Datei ist leer oder konnte nicht geladen werden."
  exit 1
fi

# ===============================
# Prüfen, ob sich die Datei geändert hat
# ===============================
if [[ -f "$REMOTE_LAST" ]] && cmp -s "$REMOTE_FILE" "$REMOTE_LAST"; then
  echo "ℹ️ Keine Änderungen in der entfernten Datei. Abbruch."
  exit 0
else
  echo "✅ Neue oder geänderte Datei erkannt."
fi

# ===============================
# Backup der vorherigen Version
# ===============================
cp "$REMOTE_FILE" "$REMOTE_LAST"
echo "📝 Alte Remote-Datei aktualisiert zum Vergleich."

# ===============================
# Mergen der Dateien
# ===============================
echo "🔄 Führe $LOCAL_FILE und neue Remote-Datei zusammen ..."
cat "$LOCAL_FILE" "$REMOTE_FILE" | sort -u > "$MERGED_FILE"

MERGED_COUNT=$(wc -l < "$MERGED_FILE")
echo "✅ Zusammenführung abgeschlossen. Einträge gesamt: $MERGED_COUNT"

# ===============================
# Optional: Ausgabe der neuen Einträge
# ===============================
echo "📋 Neue Einträge (die vorher nicht in $LOCAL_FILE waren):"
comm -13 <(sort "$LOCAL_FILE") <(sort "$REMOTE_FILE")

echo "=== Fertig ==="
