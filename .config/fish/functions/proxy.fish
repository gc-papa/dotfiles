function proxy
    if test (count $argv) -eq 0
        echo "Usage: proxy [on|off|trust <cert-file>]"
        return 1
    end

    echo ""
    echo "🛠 Setting internal DNS (10.255.255.254)"
    sudo rm -f /etc/resolv.conf
    echo "nameserver 10.255.255.254" | sudo tee /etc/resolv.conf >/dev/null
    echo "search swi.srse.net localdomain" | sudo tee -a /etc/resolv.conf >/dev/null

    set -l action $argv[1]
    set -l CNTLM_HTTP_PROXY "http://127.0.0.1:3128"
    set -l CNTLM_SOCKS_PROXY "socks5://127.0.0.1:1080"
    set -l CNTLM_NO_PROXY "localhost,127.0.0.1,::1,10.*,192.168.*,.swi.srse.net"
    set -l SYSTEM_CA_CERT "/etc/ssl/certs/ca-certificates.crt"
    set -l vpn_name "Sunrise AOVPN Optional"
    set -l CERT_DIR ~/.certs
    set -l NTLM_HASHED "Papa@SWI:3c5c5db3d12034413dd83d9d9832a430"

    if test "$action" = trust
        if test (count $argv) -ne 2
            echo "Usage: proxy trust <cert-file>"
            return 1
        end

        set -l CERT_FILE $argv[2]
        if test ! -f $CERT_FILE
            echo "❌ Error: The file $CERT_FILE does not exist."
            return 1
        end

        echo "🔐 Installing Sunrise Root CA from $CERT_FILE..."
        mkdir -p $CERT_DIR
        cp $CERT_FILE $CERT_DIR/sunrise-root.crt
        sudo cp $CERT_FILE /usr/local/share/ca-certificates/sunrise-root.crt
        sudo update-ca-certificates
        echo "✅ Sunrise Root CA installed successfully!"
        return 0
    end

    if test "$action" = on
        echo "🔄 Connecting to VPN: $vpn_name..."
        powershell.exe -Command "rasdial '$vpn_name'"
        echo "✅ VPN Connected: $vpn_name"

        if not pgrep -x cntlm >/dev/null
            echo "⚠️ CNTLM is not running. Starting CNTLM..."
            sudo /usr/bin/systemctl start cntlm
        else
            echo "✅ CNTLM is already running."
        end

        mkdir -p $CERT_DIR

        if command -q composer
            echo "🔐 Extracting certificates from proxy..."
            echo | openssl s_client -showcerts -connect repo.packagist.org:443 -proxy 127.0.0.1:3128 2>/dev/null | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' >$CERT_DIR/packagist.crt
            echo | openssl s_client -showcerts -connect api.github.com:443 -proxy 127.0.0.1:3128 2>/dev/null | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' >$CERT_DIR/github.crt

            if test -f $CERT_DIR/sunrise-root.crt
                echo "➕ Adding Sunrise Root CA to bundle"
                cat ~/cacert.pem $CERT_DIR/*.crt >$CERT_DIR/proxy-bundle.pem
            else
                echo "⚠️ Sunrise Root CA missing, creating bundle without root"
                cat ~/cacert.pem $CERT_DIR/*.crt >$CERT_DIR/proxy-bundle.pem
            end

            composer config -g cafile $CERT_DIR/proxy-bundle.pem
            echo "✅ Composer cafile set to $CERT_DIR/proxy-bundle.pem"
        end

        echo "🔧 Setting environment proxy variables..."
        set -gx NODE_EXTRA_CA_CERTS $CERT_DIR/proxy-bundle.pem
        set -gx NODE_OPTIONS --use-openssl-ca
        set -gx http_proxy $CNTLM_HTTP_PROXY
        set -gx https_proxy $CNTLM_HTTP_PROXY
        set -gx no_proxy $CNTLM_NO_PROXY
        set -gx all_proxy $CNTLM_SOCKS_PROXY
        set -gx NTLM_CREDENTIALS $NTLM_HASHED

        # APT
        echo "Acquire::http::Proxy \"$CNTLM_HTTP_PROXY\";" | sudo /usr/bin/tee /etc/apt/apt.conf.d/80proxy
        echo "Acquire::https::Proxy \"$CNTLM_HTTP_PROXY\";" | sudo /usr/bin/tee -a /etc/apt/apt.conf.d/80proxy
        echo "Acquire::https::Verify-Peer \"false\";" | sudo /usr/bin/tee /etc/apt/apt.conf.d/99disable-ssl-verify
        echo "Acquire::https::Verify-Host \"false\";" | sudo /usr/bin/tee -a /etc/apt/apt.conf.d/99disable-ssl-verify

        # NPM
        npm config set proxy $CNTLM_HTTP_PROXY
        npm config set https-proxy $CNTLM_HTTP_PROXY
        npm config set cafile $CERT_DIR/proxy-bundle.pem
        npm config set strict-ssl false
        npm config set registry "https://registry.npmjs.org/"

        # Git
        git config --global http.proxy $CNTLM_HTTP_PROXY
        git config --global https.proxy $CNTLM_HTTP_PROXY
        git config --global http.sslVerify false

        echo "✅ Proxy is now ON via CNTLM and VPN is connected."

    else if test "$action" = off
        echo "❌ Disabling CNTLM proxy settings and disconnecting VPN..."

        set -e http_proxy https_proxy HTTPS_PROXY no_proxy all_proxy ALL_PROXY NODE_OPTIONS NODE_EXTRA_CA_CERTS

        sudo rm -f /etc/apt/apt.conf.d/80proxy
        sudo rm -f /etc/apt/apt.conf.d/99disable-ssl-verify

        npm config delete proxy
        npm config delete https-proxy
        npm config delete cafile
        npm config delete strict-ssl
        npm config delete registry

        git config --global --unset http.proxy
        git config --global --unset https.proxy
        git config --global http.sslVerify true


        echo "🌐  Imposto DNS esterno (1.1.1.1 / 8.8.8.8)"
        sudo rm -f /etc/resolv.conf
        echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf >/dev/null
        echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf >/dev/null

        if pgrep -x cntlm >/dev/null
            echo "Stopping CNTLM..."
            sudo /usr/bin/systemctl stop cntlm
        end

        echo "❌ Disconnecting VPN: $vpn_name..."
        powershell.exe -Command "rasdial '$vpn_name' /disconnect"

        echo "✅ Proxy is now OFF and VPN is disconnected."
    else
        echo "❌ Error: Invalid argument '$action'"
        return 1
    end
end
