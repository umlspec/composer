ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

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

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.0
docker tag hyperledger/composer-playground:0.15.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �Z �=�r�z�Mr����S�T.���X���f�����*,��M�d�h�����9:�G8Uy��F�!?�y��Mw� �"	{�|U6��믿��nj��Bf@1��B����p�Z����p"�|����$��#>,`$^D��G���p�T�\p,� <�M�U��x����E������BfWU���0 xs�����_�U��:l��a.�T۰�Ӛ�25Tk 34��M)��1L�rI [��6�C�ۢiH益���n�����R�x�8̧����� ���V�f�bw����a~ٰm�Q�cP,�K0�b6��ۖ�=���#�L��VuvN��������b"���+�Tr^1\�6�D�h�a�"&�Pב���D}?5�z:m�)6�#Ө������mM�����k~Y��vlw@ؽ�iZt� 7����x�u�y�-�?�Z�6L�jm4�ơ�pB����QT�fͭWm#�!��9x�YC&�r�xv�i9�FXo�e'�(�%lw4DZ��$n����=)�Bq��}�Q��9��V'�$e��+��U�/[�㵿i��~Lw���%2��S���k��{_}p�eW��a&Թ�-�7݇4QO��R�ܹۆ�[b;@w4�����5�#�g�-z��P:�wz�K�:�g���u��2���|��������i��� B^4*͒��p4��?���t�L��\��2�6�b�����5h5�����4{�yA���� Ey��T����
x�PU�CUh5�pLv�)Pj����d���?����y�RL��r�Y��?� :��:���<Y����S�?Y�d8?�����J`���n�����m44($�4��&p����?��D$�'pa^Z��U�z��0e�w�҂���^��q���"9��Q���O�c��z����ih�9��gg� �����Y�u�	J4��H��`������ft�Q���:�I,3^�S��S�M�$�|�6���8��6T�3x���N(�s�N��BS}�ahV��g<��i��6�W��OS�[�n��&
�-��{��pY�U<ಪJKi¡՞��!jF���u;�5��Z- M��v�k�m8Z�X�AН�!����Q��������hLB��`,80��@�Ju���8���Yx|���DΠ.���k�z}2|�0��#kZ�z��U�X�����	����
���@�<Pwt��vڠ�j�z��mtND�tt]�#���Y��y����0G�����B�c���g�Zo�4y�c	���e��������4����m���Y��+�6���(��2SWq��x��_�0��"i���Tk�%uR�5�����Q/��z����B��hĴ���x�-f�-7�a�p�c�%���1i���}mƐ���a��d���d���g�G��?1�]������.LA���vI��b�j��{�\�QmZ��^3�׾����0G��.{�!h!`!)6�5U�	*ـW�eܯ��S:9��v6b�^G ��9K*c�1��T��G���Xqz��p#*H��g�ʚ��]N/�b�����q��!��5/o��a<t��^:����������d"ݛ������'���U����uÔ�?�{�c���E!2i�ᅵ�g%��Iɑƕ�\���L��4f�a7cª+�9�I�M?��g����'�&Ly/[:/%�٣��/xkB^1���슞b���ч|�EX��r�
�i9^�&ΏS�R�0���z$5{2�P-���_`�rڤ7j�_��U0^`�*d�f��41E�	lm�gaf��r��RY.����\�R����4�y	<�����F�J���"�hw�o�@���M���x�lN�x�O`�D��{0�H�l9���ǒ8�Ӯ"��~^R��,����1�[�$���y;�gF�����㳈��ΰ����&�E�.s,���Ht���(G�?�u��j���?�U���?,�v���DVqu�A��j�nm�傼� �q���_�}`���AӾOp���ܤ����ߕ����ɧ�}O�N�:M� ���%��A�h_k�KÔ�?!0-_��㿣\$���^,��,5�����"�EQ��:�%p��_�R�"��q�oX����J`���"j��c%ܴl�L�0_�����m��^��Q��KN{d_�G!�1r1����C��@���f��'ۉ0�Rӱ���Ҿ�$,�c�-�	2��ӊ<!bx��2�I��\��[� P�H!��]�3f�VȄE¯ϧ�
�H����'f�:������V-����-F{ytc.���"]�5�������9����;c�S,t�km��
V�����[�����\
Yt�GE�7��������X~�%���+���/DĆw/�4|t�����}-�Hi�7�ɵ�z � �+�N�
һw)�]߿S��4kձ"������K!�X��_�R$L�D"���
`������x�\k�,� �����^�X3�p�{n ���^��H�gM�����j���H������tl}�T�n
?��3�u��GC�s���;��}Aw>'�V�0��Pګ��P1ԫ�U��D{��:���Q�WS��Hȁ����;6��l�3Z��2C".�y�j�oք]4N�3��lL��E���1��0���������ZW�-0� ?�R�i�
��v������J/�����i���L}$��F�VP��iX��̉���l�����#!ceD����?�+���1��ԗ:��|�c�Cc|ooL4l��+��Y���f�1�Q1{,�S�����Z>�� �I]mЗB0M��W��8�&�,DJ�B����F&f,�BX��"��"�UE#�:�D���v};��X�Vb�Fa^�l� ��EN��vƪ|�E)zn��D�X^	ז��ɼ�� ��j�1����m Й�6@��c���F�3Т!���!i�;@7Jw��3]HAZ�+j�F,.�x������dL�'�c�R�;5����U�j�K�癵j�2���78.4�qW�����y.pm�]�v��	
^4��8�'�Z�_|�����n�VM@&����ѧ؄o�S�d�|������O
[����_��:�cE�����]�!���O�C���Jm@W�c�벤�@�v�K��T�3e ��#���F�AӀ״��t��ܷ�*��־�U�/q~����C���s��/�ދ�b%����9*�7F��;#kC_���+�_S|�o��}J �����������k������?����)h_.����8)*L��$E���*���o�s��w�~�����?����������ǟQ��)�(Ķ�
��b֫uQَ�"�jL�(D"�Ĉ��¢Ř����$T�%i�?�e��-3IxC���o�NG#�,�l0�1I���G�o2L��-ôU�����lN�Q�����Ɵ�'���|�͈�2���Gk�7��`�7���q����ʫim���c��7�?N�hc��0������{�]��������/�����������hֿM���1�?"��^	|�t,��UC�ᴡ�1��S��:�T�>���ܛ?m2���|d��L�Y���}����W��}d}NhL<@ ��d�xϲ�lB.�h�;=��&2���$r/�٢�w����~-��7Q�H��B/�8��g٫.�q{�U� S�[�����\��8w�����F��*'Z�f5�����<I]�/䊛����8O�g��J;�
�թ�}�)�o\�����gW)��M�Y}��J�EU�.��2tqr唐o���S1{{M%�++��EVȕ��a9+��������'�j�`����q��I�^W�R��8ҺD<�_�<9�*m�sZN����嗹�;�"��l�z"]�7���U���sC��N
'E�H2�=W�4�I�J�R;h��r��d<���?dJ91&7R�D���K��\V�g����x�ϴ.K�ܱqЍ�ߨ��'�I�~8)�_�����qT+V�p_�O�ZIU�\�,z��%��h��Վ��31��4z��r� '�x,0��d/�
d��I9G�z������|!˹�EZU��
�\b_����t��l<�N7���~�C��W@�\"ɩ�ki�r''Ö�L�\CΥ*�l!!Z���;=�j|��O���b�I,��ϞG�Y	���J�8�M�B�l�$�G�v�u�f��T���\,���o�s{G�S�	1��򕢼�N�S>�ONY���u0�|`�Uo=�����Y?����ݠ�,��s��<����0�yx��������{w�<���۾����?<��	�����j�''y�E`?uJS3�lf���3:��z��P�B�㲽������bj�y̜��\���M�j�$R���]p�X�J�r��&�B%_��*��4LD�_��f<���cF<nU���ԗ��*�{BFm$�'z�0���ȡd��$��j�x�i�����w�a��׿XV��{A�?/
�	�_����_	�ѓ�e�$fY-�YVIb�Ց�eU$fY�YVAb�Տ�e�#fY�YV9b��F�L��+
@�2�?��'���U�g�����n�}��0M���U�_����	���n�R��=O�Kȅ����J�АS0�3S�d�ӯs�''d��u����ǌq�>K�Z)�8ų7�q�k�lw����֕��m]>���ڻ�b{�Q�¤����+p��}�^���'��M�`���u,X����X���������0:}���g�9���	Y�@��Y��輨�'$��(�&p���Q����Ud���a<��?���C7��lX,�$���J#f�:��]�m���*�E�ݨ�O�%?���8��U� � O}T I�U}��ki�}�M(��R�(���I/�*ҌA%[��l|?0�@�PV� {�e���͝��ȃ��z�����Nj�6���~l�N��?��}0��\� �(�&}�z�KBH�U�}:
]�x7��K�?�Hd:�� ��cz�܃�1�
��8��n=�U��1m��n��6z�F��G�6�< u M�I�$�e�*�0�>Fi}R�E�m��v� ���j����ĸ��53;�g��v~x���af�L�{���f��v�$N��u:�ph�c�qǉӱ'Y=�8 �]v$�4�7$���pY�sA8 �8CU�'N:��z^�Eb���I�ꫪ������>�����8�|�P�g:�^|DJ������	i�����A��('qf�]�xP�"� �������
��! �����
��D3���}��Ʈ|���G~�<y�������@��D2:�뇸�c;��PF�A}@�Kr.�Yȫ�r�ZDhs�X>�3�I����&L�G�Kr�\r���Jx�a^:�r'ùaFp�����> ��׹
�F�0��&�`zI��ρw'_�ig:�{�6�Xc�.'qE	>4	�jpD�B�h��c�Ąxt�K��O}��u�W��R1$xr�ll?�|��3���k�D�tC�bMH>��>�Ľ��W�#��uA>h��y�n�?�ܫK�h����{�	f���h�+&��@6�k�\a�����f�!
��1� AY��#X%e�x�<��F2C�M������eY�8�%:*�����x��=�0t|��Q��!�Hw���j0w#��� a�2P���e�O����'O`�LZ�-wW�=H�t+	z=��"O�6��9��5����n�5��۟���1���#���:���S�xl{����_��x!���>O��O������������?�\#�7��ٿ��g���������"�GK���^~�������yݺ��Օ���H�3qE1��+�TZ��x"-+q*�����L%��D/K'�dF�h:��,���$-G�G���W����7��ǙO凟��©~������D�#���V,�o��OQX��z;�ݷw����[���������=�+b���{���E���Ӟs�o_�<t�6xm��#�Ε�� �i�F)[T��Y�a9�մ���Z��9�]��c�{���1�;�l�-<�����Ț���B�:4?#vgdԼ[TV-�u�Y=)�uL[�i� ���"�bJ��zGb�cIl��vM��	�i/&�Qv)�����8y�+�%�.$�Ƹ4�G�I�������;8��`a�{���8�iS�\h�:t��S�p����N3�;���a��R���ց�:*-ّR>D�Q��&mG:�L�#jeWB�����L�Z��Ń�LV�|eޤΝ�Zh�R0cr *}1s8��F��ԋQ��c�F"��[�%���6�~0��̒���0ho}�L�z=�Z]+ �8O[�V�m~&1��|DtKIg`&R�pb.˝�?��'��/��`-���E�֙�v ��6��f���@/�R�m��YJ�묎�3-'N�^+��v�e7��8��'rJ�.���H��O��b��jF��;���k��K��/�J��9��_%^m:��L�J-�49�v���O$��e�VT�R�ƌFn���v蟈�YS�Bl+�Ŋ@�狨%��έU�t��TO�)�
�{�E7&o�~_����Zj6�5
��,�`��A���m=�mK���Ҙ�3�.�CEVh�OJ�~N����J�[ �m8����L)ڜ8&�'�����gQ?���rL6D��W櫓*m�b0g+��!���s�R�Sf��D�J3>�M��(�ԒN�b[��w�ZV_&�v)C%�9�9)��9gT�CZ�գc=�궪�^�Pb}��~n4ϤF�\؍ߏ���ˑw"{����W�^��::��YA������K��oV"8!�m⭜{
:�&��X��{�ȇ�7�����~����/���D=H����Šߑ�l˫�W"/��X���A��I������M�ȏ�~��=���E~p/����(�Ϯe�e
X�|��̫���5������IJ��.�| =o��瘦��s�6����+X8�I"�ǒ����,B��K.�6VsXr��;��.�ޖ�'"��%p	߰�B �-1��<e!�k�!������q�n���ӳT.U:�&55V'��Z�=?R�#�R��S<�G�ZW?�RLn$�=kRp�E7�X�~{u2ʗ4]���M*�'Su�L�x��AǗHN��:<��pL-l���i1*�0-(�V��d~5�Y&��L�_8���6(��P-�\'�4mF�W���(�J��X���D]k'����蘊I�I:1<�BB�%�h�[N��F�&�Uc��\��ر:H�Aw>.���R"�D��.��`x�=���2M�r`(�;�� �FuqV.�r��f�����<w��Y����m9�b�}�U�~$�b'���E������
7\V�	n�9�g|�gw���;�m�3��5����6f���T8�B�J�ՙb[z;_��0j��)XҬr����qS���ö^oM��*?��(�v�i��Y
N���B�g���0ڭ0�f�Ryk�
W�q\C�w��0Α�,gl��&��G1ij�ZB����\3���t{p~�tbO#h�u.k�BI����`�.̎z'��Z���b{(��	_j��%���gλ"_\4d���B��抺���~o�tl��P�R���R��43�U��3��q-OT$�H�kE"V��d|��g"�e�� ��V�#s/V��N���"�ۏq�%��`eB�v	�W&���R� 8�I��B!�s��J�4��[ǽ����J�OԒGF{�g�|!6��9���̼[o
ͯ�	&��T�I�.S���j�ǃB�Xefs�ȬS�Qn�P_��P(�V�#�����x� �jXc�����b=yp�ҋ7%� !�-�(���f���D)Y�3*����Ĝ�d5f>"�T)�y g��ފ�i.:�ɎȦv}��Q.a,�n���6��Q�b��.�����oB�~�.�j䍰�����e�k��ƅ���{�-�P-{���b�=?��_&~��ckfIˉy3��ef�e��ؽAS_���"��o>}��z��S2��M��Gr/ʋ|5�*�
����c�k,��8���w}�[�nx�е�x��x���>�C3!�����'2�~>$~��6�
4��l�Q��?��Z�] ���Q��jY�IF��z�O�t|��s��V����_>_����'�7s���5��T���?�D�����܍�/�F�=��O����ޯ�$���*�wx��Ϳ���N�J�8
�B`f��,�;L���EN��T_nz��\j�T�g����/�G�!Ax�M��<[p���]}���]'��[�:$?��p�W���a#��fY����jO�6�ͺY��f�E�����9r ]s���;���� ܁���[�6�����n�#�q)�	�:y��񇽇�Azc!�G�c�ah��*.ԃ܀<z��ctM쾫�]���}�@lg�wA����#9�!�����:!I�&��93r�B��:��<x:�~e��K�پ��_����jطʄ5LC�p.i<$?�������Z �p�p�z�}�C���uiةw��;��>5��{Pf�5.M���B�:1T�Ő�XS�� `�0��ӧ�o+Mn��	�^׼�
VP���\P��f�%3hy(�V|�p������f�d\ދ�M�k!�l��T��	0Ɇ	!����b=��r8�|��@�m��� �ՍQ�`��8Ӹ70������}/�jc�}�o*���'?( �<����LM��w�k��>�afcO�C�<:=�T�=���{�kX������Fb�7?1�X	��C]��\�C܋���-�S3�'%����4���je}�Z]����8�4� <�'�}<��[̜b`�Ò�;�5U�ٺ6��F۸�R ���)
/�D����@䉮".���e��Pρn��1`I�x�K�c���!���v�U�ր��uS�5'<$/�x��ū�������':0����G���H�RFe1��Z�!I[���B
�����4�-��l2��a��$�x���(`A�nٰ��,��l��v�NG�+�6�z,���;!�µ12���vT-��!�]\���Q.��t\�D�^�����R�M\7��Z�yU�����Rdí�a�l�j�$x���G2~24��(���+��ZCa�^��*d�� �v���tv��$E�GF���jf����`u�!e�&p���z�L��JU�qDV�v���M{�6�����~����l,K�%E�p�g�M4��E�YH�BS�&���t"rN1��n�#��0Vmǜ=��i)?wḥBz�ŨR�/F�g���f�w5���p�_���3��]qvmל�O���V��d<��r��E<^��C�C�C�@$��\�dG�%WV�#�Hw����Q�Єg}�:ϰ!w�cNQd��Q��Ew��hrG�&�8��[�� v4�x�Rh�,/�oP�z�zY��++:�;�V�i��ɔL '�YZɸO�S�~���)%ݧ ��8����/��)�HdT@� �����^�p�>�����i^,7h�P�����Z��C��/ytcߴ;$@�s�.�$�r*	dY�%2���V�� R�DVM�2����B�8�d&�&�*R@��!�n��C�9qȇ��|���Bףg���Û��/<�{NnÌ��;���x�z%nƶ��7 U�
�`ʧ�j����Ǌ*ϴ˳	M��0�����1l]�.͍�6���K�*�/�_�u7{�+��X��S9�,6k�8�<v]n��BP�p�x]�@���N�:5'vT3ѺZԚ���nf2���c�ɴ�;M�y��vI�"��������v~���:D�X�6�`��Hv���)��<*t3z�U<"�P)��x��E��}���\�[�ty���Va3�x�W�ZU�H�gc}q�F�9��L���س�Ya��%Q姐"�\=
����l⥥��q��,Z�6�\��
�^jWG"��c��NÇv7+�`wA�b&��B�1R�"Ϡ̲�+��M	�ǟ#1,����Yo��W��U[�"�z}�~���|��fϕA�{[=�Rz��g&��a���0�9H(�$:ySDt�IS_��o����lt7�����q�e����b���u���t�1�s�-x�F>u���^��ōb[�l�8��5�G{�j�aہSQ��HEKE����6u�b���,���we�ic[�]��{���<<ܪ�	B!Ġ�[�b	��츓t�q���^�J�(�Xg�i�[����/��hN�X������G4�����>�o<�o�?I���Q����G�������ぅ�7G��������/�y�gm4 P��;��g��� ��)�{��n����?�����/	T�2|Z������=������#8Ѐ8��R��?�?,��`��?$@���X
�Q�4!Er*�1u��"�p�pQ�$�T��")N���&X1	�8�X:���Ի�s����{����������^�\Nk�l]d��ҫZ;�6Lw������]�7ɓ�ixԃ���I�n�w�����J��ɑ[{LBw��O��s��^6�&ӠOLp����j���d�O���l�R�)%�q���ٶ���~���v�x�p�C��:|<�?��T�<����ߓ�g��� �O����?
��������z ��W��w�?N��Q�b��ujW�|j ��W���p�������(��D���_9�s�=����(��?���D���S�'K����$��Q VuªNX���n��)`���������(��2@�������� �#F�� ������?��E�����'�?�?�v؝��W+�m��p��+����K%󟑥l^�?��O�gf?o�V�z���m��x��gY6�7�j�~z�����'�ph��(��X�5�b���*��f�N=�}�(��67�Ka�O�.�eRȍn��[�EH�.��}t�]yL�}��~#7^��|�$~d�˝��i�.��@��᷹r�a��c�7��d��ζ;�o�>��~^_z�B�zj�I�ܥ�u<~_K���Ǒ6���C���2�8>8�\���͵(�!?螊��4��@'��%s���%��P��迧QHT��?��Â���_��p�B,���O��F��'���j�������<K���*@���������+�s��(��?�&�?8����_^��\���k�?8уc9)�)O����z������F�����q�����Gó��}XO�V���Z�V�铐>�2M���Jwa���+�%�k��ôy��J�J0k%�1#-)�"i�z��S�;Q�ᖌ���۶��Oa=�׸>�-�|���� Ւ��|����F�K�x�㿵��^`�1f��ft�B&#��㼽��u�m��d��&�^�Ů7�I�r&w'�/g��*�P����KÚQ�<6$��s�fhW�����߀����?
�
`���9/6���
 ����8�?C���s��� '���!%DS��#��bN�BV�HN�L�P�(���/D4F$��HLH&$��q������!�G�_���_:�9?eʦWo�m��7�x�_��v%K5�X��k�Kæ������]����Ð�%�����@��&1�u��b|�9�h���֌�{AK�T�4�����9��ᶞri�8��'#�[���V�p���gu���/�P��8���U,��*���{����U��8�?���W���S�ףTH]�������xo����z���s�|sx����w�������oK[���K}FLK7�T���"%�i��Ǎ���yY*��6pG��/�7rt�4�� �9���
<����?
�����k�o �_0�U`��`�� �����h�*������� �^����R���/e��*�a5:'��3�4�������_���������Um�~f ���O�  �ճw \�j�.���P��% �� ���t��=S��:ņ1/�5� �~J�j��b�K��X�]W�7�KD�R�?��X����� ��꩔��zs�s�.֫y�G%���}7J�<������Uo; ����r��J�7���$��t�@n�Ӵ����P�B���v�\VDj��=�2n7�Y��-5}�@p������ZY�c�||ԴJ(��o��4ɖ>4Is�6�b|h_"�6��-%�&S�謉?���6�w;r��������2��,V�Ŏ��5����T}t^��n*�=h����������Gtx���Z��|��A����8�?M>����? �������G��)� ���������������D�QR�\�!Ɋ�1E'lDR<�J�@���0A߶AMǢ��BB|��`����Q�/�$����~7<,.���&��?�	.��PVO�]�3{7d/�m��K����}-oS�wv�;�6k�铇]K<��>�^1Jw�����K����F�!O��T|}��-��h�3ګ�7�.ɬ���V�p�S��?��A������C���w@q�����<��Q ��������h�?�Wx�����������0����_�}�_(cT������?x���V��ԯ�����ڵs\W���X�6�b���G�J��59x���i{F�L���1�gz�o�l�{��r��E0��Ǖj�'^��nD�8Tsqr�p�9
�8���9W�ڌ�m���,FCa�������F�Y�Y�/��RmW0r+��y���ʹ4烁ұd�I�j�ڳ���l[���vne������D���Ei�vە�DF���I��[��ZlS��=�pT67�P�t&	+�I��گ	��%�z�C����H]��7+�}�7���t��$�����dvVYI8ƶח�n�F��U���ߊ�F��~w\����8�?M1��Z��?4����G����!�C�7�C�7��A�}��+�9� ����[����P������K��,�����?
��/����/��V[�0�M��C������V�<������s�#�O��}�� �� *����B� �����a�wU�����b ��W��ԃ���H���9D� �������_��	��0�@T����<�? �?���?��[8~
X�?�.�������ɐ
����X�?w�����?��T ��G�<�? �?���?����A�U����B@�������ʀ��9j`�?����	����������?�D�_����_ �����~o���a�;`�����8����_�������_������G��C��"9��f�@�_ �����g�����8�?E]�`H&N�HR��R2��P�$�f��x1Ȉa�(�D!�BJ)`YN�_�Q���8�?�S�W�o��^�^#��3��K��l]#N��"P�I��-7�8)Ie�����.e��'��<$]j����ry\6�$��MgMf}�Ve��?�������-.�@j�!�R��Z��;\xg�ϝ��2�a�nf�:����0��	Dr]�����*Q���R��vwO��3�p���gu���/�P��8���U,��*���{����U��8�?���W�����S���Fmmn��֙&jkދ/���_6�ީ8�[}|��ɢp�Ҿ��nm@��3#Ζ͙�g$a���&'��0vuorP�}�y�M������,��e�m=)I�4�n=��tΆ���������_D�����?�������C��U����/����/�����6��
`����G�����_�������Sڛ!���=�v�N>?�J�\~s�����{�v7i�)��7�m�x���x�1ێ�_lQ��Ҏg��d�d�b�Xw��h�q�w�#��#����Ȍ��9����RH�)���9������� �s��)�{m7J���7����So����PJK���J�7���N����@��V=M{��<-�K�o'�e��H��.�vs����~X �-�Q��p
���Y�3M��q�dblA�8$V��ɟ���Tkv�)g�����:�Ơ�t�,j�$ӛt�s��c��z�	;�?���O��f'�﯀���4�r$����@C�	>���_��������X8$�!�����0����rt�/l�����������i�������(����}=��?���������$KC�^���U���W��>���z�	���N<�W�گ��hh�������K7e�9�]�K�tI�w��,�R~�{�~�����9?���/5߲�>uXJ�����R����͵��ֶd4�J}ɴ�׬��(孡�m��F��������D�3���.��&���j.OG�x��Hi�Rl�`)K�ĮsJѡl~�y���,/���e��Pb9�������{ʾ��r��z���N��ײ&�^�~��7�9���>�'b-u2EU�3옚��֗2H�~�.��}���6O�S��E�Z��wY��nɚ�˙B�:�+*Tʶ9'<(.�d ��ҩ'W����ڸ��H�̫J�&�!X����¹��^���y���Hr�ڲ���y�`�����?��"�'����T�X:��LDׇY>���۞���4XF����I(QABFT�����������?$�����N�_�^.C���x?��]0?$�S��8c�3_I����˕o�
��rS+���V|�����}G��c(��� ���{��?$@�����@q�������?������:�[�/���3
����SFg[�c>�Fw��`�6���/uz�=��n	6�}��ş�~����n�?�����x/���K��%�G�-��0Y��B5ZW�vM�����!$�ǎ�f,�(��"�pҪe+��g�,�eu&Q�m���g�\��.�U��fƶ=�������^�~ă�_�{W��&�e��+4nGGO�3Y�"u�' ���Ą�@�����������r�ee�a[�X�;��{�N�cQ�fG�T��E�	�ݲ�y8Vg���&�<[��r�ߏ���q՝J*>�F��ǆ��!W�N�����`�E҈��R;kzUG-��-r��{�9��u���z��G��V�~��y�ĭ���M)���Bk����2���2A$#~�]7T�Rp����x��E����x	^�����'"�����%� ��T�#�����$\o��R;t�ȡ"��u�x ���U��&���k5����˲%Q-�����{-~����~G�CR�����b�w��0�i ��_Ija��\��?k����2��m `8(7H���p������T��>�P?��؛�QYmz�]�)�����Y�k���?�Z�|�h~>�xbǗy���u1Q@>q�:J����^
�vuul��x�|^V��,/��e�
�ޡ����4u咝=^K�+u�����Yx!/}N��i�{"vý����.1���=�W{�3��M���ؽ��ON�J"\���󨿙Wp�V�=��:e�_��y���m���^:�b�����y�G�ŲQ�<���^$��9�Z�k���l����\�"3����[���h+�M^�������=�b[ʮ�M�]]���zm���P0�:9�(�yK���!k�fuH���d���-kh�1
�A��Wuǈ!ߣ�r��+�7�i�A�������T�F��)���߷�����O�!M��D��!����O
�S�B�'�B�'�����Y��S8t��߷�����vH���.g�E�����0��
�������������h�ϳe}��/!�����?�A��r��̕�;���t��*�Z�� ��?{������� +�O��>w �?���O�W�0�SJȒ��"{ ��g����_p��4��_������C�����
������~���������T���������}�\�����?RB�*B�C.��+���t ��� ��� ��������= ��o������̐�_��������!��a�?���?���?d;����RA��/�MH���߷����7� �+��!�?+�"����� ��������\�?��񟌐��[�� t}��� ��}�<�	���a������h�uL-3J�*$��ը:���(�)]g�:���fjE��P��U0�Dc4�>�Y��/�<�����!�?����}y�E��0���R�5�ŵ$-��_���ϑP�$,R���^Ϥ��F�O�VU�C~��b�V��� ��R%l���p�uZ��g���a�1:m�8�g�"Q䶣r��M��!��
i���Nb{��+un���֤�5E!�q���Ni�x[�5˼q��ae�U���1޻:��/xΐ���?�CV���Q�< �?��!��?�!K�?��cf}�y����Ï��8�l�N�w�	:�0$bŨ���$j��z��](.w�lp���x�Y�;��F�|��m���7�8��~]*���i�J�m�E]�Djy��b��OeA�$�D�|���}��"�	�3B����<j��xQ�B�E��e����/����/����Q�h���G������������:�_�m�������ؖn�����g?\�}<�*'rs	������w�!/{�XLf��۟�(�:�yx�Y��;Q��:�"S�ä85�Iq���@NE׫Ē���nS�Ķ�V^I�)�j9h�.%4�j�۶X�����ɭ��.���`$�o��s� r=��T��8�7�%���>i�Ṉ@�b��#�/��z���Wj���y���X�-�8{:�����xO���ި
թ��~�l�36j��aV����������A�<"�ΘT�݁���&aJ�vP�~���|/���S���~v���${�i�����a7�?�Ր��r��̍�/�?����^z�A��=���������C���L�?)���9����3��F���������$�Y_�{�?���O������T�'�������#NC�G �G����E.�~���_*�\������������!3��a��L�������%��#|����(�?䰼���r�c[`�SzahW��0��-{���T��V �W��z��H~�3�I����i�]j;���K���^��w����y�^�z]]\��
�%'�Ƣ��۝&��Z��`ݹݰ4��7�����9�ecr�nĺi�^}���"�[�{)�En��*�p����6;2�"?.2L�H�ñ:�5a����6��u��=Տ��TR�5�l�86ԧ��vx~kb�����jiH#�kK��=,�U�8G�ȵ^���D^�IT�[��e�Z�O�A.���g���ߋI�������[���a�?3���>B/@��E�������T �_���_���m�O��OF�\�}�<�Kq������_.���3B�����𳑋���3����j5����X�N�F�
١�H�q�m[��/5�/�?|�?�$��=��k��Zی��2�?�@������be�ɮ�P�Q����Ҍ[���^gВ�Y��,U�4��ý[ƫGu��Vil��&j%:�l�����XsL� I� �L ��Q@?b�>+��ƺhU���2���˅�K�SG[fEK*{���*j��9*�l��`T��:nS�^��K����U�.���#�r~�0�����ߘ���RA����$�Y_����������%���c	�?���
�hJ�1ZєJY�%L%
SiR�)� �\�)\30����t���J�!4�>�Y�﯌<����?!�?���?�̜ؤSV���ǜ�����x[���� �������YX)^��<��@{��y�"����N��3W�5"�(9�<��(��~Q�Oe�(.O�n=��pZLj�<�
��t �زNa���"�?�f�L��d��/��#�?��!��?�!s��0��w�<�?���G��d��XKQ�Ju]`H]��dɵ�A��m�7C=.�������HmG�-�y^�l4w�F�o6&�ǁ0��Xį5b�.�m�+5}���I�H���hw��q�czpH��"��U�Ő������M�	�3D.��+3@��A��A��,�@f�<�?�*���_��D���G�״4��8���El9	G[̹J���������� �L���2����p�(�"o3^�nDA{p\�U[Y�>���X>U�ZҖ�2iz0��֦ԩ+#�D)͆�u�������í�<�:}*�D�q
�z�:�{:W��8�7��Q�'Hlo$rQ���^ �U0��<?j�^�,9�H���W��1�RLY��vU�����}�����C��O�kͦ>�3��a��^D>3�<�Ta���zMo{��3c��XΒ�#��6�Ƕ14�H6;�f!yJ��6-z�O�BcL�-�Q����hF��Ҭ����7��F������1<����
�cd��>���i�?��sSw
��WB���ܸ�{���<*��Q�����2����]vX{��;�"���C���w{���'�s�
R�3��]��Bn�j������<�T��G�RG__v��z|�����;���'�p�,W���K����d���OޒP|Z�X��_��i����HV�����_�j;����� ��:���������������:yc6���@�>�NUu-^�Fv�i����k���s�ML'��${�|E-��^�v����[�~���������?
ڢ���x�⛷�q��~��y�����M������-�O�^�������7�v���o����E8�+<�ۣ�n�xܬ�E����+<,�������_�=�_�S��ש����+��v4%޽k�/}P�������؎YX�����,�A����`����rK茆���V�䗜�F���At�ro����H��u�k�;��&>S����cе���>���&�2�Z|پ��w��n����(,&�ω9�ܨj���⡗���'[wm�K�_�'���Y<���ﻂ��t�N[���F�� ��]���y���)��ͫ.�29���Sn����}|��6
            ������mQ � 