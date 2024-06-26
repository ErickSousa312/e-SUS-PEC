training=''
cache='--no-cache'

while getopts "tf:" flag; do
    case "${flag}" in
        f) filename=${OPTARG};;
        t) training='-treinamento';;
        c) cache='';;
        \?)
        echo "Opção(ões) inválida(s) adicionada(s), apenas

            -f {nome do arquivo} para especificar o arquivo jar a ser utilizado, 
            -c para utilizar o cache quando estiver rodando build das imagens docker e
            -t para versão de treinamento 
            
            são consideradas válidas"
        ;;
    esac
done

export COMPOSE_HTTP_TIMEOUT=8000

echo "Instalando e-SUS-PEC pelo arquivo $filename";
docker compose down --volumes --remove-orphans
sudo chmod -R 755 data
echo "docker-compose build --build-arg JAR_FILENAME=$filename --build-arg TRAINING=$training"
docker compose build $cache --build-arg JAR_FILENAME=$filename --build-arg TRAINING=$training
docker compose up -d
echo "Avaliando estado de execução container"
docker compose ps
sleep 15
docker compose ps

# Na hora de fazer o build não pode instalar os pacotes porque depende do banco de dados, por isso deve ser instalado por fora
docker exec -it esus_app bash -c "sh /var/www/html/install.sh"
# Executando novamente o ENTRYPOINT do docker file, dessa vez com os pacotes já instalados.
docker exec -it esus_app bash -c "sh /var/www/html/run.sh"