(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-baseimage:x86_64-0.1.0
docker tag hyperledger/fabric-baseimage:x86_64-0.1.0 hyperledger/fabric-baseimage:latest

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Open the playground in a web browser.
case "$(uname)" in 
"Darwin")   open http://localhost:8080
            ;;
"Linux")    if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                 xdg-open http://localhost:8080
	        elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
                       #elif other types bla bla
	        else   
		            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
            ;;
*)          echo "Playground not launched - this OS is currently not supported "
            ;;
esac

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��6Y �[o�0�yxᥐ� �21�BJ�AI`�S<r�si���>;e����R�i����s|αq{q��0�`k繵w�'�zz��|�NE��	� t���о��BGh5��(e�(�0 �[)���^����G(�%Po�/"�Sd�H� ��ފ�pj�7 �g��6�b:k��k����)��{f���[���1L|�F����� h����H���l�O|��Q4��7��kˡ9��g�E�c��LF�ֳ|G�EK�iȿs!~S�<��ol�	E[���E�Hm�oV:T5ٜ˲fF#M����PG�!��Z��$b4W'3����I�8.�0��s��܊ȭ8HQ���ll*�RV�#�f1���d�'ɫp�?OL�T`N��*NkxFo�U��6B��mbܗ��J���B��(6K�;ёWM6�����ӵoI�22���m�!
ݖ��h�6hD.�!�~�ˀ8�C&~�4p�f�*�t���s���_�f�Z�5ߩl�k����Q��|�N[��Cu:WuRš:���%�i� ���	���>�cr��q��\ե��h6��-y�Ϸ<H�G����QH?A�w�Ā�lH�n/���p?sٹ�����q�3�	<x�3�:d���!YA��'�gq�B}�.4�N�ơMv�I×'��TB�9z ��0%q�%�J�X���v_,(K���%��`���9��|Y�{.1o*��x(+��?��Ň�ޭ������_��2��`0��`0��`0��7�	3� (  