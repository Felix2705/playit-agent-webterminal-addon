# Playit Agent WebTerminal Add-on (0.0.6-Beta)

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

## Hinweis
Damit `playit` im Add-on funktioniert, wird im Container zusätzlich die playit-cli-Komponente bereitgestellt.
