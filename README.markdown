# IP Changer Script

This Bash script, named `ip-changer.sh`, is designed to enhance online anonymity by routing traffic through the Tor network and periodically changing the public IP address. It is particularly useful for users seeking to protect their privacy on systems running supported Linux distributions.

## Features
- **Tor Integration**: Installs and configures Tor to route traffic through its network, providing a new IP address via exit nodes.
- **IP Rotation**: Allows users to set a time interval and number of IP changes, with an option for infinite changes at random intervals (30-60 seconds).
- **Transparent Proxy**: Sets up Tor as a transparent proxy to route all system traffic (including browser traffic) through Tor, enhancing anonymity.
- **Easy Installation**: Automatically installs required packages (`curl` and `tor`) based on the detected Linux distribution (Ubuntu, Debian, Fedora, CentOS, Red Hat, Amazon Linux, or Arch).
- **User-Friendly**: Includes a clear interface with ASCII art and colored prompts for a better user experience.

## Usage
1. **Run as Root**: Execute the script with `sudo ./ip-changer.sh` to ensure proper permissions.
2. **Configure Interval**: Enter the time interval in seconds (type 0 for infinite changes) when prompted.
3. **Set Change Count**: Specify the number of times to change the IP (type 0 for infinite changes).
4. **Monitor Output**: The script displays the new IP address after each change.

## Browser Anonymity
- For full browser anonymity, use the Tor Browser (downloadable from https://www.torproject.org).
- Alternatively, configure your browser to use `127.0.0.1:9050` as a SOCKS5 proxy.
- Disable WebRTC leaks (e.g., in Firefox: `about:config`, set `media.peerconnection.enabled` to `false`) to prevent IP exposure.

## Requirements
- A supported Linux distribution (Ubuntu, Debian, Fedora, CentOS, Red Hat, Amazon Linux, or Arch).
- Root privileges to install packages and configure system settings.
- Internet connectivity to download Tor and related dependencies.

## Installation
1. Clone this repository or download the `ip-changer.sh` file.
2. Make the script executable:
   ```bash
   chmod +x ip-changer.sh
   ```
3. Run the script with sudo:
   ```bash
   sudo ./ip-changer.sh
   ```

## Notes
- The script uses `eth0` as the network interface for iptables rules. Adjust to your interface (e.g., `wlan0`) if necessary.
- Persistent iptables rules require additional setup (e.g., `iptables-persistent` on Debian).
- IP changes depend on Tor network availability and exit node diversity; rapid changes may not always result in a new IP.

## License
This script is provided under the MIT License. See the LICENSE file for details.

## Last Updated
July 22, 2025