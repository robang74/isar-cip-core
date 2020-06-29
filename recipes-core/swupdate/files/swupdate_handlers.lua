--[[

    Round-robin Image and File Handler.

    Copyright (C) 2019, Siemens AG

    Author: Christian Storm <christian.storm@siemens.com>

    SPDX-License-Identifier: GPL-2.0-or-later

    An `sw-description` file using these handlers may look like:
        software =
        {
            version = "0.1.0";
            images: ({
                filename = "rootfs.ext4";
                device = "sda4,sda5";
                type = "roundrobin";
                compressed = false;
            });
            files: ({
                filename = "vmlinuz";
                path = "vmlinuz";
                type = "kernelfile";
                device = "sda2,sda3";
                filesystem = "vfat";
            },
            {
                filename = "initrd.img";
                path = "initrd.img";
                type = "kernelfile";
                device = "sda2,sda3";
                filesystem = "vfat";
            });
        }

    The semantics is as follows: Instead of having a fixed target device,
    the 'roundrobin' image handler calculates the target device by parsing
    /proc/cmdline, matching the root=<device> kernel parameter against its
    'device' attribute's list of devices, and sets the actual target
    device to the next 'device' attribute list entry in a round-robin
    manner. The actual flashing is done via chain-calling another handler,
    defaulting to the "raw" handler.

    The 'kernelfile' file handler reuses the 'roundrobin' handler's target
    device calculation by reading the actual target device from the same
    index into its 'device' attribute's list of devices. The actual placing
    of files into this partition is done via chain-calling another handler,
    defaulting to the "rawfile" handler.

    In the above example, if /dev/sda4 is currently booted according to
    /proc/cmdline, /dev/sda5 will be flashed and the vmlinuz and initrd.img
    files will be placed on /dev/sda3. If /dev/sda5 is booted, /dev/sda4
    will be flashed and the vmlinuz and initrd.img files are placed on
    /dev/sda2.
    In addition to "classical" device nodes as in this example, partition
    UUIDs as reported, e.g., by `blkid -s PARTUUID` are also supported.
    UBI volumes are supported as well by specifying a CSV list of
    ubi<number>:<label> items.

    Configuration is done via an INI-style configuration file located at
    /etc/swupdate.handler.ini or via compiled-in configuration (by
    embedding the Lua handler script into the SWUpdate binary via using
    CONFIG_EMBEDDED_LUA_HANDLER), the latter having precedence over the
    former. See the example configuration below.
    If uncommenting this example block, it will take precedence over any
    /etc/swupdate.handler.ini configuration file.

    The chain-called handlers can either be specified in the configuration,
    i.e., a static run-time setting, or via the 'chainhandler' property of
    an 'image' or 'file' section in the sw-description, with the latter
    taking precedence over the former, e.g.,
        ...
        images: ({
                filename = "rootfs.ext4";
                device = "sda4,sda5";
                type = "roundrobin";
                properties: {
                    chainhandler = "myraw";
                };
            });
        ...
    Such a sw-description fragment will chain-call the imaginary "myraw"
    handler regardless of what's been configured in the compiled-in or the
    configuration file.
    When chain-calling the "rdiff_image" handler, its 'rdiffbase' property
    is subject to round-robin as well, i.e., the 'rdiffbase' property is
    expected to be a CSV list as for the 'device' property, and the actual
    'rdiffbase' property value is calculated following the same round-robin
    calculation mechanism stated above prior to chain-calling the actual
    "rdiff_image" handler, e.g.,
        images: ({
                filename = "rootfs.ext4";
                type = "roundrobin";
                device = "sda4,sda5";
                properties: {
                    chainhandler = "rdiff_image";
                    rdiffbase="sda1,sda2";
                };
            });
    will set the 'rdiffbase' property to /dev/sda2 (/dev/sda1) if /dev/sda4
    (/dev/sda5) is the currently booted root file system according to
    /proc/cmdline parsing.

]]


local configuration = [[
[bootloader]
# Required: bootloader name, uboot and ebg currently supported.
name=ebg
# Required: bootloader-specific key-value pairs, e.g., for ebg:
kernelname=linux.signed.efi
# For relying on FAT labels, prefix bootlabels with 'L:', e.g., L:BOOT0.
# For using custom labels, i.e., relying on the contents of an EFILABEL
# file within the partition, prefix it with 'C:', e.g., C:BOOT0.
bootlabel={ "C:BOOT0:", "C:BOOT1:" }

# Optional: handler to chain-call for the 'roundrobin' handler,
# defaulting to 'raw'
[roundrobin]
chainhandler=raw

# Optional: handler to chain-call for the 'kernelfile' handler,
# defaulting to 'rawfile'
[kernelfile]
chainhandler=rawfile
]]

-- Default configuration file, tried if no compiled-in config is available.
local cfgfile = "/etc/swupdate.handler.ini"

-- Table holding the configuration.
local config = {}

-- Mandatory configuration [section] and keys
local BOOTLOADERCFG = {
    ebg   = {
        bootloader = {"name", "bootlabel", "kernelname"}
    },
    -- TODO fill with mandatory U-Boot configuration
    uboot = {
        bootloader = {"name"}
    }
}

-- enum-alikes to make code more readable
local BOOTLOADER = { EBG = "ebg", UBOOT = "uboot" }
local PARTTYPE   = { UUID = 1, PLAIN = 2, UBI = 3 }

-- Target table describing the target device the image is to be/has been flashed to.
local rrtarget = {
    size = function(self)
        local _size = 0
        for index in pairs(self) do _size = _size + 1 end
        return _size - 1
    end
}

-- Helper function parsing CSV fields of a struct img_type such as
-- the "device" fields or the "rdiffbase" property.
local get_device_list = function(device_node_csv_list)
    local device_list = {}
    for item in device_node_csv_list:gmatch("([^,]+)") do
        local device_node = item:gsub("/dev/", "")
        device_list[#device_list+1] = device_node
        device_list[device_node] = #device_list
    end
    return device_list
end

-- Helper function to determine device node location.
local get_device_path = function(device_node)
    if device_node:match("ubi%d+:%S+") then
        return 0, device_node, PARTTYPE.UBI
    end
    local device_path = string.format("/dev/disk/by-partuuid/%s", device_node)
    local file = io.open(device_path, "rb" )
    if file then
        file:close()
        return 0, device_path, PARTTYPE.UUID
    end
    device_path = string.format("/dev/%s", device_node)
    file = io.open(device_path, "rb" )
    if file then
        file:close()
        return 0, device_path, PARTTYPE.PLAIN
    end
    swupdate.error(string.format("Cannot access target device node /dev/{,disk/by-partuuid}/%s", device_node))
    return 1, nil, nil
end

-- Helper function parsing the INI-style configuration.
local get_config = function()
    -- Return configuration right away if it's already parsed.
    if config ~= nil and #config > 0 then
        return config
    end

    -- Get configuration INI-style string.
    if not configuration then
        swupdate.trace(string.format("No compiled-in config found, trying %s", cfgfile))
        local file = io.open(cfgfile, "r" )
        if not file then
            swupdate.error(string.format("Cannot open config file %s", cfgfile))
            return nil
        end
        configuration = file:read("*a")
        file:close()
    end
    if configuration:sub(-1) ~= "\n" then
        configuration=configuration.."\n"
    end

    -- Parse INI-style contents into config table.
    local sec, key, value
    for line in configuration:gmatch("(.-)\n") do
        if line:match("^%[([%w%p]+)%][%s]*") then
            sec = line:match("^%[([%w%p]+)%][%s]*")
            config[sec] = {}
        elseif sec then
            key, value = line:match("^([%w%p]-)=(.*)$")
            if key and value then
                if tonumber(value)  then value = tonumber(value) end
                if value == "true"  then value = true            end
                if value == "false" then value = false           end
                if value:sub(1,1) == "{" then
                    local _value = {}
                    for _key, _ in value:gmatch("\"(%S+)\"") do
                        table.insert(_value, _key)
                    end
                    value = _value
                end
                config[sec][key] = value
            else
                if not line:match("^$") and not line:match("^#") then
                    swupdate.warn(string.format("Syntax error, skipping '%s'", line))
                end
            end
        else
            swupdate.error(string.format("Syntax error. no [section] encountered."))
            return nil
        end
    end

    -- Check config table for mandatory key existence.
    if config["bootloader"] == nil or config["bootloader"]["name"] == nil then
        swupdate.error(string.format("Syntax error. no [bootloader] encountered or name= missing therein."))
        return nil
    end
    local bcfg = BOOTLOADERCFG[config.bootloader.name]
    if not bcfg then
        swupdate.error(string.format("Bootloader unsupported, name=uboot|ebg missing in [bootloader]?."))
        return nil
    end
    for sec, _ in pairs(bcfg) do
        for _, key in pairs(bcfg[sec]) do
            if config[sec] == nil or config[sec][key] == nil then
                swupdate.error(string.format("Mandatory config key %s= in [%s] not found.", key, sec))
            end
        end
    end

    return config
end

-- Round-robin image handler for updating the root partition.
function handler_roundrobin(image)
    -- Read configuration.
    if not get_config() then
        swupdate.error("Cannot read configuration.")
        return 1
    end

    -- Check if we can chain-call the handler.
    local chained_handler = "raw"
    if image.properties ~= nil and image.properties["chainhandler"] ~= nil then
        chained_handler = image.properties["chainhandler"]
    elseif config["roundrobin"] ~= nil and config["roundrobin"]["chainhandler"] ~= nil then
        chained_handler = config["roundrobin"]["chainhandler"]
    end
    if not swupdate.handler[chained_handler] then
        swupdate.error(string.format("'%s' handler not available in SWUpdate distribution.", chained_handler))
        return 1
    end

    -- Get device list for round-robin.
    local devices = get_device_list(image.device)
    if #devices < 2 then
        swupdate.error("Specify at least 2 devices in the device= property for 'roundrobin'.")
        return 1
    end

    -- Check that rrtarget is unset, else a reboot may be pending.
    if rrtarget:size() > 0 then
        swupdate.warn("The 'roundrobin' handler has been run. Is a reboot pending?")
    end

    -- Determine current root device.
    local file = io.open("/proc/cmdline", "r")
    if not file then
        swupdate.error("Cannot open /proc/cmdline.")
        return 1
    end
    local cmdline = file:read("*l")
    file:close()

    local rootparam, rootdevice
    for item in cmdline:gmatch("%S+") do
        rootparam, rootdevice = item:match("(root=[%u=]*[/dev/]*(%S+))")
        if rootparam and rootdevice then break end
    end
    if not rootdevice then
        -- Use findmnt to get the rootdev
      rootdevice = io.popen('findmnt -nl / -o PARTUUID'):read("*l")
      if not rootdevice then
        swupdate.error("Cannot determine current root device.")
        return 1
      end
    end
    swupdate.info(string.format("Current root device is: %s", rootdevice))

    if not devices[rootdevice] then
        swupdate.error(string.format("Current root device '%s' is not in round-robin root devices list: %s", rootdevice, image.device:gsub("/dev/", "")))
        return 1
    end

    -- Perform round-robin calculation for target.
    local err
    rrtarget.index = devices[rootdevice] % #devices + 1
    rrtarget.device_node = devices[rrtarget.index]
    err, rrtarget.device_path, rrtarget.parttype = get_device_path(devices[rrtarget.index])
    if err ~= 0 then
        return 1
    end
    swupdate.info(string.format("Using '%s' as 'roundrobin' target via '%s' handler.", rrtarget.device_path, chained_handler))

    -- If the chain-called handler is rdiff_image, adapt the rdiffbase property
    if chained_handler == "rdiff_image" then
        if image.properties ~= nil and image.properties["rdiffbase"] ~= nil then
            local rdiffbase_devices = get_device_list(image.properties["rdiffbase"])
            if #rdiffbase_devices < 2 then
                swupdate.error("Specify at least 2 devices in the rdiffbase= property for 'roundrobin'.")
                return 1
            end
            err, image.propierties["rdiffbase"], _ = get_device_path(rdiffbase_devices[rrtarget.index])
            if err ~= 0 then
                return 1
            end
            swupdate.info(string.format("Using device %s as rdiffbase.", image.properties["rdiffbase"]))
        else
            swupdate.error("Property 'rdiffbase' is missing in sw-description.")
            return 1
        end
    end

    -- Actually flash the partition.
    local msg
    image.type = chained_handler
    image.device = rrtarget.device_path
    err, msg = swupdate.call_handler(chained_handler, image)
    if err ~= 0 then
        swupdate.error(string.format("Error chain-calling '%s' handler: %s", chained_handler, (msg or "")))
        return 1
    end

    if config.bootloader.name == BOOTLOADER.EBG then
      if rootparam then
        local value = cmdline:gsub(
            rootparam:gsub("%-", "%%-"),
            string.format("root=%s%s",
                (rrtarget.parttype == PARTTYPE.PLAIN and "") or (rrtarget.parttype == PARTTYPE.UBI and "") or "PARTUUID=",
                 rrtarget.parttype == PARTTYPE.PLAIN and rrtarget.device_path or devices[rrtarget.index]
            )
        )
        swupdate.info(string.format("Setting EFI Bootguard environment: kernelparams=%s", value))
        swupdate.set_bootenv("kernelparams", value)
      end
    elseif config.bootloader.name == BOOTLOADER.UBOOT then
        -- Update U-Boot environment.
        swupdate.info(string.format("Setting U-Boot environment"))
        local value = rrtarget.index
        swupdate.set_bootenv("swupdpart", value);
    end

    return 0
end

-- File handler for updating kernel files.
function handler_kernelfile(image)
    -- Check if we can chain-call the handler.
    local chained_handler = "rawfile"
    if image.properties ~= nil and image.properties["chainhandler"] ~= nil then
        chained_handler = image.properties["chainhandler"]
    elseif config["kernelfile"] ~= nil and config["kernelfile"]["chainhandler"] ~= nil then
        chained_handler = config["kernelfile"]["chainhandler"]
    end
    if not swupdate.handler[chained_handler] then
        swupdate.error(string.format("'%s' handler not available in SWUpdate distribution."), chained_handler)
        return 1
    end

    -- Check that rrtarget is set, else the 'roundrobin' handler hasn't been run.
    if rrtarget:size() == 0 then
        swupdate.error("The 'roundrobin' handler hasn't been run.")
        swupdate.info("Place 'roundrobin' above 'kernelfile' in sw-description.")
        return 1
    end

    -- Get device list for round-robin.
    local devices = get_device_list(image.device)
    if #devices < 2 then
        swupdate.error("Specify at least 2 devices in the device= property for 'kernelfile'.")
        return 1
    end
    if rrtarget.index > #devices then
        swupdate.error("Cannot map kernel partition to root partition.")
        return 1
    end

    -- Perform round-robin indexing for target.
    local err
    err, image.device, _ = get_device_path(devices[rrtarget.index])
    if err ~= 0 then
        return 1
    end
    swupdate.info(string.format("Using '%s' as 'kernelfile' target via '%s' handler.", image.device, chained_handler))

    -- Actually copy the 'kernelfile' files.
    local msg
    image.type = chained_handler
    err, msg = swupdate.call_handler(chained_handler, image)
    if err ~= 0 then
        swupdate.error(string.format("Error chain-calling '%s' handler: %s", chained_handler, (msg or "")))
        return 1
    end

    if config.bootloader.name == BOOTLOADER.EBG then
        -- Update EFI Boot Guard environment: kernelfile
        local value = string.format("%s%s", config.bootloader.bootlabel[rrtarget.index], config.bootloader.kernelname)
        swupdate.info(string.format("Setting EFI Bootguard environment: kernelfile=%s", value))
        swupdate.set_bootenv("kernelfile", value)
    elseif config.bootloader.name == BOOTLOADER.UBOOT then
        -- Update U-Boot environment.
        swupdate.info(string.format("Setting U-Boot environment"))
        -- TODO
    end

    return 0
end

swupdate.register_handler("roundrobin", handler_roundrobin, swupdate.HANDLER_MASK.IMAGE_HANDLER)
swupdate.register_handler("kernelfile", handler_kernelfile, swupdate.HANDLER_MASK.FILE_HANDLER)
