var metadata = {
    name: "SAR-BOF",
    description: "Situation Awareness Remote BOFs"
};

var cmd_nbtscan = ax.create_command("nbtscan", "NetBIOS name scanner (nbtscan-like)", "nbtscan 192.168.1.0/24 -v");
cmd_nbtscan.addArgString("target", true, "Destination IP address, range or CIDR (e.g. '192.168.1.1', '192.168.1.1-192.168.1.20', '192.168.1.0/24', '192.168.1.1,192.168.1.5')");
cmd_nbtscan.addArgBool("-v", "verbose");
cmd_nbtscan.addArgBool("-q", "quiet");
cmd_nbtscan.addArgBool("-e", "etc_hosts");
cmd_nbtscan.addArgBool("-l", "lmhosts");
cmd_nbtscan.addArgFlagString("-s", "separator", "Script-friendly output separator (enables script mode)", "");
cmd_nbtscan.addArgFlagString("-t", "timeout", "Response timeout in milliseconds (default 1000)", "");
cmd_nbtscan.addArgBool("-no-targets", "Disable automatic target registration");
cmd_nbtscan.setPreHook(function (id, cmdline, parsed_json, ...parsed_lines) {
    let target    = parsed_json["target"];
    let verbose   = parsed_json["-v"] ? 1 : 0;
    let quiet     = parsed_json["-q"] ? 1 : 0;
    let etc_hosts = parsed_json["-e"] ? 1 : 0;
    let lmhosts   = parsed_json["-l"] ? 1 : 0;
    let sep       = parsed_json["separator"] || "";
    let timeout_s = parsed_json["timeout"] || "";
    let no_targets = parsed_json["-no-targets"] ? 1 : 0;

    let timeout_ms = 1000;
    if (timeout_s) {
        let parsed = parseInt(timeout_s, 10);
        if (!isNaN(parsed) && parsed > 0 && parsed < 600000) {
            timeout_ms = parsed;
        }
    }

    let bof_params = ax.bof_pack("cstr,int,int,int,int,cstr,int", [ target, verbose, quiet, etc_hosts, lmhosts, sep, timeout_ms ]);
    let bof_path = ax.script_dir() + "_bin/nbtscan." + ax.arch(id) + ".o";
    let message = "NBTscan: " + target;

    if(no_targets == 1) {
        ax.execute_alias(id, cmdline, `execute bof ${bof_path} ${bof_params}`, message);
    }
    else {
        let targets_handler = function (task) {
            let blocks = task.text.trim().split('\n');
            var results = [];
            const ipRegex = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([^\s]+)\s+([^\s]+)/;
            for (const line of blocks) {

                if (results.length > 1000) {
                    ax.targets_add_list(results);
                    results.length = 0;
                }

                const match = line.trim().match(ipRegex);
                if (!match)
                    continue;

                const [, ip, netbiosName, domain] = match;

                const octets = ip.split('.');
                const isValid = octets.length === 4 &&
                    octets.every(octet => {
                        const num = parseInt(octet, 10);
                        return num >= 0 && num <= 255 && /^\d+$/.test(octet);
                    });
                if (!isValid)
                    continue;

                const obj = {
                    address: ip,
                    computer: netbiosName,
                    domain: domain,
                    alive: true,
                    info: "collected from nbtscan"
                };
                results.push(obj);
            }
            if (results.length > 0) ax.targets_add_list(results);
            return task;
        }

        ax.execute_alias(id, cmdline, `execute bof ${bof_path} ${bof_params}`, message, targets_handler);
    }
});

var group_test = ax.create_commands_group("SAR-BOF", [cmd_nbtscan]);
ax.register_commands_group(group_test, ["beacon", "gopher"], ["windows"], []);