#!/bin/bash

display() {
    echo -e "\033c"
    echo "
    ==========================================================================
$(tput setaf 6) ⠀⠀FORKED FROM KLOVITEGG https://github.com/beastgamer81/klovitegg
$(tput setaf 6) ⠀⠀⠀⠀⠀          ⠀       ⠀⠻⣷⣄
$(tput setaf 6)⠀⠀⠀           ⠀  ⢀⣴⣿⣿⣿⡿⠋⠀⠹⣿⣦⡀
$(tput setaf 6)⠀⠀            ⢀⣴⣿⣿⣿⣿⣏⠀⠀⠀⠀⠀⠀⢹⣿⣧
$(tput setaf 6)⠀             ⠙⢿⣿⡿⠋⠻⣿⣿⣦⡀⠀⠀⠀⢸⣿⣿⡆
$(tput setaf 6)⠀             ⠀⠀⠉⠀⠀⠀⠈⠻⣿⣿⣦⡀⠀⢸⣿⣿⡇
$(tput setaf 6)⠀⠀⠀⠀            ⢀⣀⣄⡀⠀⠀⠈⠻⣿⣿⣶⣿⣿⣿⠁
$(tput setaf 6)⠀⠀⠀            ⣠⣿⣿⢿⣿⣶⣶⣶⣶⣾⣿⣿⣿⣿⡁
$(tput setaf 6)            ⢠⣶⣿⣿⠋⠀⠀⠉⠛⠿⠿⠿⠿⠿⠛⠻⣿⣿⣦⡀
$(tput setaf 6)            ⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⡿   
$(tput setaf 6)  
$(tput setaf 6)     
$(tput setaf 6)   ☭ Народная армия непобедима!
$(tput setaf 6)  
$(tput setaf 6)   
$(tput setaf 6)    
$(tput setaf 6) COPYRIGHT 2024 ReyoServers Technology (https://reyo.run) & https://github.com/AvexXS & https://github.com/beastgamer81

    ==========================================================================
    "  
}

forceStuffs() {
mkdir -p plugins && mkdir -p plugins/noMemberShutdown
cd plugins && curl -O https://cdn.modrinth.com/data/DgUoVPBP/versions/QucVTrXS/IdleServerShutdown-1.3.jar && cd ../.
cd plugins && cd noMemberShutdown && curl -O https://raw.githubusercontent.com/AvexXS/SovietEgg/main/config.yml && cd ../. && cd ../.
echo "eula=true" > eula.txt
}

# Install functions
installJq() {
if [ ! -e "tmp/jq" ]; then
mkdir -p tmp
curl -s -o tmp/jq -L https://github.com/jqlang/jq/releases/download/jq-1.7rc1/jq-linux-amd64
chmod +x tmp/jq
fi
}

installPhp() {
installJq

REQUIRED_PHP_VERSION=$(curl -sSL https://update.pmmp.io/api?channel="$1" | jq -r '.php_version')

PMMP_VERSION="$2"

curl --location --progress-bar https://github.com/pmmp/PHP-Binaries/releases/download/php-"$REQUIRED_PHP_VERSION"-latest/PHP-Linux-x86_64-"$PMMP_VERSION".tar.gz | tar -xzv

EXTENSION_DIR=$(find "bin" -name '*debug-zts*')
  grep -q '^extension_dir' bin/php7/bin/php.ini && sed -i'bak' "s{^extension_dir=.*{extension_dir=\"$EXTENSION_DIR\"{" bin/php7/bin/php.ini || echo "extension_dir=\"$EXTENSION_DIR\"" >>bin/php7/bin/php.ini
}

# Useful functions
jq() {
    tmp/jq "$@"
}

# Validation functions
validateJavaVersion() {
    if [ ! "$(command -v java)" ]; then
      echo "Java is missing! Please ensure the 'Java' Docker image is selected in the startup options and then restart the server."
      sleep 5
      exit
    fi

    
    installJq
    
    VER_EXISTS=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep -m1 true)
	LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions' | jq -r '.[-1]')
}

# Launch functions
launchJavaServer() {

  
  # Remove 200 mb to prevent server freeze
  number=200
  memory=$((SERVER_MEMORY - number))
  
  java -Xms128M -Xmx${memory}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui
}

launchPMMPServer() {
  if [ ! "$(command -v ./bin/php7/bin/php)" ]; then
    echo "Php not found, installing Php..."
    sleep 5
    PMMP_VERSION="${PMMP_VERSION^^}"
  
    if [[ "${PMMP_VERSION}" == "PM4" ]]; then
      API_CHANNEL="4"
    elif [[ "${PMMP_VERSION}" == "PM5" ]]; then
      API_CHANNEL="stable"
    else
      printf "Unsupported version: %s" "${PMMP_VERSION}"
      exit 1
    fi
    installPhp "$API_CHANNEL" "$PMMP_VERSION"
    sleep 5
  fi
./bin/php7/bin/php ./PocketMine-MP.phar --no-wizard --disable-ansi
}

launchNodeServer() {
    if [ ! "$(command -v node)" ]; then
      echo "Node.js is missing! Please ensure the 'NodeJS' Docker image is selected in the startup options and then restart the server."
      sleep 5
      exit
    fi
    if [ -n "$NODE_DEFAULT_ACTION" ]; then
      action="$NODE_DEFAULT_ACTION"
    else
      echo "
      $(tput setaf 3)What to run?
      1) Run main file      2) Install packages from package.json
        "
      read -r action
    fi
    case $action in
      1)
        if [[ "${NODE_MAIN_FILE}" == "*.js" ]]; then
        node "${NODE_MAIN_FILE}"
        else
        if [ ! "$(command -v ts-node)" ]; then
          echo "ts-nods is missing! Your selected nodejs version doesn't support ts-node."
          sleep 5
          exit
        fi
        ts-node "${NODE_MAIN_FILE}"
        fi
      ;;
      2)
        npm install
      ;;
      *) 
        echo "Error 404"
        exit
      ;;
    esac
}

optimizeJavaServer() {
  echo "view-distance=6" >> server.properties
  
}

if [ ! -e "server.jar" ] && [ ! -e "nodejs" ] && [ ! -e "PocketMine-MP.phar" ]; then
    display
sleep 5
echo "
  $(tput setaf 3)Which platform are you gonna use?
  1) Paper             2) Purpur
  3) BungeeCord        4) PocketmineMP
  "
read -r n

case $n in
  1) 
    sleep 1

    echo "$(tput setaf 3)Starting the download for PaperMC ${MINECRAFT_VERSION} please wait"

    sleep 4

    forceStuffs
    
    installJq

    VER_EXISTS=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep -m1 true)
	LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions' | jq -r '.[-1]')

	if [ "${VER_EXISTS}" == "true" ]; then
		echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
	else
		echo -e "Specified version not found. Defaulting to the latest paper version"
		MINECRAFT_VERSION=${LATEST_VERSION}
	fi
	
	BUILD_NUMBER=$(curl -s https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION} | jq -r '.builds' | jq -r '.[-1]')
	JAR_NAME=paper-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar
	DOWNLOAD_URL=https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}
	
	curl -o server.jar "${DOWNLOAD_URL}"

    display
    
    echo -e ""
    
    optimizeJavaServer
    launchJavaServer
    forceStuffs
  ;;
  2)
    sleep 1

    echo "$(tput setaf 3)Starting the download for PurpurMC ${MINECRAFT_VERSION} please wait"

    sleep 4

    forceStuffs
    
    installJq
    
    VER_EXISTS=$(curl -s https://api.purpurmc.org/v2/purpur | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep true)
	LATEST_VERSION=$(curl -s https://api.purpurmc.org/v2/purpur | jq -r '.versions' | jq -r '.[-1]')

	if [ "${VER_EXISTS}" == "true" ]; then
		echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
	else
		echo -e "Specified version not found. Defaulting to the latest purpur version"
		MINECRAFT_VERSION=${LATEST_VERSION}
	fi
	
	BUILD_NUMBER=$(curl -s https://api.purpurmc.org/v2/purpur/${MINECRAFT_VERSION} | jq -r '.builds.latest')
	JAR_NAME=purpur-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar
	DOWNLOAD_URL=https://api.purpurmc.org/v2/purpur/${MINECRAFT_VERSION}/${BUILD_NUMBER}/download
	
	curl -o server.jar "${DOWNLOAD_URL}"

    display
    
    echo -e ""
    
    optimizeJavaServer
    launchJavaServer
    forceStuffs
  ;;
  3)
    sleep 1
    
    echo "$(tput setaf 3)Starting the download for Bungeecord latest please wait"
    
    sleep 4

    curl -o server.jar https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar
    
    touch proxy

    display
    
    sleep 10

    echo -e ""

    launchJavaServer proxy
  ;;
  4)
  sleep 1
  
  echo "$(tput setaf 3)Starting the download for PocketMine-MP ${PMMP_VERSION} please wait"
  
  sleep 4
  
  PMMP_VERSION="${PMMP_VERSION^^}"
  
  if [[ "${PMMP_VERSION}" == "PM4" ]]; then
    API_CHANNEL="4"
  elif [[ "${PMMP_VERSION}" == "PM5" ]]; then
     API_CHANNEL="stable"
  else
    printf "Unsupported version: %s" "${PMMP_VERSION}"
    exit 1
  fi
  
  if [ ! "$(command -v ./bin/php7/bin/php)" ]; then
    installPhp "$API_CHANNEL" "$PMMP_VERSION"
    sleep 5
  fi
  
  installJq
  
  DOWNLOAD_LINK=$(curl -sSL https://update.pmmp.io/api?channel="$API_CHANNEL" | jq -r '.download_url')

  curl --location --progress-bar "${DOWNLOAD_LINK}" --output PocketMine-MP.phar
  
  display
    
  echo -e ""
  
  launchPMMPServer
  ;;
  5)
  echo "$(tput setaf 3)Starting Download please wait"
  touch nodejs
  
  display
  
  sleep 10

  echo -e ""
  
  launchNodeServer
  ;;
  *) 
    echo "Error 404"
    exit
  ;;
esac  
else
if [ -e "server.jar" ]; then
    display   
    forceStuffs
    if [ -e "proxy" ]; then
    launchJavaServer proxy
    else
    launchJavaServer
    fi
elif [ -e "PocketMine-MP.phar" ]; then
    display
    launchPMMPServer
elif [ -e "nodejs" ]; then
    display
    launchNodeServer
fi
fi
