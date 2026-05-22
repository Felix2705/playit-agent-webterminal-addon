# Playit Agent WebTerminal Add-on

Dieses Home-Assistant Supervisor Add-on startet automatisch den **Playit Agent (playitd)** und stellt zusätzlich eine **Web-Terminal-UI (ttyd)** bereit.

Damit bekommst du im Browser eine Shell, über die du auch das zugehörige **playit-cli (`playit`)** bedienen kannst.

## Voraussetzungen
- Home Assistant Supervisor (Add-on Installation möglich)
- Dein Add-on muss in Home Assistant unter **Ingress/Sidebar** erreichbar sein

## Add-on installieren & starten
1. Add-on **Playit Agent WebTerminal** installieren
2. Add-on **Starten**
3. In Home Assistant das Add-on öffnen (**Ingress/Sidebar**)
4. Die Web-Terminal-Session nutzen

## Bedienung im Web-Terminal (wichtig)

Im ttyd-Terminal steht dir der Befehl **`playit`** zur Verfügung.

### Agent steuern / Secret-Claim starten
1. Im Web-Terminal ausführen:
   ```sh
   playit
   ```

2. Falls das Frontend-Secret noch nicht provisioniert ist, führt `playit` typischerweise durch den Claim-Flow.

3. Danach läuft der Tunnel/Agent über `playitd`.

### Hilfe anzeigen
```sh
playit --help
```

### Status prüfen (für Debugging)
```sh
playit service status
```

## Playit Status Monitoring (Entities in Home Assistant)

Dieses Add-on exportiert den Output von `playit service status` als Home-Assistant Entities.

Die folgenden Entities werden angelegt/aktualisiert:

- `sensor.playit_agent_phase`  
  (z.B. `running`)

- `sensor.playit_agent_uptime_seconds`  
  (Uptime in Sekunden)

- `sensor.playit_agent_version`  
  (Playit Agent Version)

- `sensor.playit_agent_secret_configured`  
  (z.B. `true`/`false`)

### Wo finde ich die Entities?
1. Home Assistant öffnen
2. **Einstellungen → Geräte & Dienste → Entitäten** (oder Entwicklerwerkzeuge → **States**)
3. Suche nach: `playit_agent_`

### Wenn die Entities nicht erscheinen
- Add-on neu starten und **30–60 Sekunden warten** (der Exporter aktualisiert im Intervall).
- Wenn du debuggen willst, prüfe im Web-Terminal mit:
  ```sh
  playit service status
  ```

## Hinweis
Damit `playit` im Add-on funktioniert, wird im Container zusätzlich die playit-cli-Komponente bereitgestellt.
