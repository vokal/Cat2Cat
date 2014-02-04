#Make this path the path to the folder where you're keeping the Cat2Cat executable.
CAT2CAT_DIR="${PROJECT_DIR}/Pods/Cat2Cat"

echo "Cat2Cat dir: ${CAT2CAT_DIR}"

#The full path to the Cat2Cat executable, which will start the script - Note that if you rename the executable, you will need to adjust the name here.
CAT2CAT_EXECUTABLE="${CAT2CAT_DIR}/Cat2Cat"

#A pipe-seperated list of your asset catalog files, including the .xcassets extension, relative to the PROJECT_DIR.
ASSET_CATALOGS="Cat2CatExample/Icons.xcassets|Cat2CatExample/Photos.xcassets"

#The output directory for your category file, relative to the PROJECT_DIR.
CATEGORY_OUTPUT_DIRECTORY="Cat2CatExample/Categories"

#The type of category - 0 for iOS + Mac, 1 for iOS only, 2 for Mac only
CATEGORY_TYPE="2"

#The actual script!
"${CAT2CAT_EXECUTABLE}" "${PROJECT_DIR}" "${ASSET_CATALOGS}" "${CATEGORY_OUTPUT_DIRECTORY}" "${CATEGORY_TYPE}"