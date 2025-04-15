function fish_greeting
    # Top line with OS info
    set_color blue
    clear
    echo ""

    # OS Info
    set_color cyan
    echo -n "󰣇 "
    set_color normal
    echo -n (uname -s)" "(uname -r)
    echo -n " | "

    # Memory usage
    set_color green
    echo -n "󰍛 "
    set_color normal
    echo -n (free -h | grep Mem | awk '{print $3 "/" $2}')
    echo -n " | "

    # CPU load
    set_color yellow
    echo -n "󰘚 "
    set_color normal
    echo -n (uptime | cut -d ',' -f 3- | cut -d ':' -f 2)
    echo -n " | "

    # Docker containers
    set_color blue
    echo -n "󰡨 "
    set_color normal

    if command -q docker
        set running_containers (docker ps -q 2>/dev/null | wc -l)
        set total_containers (docker ps -a -q 2>/dev/null | wc -l)
        echo "$running_containers/$total_containers"
    else
        echo "not installed"
    end

    # Proxy status
    set_color magenta
    echo -n "󰖟 Proxy: "
    set_color normal

    if test -n "$http_proxy" -o -n "$HTTP_PROXY"
        set_color green
        echo -n ENABLED
    else
        set_color yellow
        echo -n disabled
    end

    # VPN status check
    echo -n " | "
    set_color magenta
    echo -n "󰖂 VPN: "

    # Test ping to internal domain silently with timeout
    if ping -c 1 -W 1 swi.srse.net >/dev/null 2>&1
        set_color green
        echo ON
    else
        set_color red
        echo OFF
    end

    # Current directory contents with exa
    echo ""
    set_color blue
    echo "📂 Current directory:"
    set_color normal

    if command -q exa
        # Use exa with icons, grid layout and git status if available
        exa --icons --grid --git -a
    else
        # Fallback to ls if exa is not installed
        ls -la
    end
end
