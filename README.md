
# PleaseWipeThis Script

This Bash script securely wipes and formats drives using the `sg_format` and `sg_dd` utilities, ensuring all data on the drives is unrecoverable. It also generates logs and Certificates of Authenticity for each processed drive.


## Dependencies and Prereqs

The script requires the following dependencies to function correctly:

1. **Bash**:

- Ensure the script is executed in a Bash shell. Most Linux distributions have Bash 
pre-installed.

2. **Required Utilities**:
   - `sg_inq`: Used to retrieve the serial number of the drive.
   - `sg_format`: Performs low-level formatting of the drive.
   - `sg_dd`: Writes random data to the drive for secure erasure.

3. **sg3-utils Package**:

- Provides the necessary tools like sg_inq, sg_format, and sg_dd.
- Install via your package manager
```bash
    sudo apt-get install sg3-utils

```
- For Red Hat-based distributions:

 ```bash
    sudo yum install sg3_utils
```

4. **coreutils Package**:

- Used for commands like mkdir, cat, and xargs.
- Pre-installed in most Linux distributions.


5. **Administrative Privileges**:

The script requires sudo to access and format drives. Ensure the user running the script has sudo privileges.


6. **Drive Naming**:
   - Drives must be named in the `sg` format (e.g., `sg2`, `sg3`).

7. **Permissions**:
   - Ensure the script has execute permissions: `chmod +x script.sh`.
## Usage/Examples


1. **Run the Script**:
   ```bash
   ./pleasewipethis.sh
    ```

2. **Provide Input**:

- Drives: Enter the drive names separated by spaces (e.g., sg2 sg3 sg4).
- Rack Number: Enter the rack number to organize and save logs/certificates in a dedicated folder.

3. **Example**:
   ```bash
    Please input the drives you want to format (e.g., sg2 sg3 sg4): sg2 sg3
    Please input the Drive Rack number: 1

    ```




## Features

- **Drive Validation**:

    - Ensures the drive names follow the correct sg format.
    - Verifies the existence of specified drives under /dev.

- **Serial Number Verification**:
    - Retrieves and displays the serial number for each drive to confirm the correct device.

- **Formatting Processes**:

    1. **Low-Level Format**:
    -  Uses sg_format to format the drive.
    2. **Secure Data Overwrite**:
    -  Uses sg_dd to overwrite the drive with random data.

- **Parallel Processing**:

    - Processes multiple drives concurrently.

- **Logging**:
    - Creates detailed logs in a folder named after the specified rack (e.g., Drive_rack_1).

- **Certificate Generation**:

    - Generates a Certificate of Authenticity and Destruction for each drive, confirming the secure wipe.

## Output

1. **Logs**:

- Each drive generates a log file (wipe_log_<drive>.txt) in the rack folder, detailing the wipe process.

2. **Certificates**:

- A certificate file (Certificate_<drive>.txt) is created for each drive, documenting the wipe process and confirming data destruction.

### Example Outputs
Folder structure after running the script:

        Drive_rack_1/
        ├── wipe_log_sg2.txt
        ├── wipe_log_sg3.txt
        ├── Certificate_sg2.txt
        ├── Certificate_sg3.txt

**Sample Log (wipe_log_sg2.txt)**:

        Drive Wipe Log
        ------------------------------
        Rack Number: 1
        Device: /dev/sg2
        Serial Number: XYZ123

        Wipe Process:
        1. sg_format --format --size=512 -v --cmplst=1 /dev/sg2
        Status: Completed Successfully
        2. sg_dd bs=512 if=/dev/urandom of=/dev/sg2
        Status: Completed Successfully

        ------------------------------

**Sample Certificate (Certificate_sg2.txt)**

        Certificate of Authenticity and Destruction
        ------------------------------
        This certifies that the following drive has been securely wiped and verified:

        Device: /dev/sg2
        Serial Number: XYZ123
        Rack Number: 1
        Date and Time of Completion: 2024-12-18 12:34:56

        Wipe Details:
        1. sg_format --format --size=512 -v --cmplst=1
        2. sg_dd bs=512 if=/dev/urandom

        This drive has undergone all necessary steps to ensure that the data it previously contained is unrecoverable. The authenticity of the serial number was verified both before and after the wipe.

        Signed,
        [NKU IT Surplus]
        ------------------------------



