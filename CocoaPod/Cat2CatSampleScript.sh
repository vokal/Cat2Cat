# Adjust the path to the Cat2Cat executable as needed.
# Adjust the --base-path parameter as needed--the --asset-catalog and --output-dir parameters are relative to this parameter.
# Use the --asset-catalog parameter to add each asset catalog (relative to the base path).
# Use the --output-dir parameter to set the output directory for your category/extension file (relative to the base path).
# Use the --mac and/or --ios flags to generate NSImage and/or UIImage categories/extensions.
# Use the --objc and/or --swift flags to generate Objective-C categories and/or Swift class extensions.
"${PROJECT_DIR}/Pods/Cat2Cat" \
    --base-path="${PROJECT_DIR}" \
    --asset-catalog="Cat2CatExample/Icons.xcassets" \
    --asset-catalog="Cat2CatExample/Photos.xcassets" \
    --output-dir="Cat2CatExample/Categories" \
    --mac --objc