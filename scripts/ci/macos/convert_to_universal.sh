#!/usr/bin/env bash
UNAME=$(uname)
if [ "${1}" = "" ]; then
PREFIX="."
else
PREFIX=${1}
fi

echo -e "${0} was runned on ${UNAME}\n\n"
if [ "$(uname)" = "Darwin" ]; then
echo "Cache location $(brew --cache)"
LIPO_PREFIX=""
ls $PREFIX
else
LIPO_PREFIX="x86_64-apple-darwin-"
echo "This system is not MacOS"
fi
####
makeUniversal() {    
mimetype=$(file -b --mime-type $1)
noPrefixPath="${1#${PREFIX}/arm64}"
echo -e "==> Processing ${1}\n   as ${mimetype}"
if [ "${mimetype}" = "application/x-mach-binary" ]; then
    ${LIPO_PREFIX}lipo "${PREFIX}/arm64/${noPrefixPath}" "${PREFIX}/x86_64/${noPrefixPath}" -create -output "${PREFIX}/universal/${noPrefixPath}"
    echo "==> Mach-O binary merged: ${noPrefixPath}"
elif [ "$(file -b ${i})" == "current ar archive" ]; then
    ${LIPO_PREFIX}lipo "${PREFIX}/arm64/${noPrefixPath}" "${PREFIX}/x86_64/${noPrefixPath}" -create -output "${PREFIX}/universal/${noPrefixPath}"
    echo "==> AR Archive merged: ${noPrefixPath}"
else
    cp -v "${1}" "${PREFIX}/universal/${noPrefixPath}" || echo "File $(file -b ${i}) FAILED"
fi
}

####

FILES=$(find ${PREFIX}/arm64 -type f)
DIRS=$(find ${PREFIX}/arm64 -type d)

echo "Creating directory structure"
for i in $DIRS
do
universal_dir=$(echo "${i}" | sed "s/arm64/universal/g")
#echo "DIR: ${i} -> ${universal_dir}"
mkdir -vp "${universal_dir}"
done

for i in $FILES
do 
#echo -e "${i}\n"
makeUniversal $i
done

