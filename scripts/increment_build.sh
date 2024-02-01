#!/bin/bash

# Read the contents of the text file
TEXTFILE=$(cat ./source/pdxinfo)

# Extract the current build number
currentBuildNumber=$(echo $TEXTFILE | grep -o 'buildNumber=[0-9]*' | awk -F= '{print $2}')

# Increment the build number by 1
newBuildNumber=$((currentBuildNumber+1))

echo "Current build number: $currentBuildNumber"

# Update the text file with the new build number
updatedTextFile=$(echo "$TEXTFILE" | sed "s/buildNumber=$currentBuildNumber/buildNumber=$newBuildNumber/")

# Save the new build number to an environment variable (
$newBuildNumber >> "$GITHUB_ENV"

# Print the updated text file and the new build number
echo "$updatedTextFile" > ./source/pdxinfo
echo "New Build Number: $newBuildNumber"
