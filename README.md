# Empyrion-Docker-Server
**Docker Image für den [Empyrion](https://empyriongame.com/) Dedicated Server incl. WINE**

Das Image selbst enthält WINE und Steamcmd sowie ein Skript „entrypoint.sh“, das die Installation des dedizierten Empyrion-Servers über Steamcmd startet.

Wenn Sie das Image ausführen, mounten Sie das Volume /home/user/Steam, um die Empyrion-Installation beizubehalten und zu vermeiden, dass es bei jedem Containerstart heruntergeladen wird.
Beispielaufruf:

```
cd /home
mkdir -p gamedir
docker run -di -p 30000:30000/udp -p 30001:30001/udp -p 30002:30002/udp -p 30003:30003/udp -p 30004:30004/udp --restart unless-stopped -v $PWD/gamedir:/home/user/Steam hamunaptra77/empyrion-server

```

Nach dem Starten des Servers können Sie die Datei „dedicated.yaml“ unter „gamedir/steamapps/common/Empyrion – Dedicated Server/dedicated.yaml“ bearbeiten.
Nach der Bearbeitung müssen Sie den Docker-Container neu starten.

Der DedicatedServer-Ordner wurde mit /server verknüpft, sodass Sie mit z:/server/Saves auf Spielstände verweisen können (z. B. den Spielstand mit dem Namen „The\_Game“):

```

# cp -r /..../Saves/Games/The_Game 'gamedir/steamapps/common/Empyrion - Dedicated Server/Saves/Games/'
# you might want a symlink for games: ln -s 'gamedir/steamapps/common/Empyrion - Dedicated Server/Saves/Games'
docker run -di -p 30000:30000/udp -p 30001:30001/udp -p 30002:30002/udp -p 30003:30003/udp -p 30004:30004/udp --restart unless-stopped -v $PWD/gamedir:/home/user/Steam hamunaptra77/empyrion-server -dedicated 'z:/server/Saves/Games/The_Game/dedicated.yaml'

```

Um Argumente an den Steamcmd-Befehl anzuhängen, verwenden Sie `-e "STEAMCMD=..."`. z.B.: `-e "STEAMCMD=+runscript /home/user/Steam/addmods.txt"`.

Weitere Informationen zum dedizierten Server selbst finden Sie im [wiki](https://empyrion.gamepedia.com/Dedicated_Server_Setup).
