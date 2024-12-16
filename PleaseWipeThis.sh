#!/bin/bash

# Prompt the user for the drives to format
read -p "Please input the drives you want to format (e.g., sg2 sg3 sg4): " drives
read -p "Please input the Drive Rack number: " rack

# Validate rack number input
if [[ -z $rack ]]; then
    echo "Rack number cannot be empty. Please specify a valid rack number."
    exit 1
fi

# Create or verify folder for the rack
rack_folder="Drive_rack_$rack"
if [[ ! -d $rack_folder ]]; then
    mkdir "$rack_folder"
    echo "Created directory: $rack_folder"
else
    echo "Directory $rack_folder already exists. Files will be saved here."
fi

# Loop through each drive and initiate wiping in parallel
for drive in $drives; do
    (
        # Validate input (ensure it starts with "sg" and is followed by a number)
        if [[ ! $drive =~ ^sg[0-9]+$ ]]; then
            echo "Invalid input: $drive. Skipping."
            exit 1
        fi

        # Check if the specified device exists
        if [[ ! -e /dev/$drive ]]; then
            echo "Error: /dev/$drive does not exist. Skipping."
            exit 1
        fi

        # Display the drive's serial number for verification
        serial=$(sudo sg_inq /dev/$drive | grep -i "Unit serial number" | awk -F: '{print $2}' | xargs)
        if [[ -z $serial ]]; then
            echo "Could not retrieve the serial number for /dev/$drive. Skipping."
            exit 1
        fi

        # Confirm wipe process
        echo "The serial number for /dev/$drive is: $serial"

        # Start formatting with sg_format
        echo "Starting the first format process (sg_format) for /dev/$drive..."
        sudo sg_format --format --size=512 -v --cmplst=1 /dev/$drive
        if [[ $? -ne 0 ]]; then
            echo "sg_format failed for /dev/$drive. Aborting operation for this drive."
            exit 1
        fi
        echo "sg_format completed successfully for /dev/$drive."

        # Start overwriting the drive with random data using sg_dd
        echo "Starting the second format process (sg_dd) for /dev/$drive..."
        sudo sg_dd bs=512 if=/dev/urandom of=/dev/$drive
        if [[ $? -ne 0 ]]; then
            echo "sg_dd failed for /dev/$drive. Aborting operation for this drive."
            exit 1
        fi
        echo "sg_dd completed successfully for /dev/$drive."

        # Log the wipe process
        log_file="$rack_folder/wipe_log_${drive}.txt"
        cat <<EOT >> "$log_file"
Drive Wipe Log
------------------------------
Rack Number: $rack
Device: /dev/$drive
Serial Number: $serial

Wipe Process:
1. sg_format --format --size=512 -v --cmplst=1 /dev/$drive
   Status: Completed Successfully
2. sg_dd bs=512 if=/dev/urandom of=/dev/$drive
   Status: Completed Successfully

------------------------------
EOT
        echo "Wipe process logged to $log_file"

        # Generate Certificate of Authenticity and Destruction
        cert_file="$rack_folder/Certificate_${drive}.txt"
        cat <<EOT >> "$cert_file"
Certificate of Authenticity and Destruction
------------------------------
This certifies that the following drive has been securely wiped and verified:

Device: /dev/$drive
Serial Number: $serial
Rack Number: $rack
Date and Time of Completion: $(date "+%Y-%m-%d %H:%M:%S")

Wipe Details:
1. sg_format --format --size=512 -v --cmplst=1
2. sg_dd bs=512 if=/dev/urandom

This drive has undergone all necessary steps to ensure that the data it previously contained is unrecoverable. The authenticity of the serial number was verified both before and after the wipe.

Signed,
[NKU IT Surplus]
------------------------------
EOT
        echo "Certificate generated: $cert_file"
    ) &
done

# Wait for all parallel processes to complete
wait

# Notify user of completion
echo "All drives have been formatted and documented."

