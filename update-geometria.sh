# Check git satus and make sure we don't modify the working tree with update changes by mistake
if [[ "${@#-force}" = "$@" && -n $(git status --porcelain) ]]; then
    echo "Current git repo's state is not committed! Please commit and try again."
    exit 1
fi

# Variables

GEOMETRIA_TARGET_PATH_PARENT=Sources/GeometriaAppLib
GEOMETRIA_TARGET_PATH=$GEOMETRIA_TARGET_PATH_PARENT/Geometria

if [[ -z $GEOMETRIA_VERSION_TAG ]]; then
    GEOMETRIA_VERSION_TAG=main
fi

echo "Source tag/branch: $GEOMETRIA_VERSION_TAG"
echo "Target path: $GEOMETRIA_TARGET_PATH"

# Pre-clone checks

if [[ -d $GEOMETRIA_TARGET_PATH ]]; then
    true
else
    mkdir -p $GEOMETRIA_TARGET_PATH
fi

# Cloning

echo "Creating temporary path folder ./temp..."

if [[ -d "temp" ]]; then
    rm -rf temp
fi

mkdir temp

cd temp
git clone https://github.com/LuizZak/Geometria.git --depth=1 --branch=$GEOMETRIA_VERSION_TAG

# Copy all Geometria files over
echo "Copying over Geometria files..."

GEOMETRIA_SOURCE_PATH=Geometria/Sources/Geometria

if [[ -d $GEOMETRIA_SOURCE_PATH ]]; then
    rm -R ../$GEOMETRIA_TARGET_PATH
    mkdir ../$GEOMETRIA_TARGET_PATH
    cp -R $GEOMETRIA_SOURCE_PATH* ../$GEOMETRIA_TARGET_PATH_PARENT
else
    echo "Error while copying over Geometria files: Could not locate source files path $GEOMETRIA_SOURCE_PATH."
    exit 1
fi

cd ..

rm -rf temp

echo "Success!"

if [[ -n $(git status --porcelain) ]]; then
    echo "New unstaged changes:"
    git status --porcelain
fi
