import Foundation

struct PartitionInfo: Identifiable, Hashable {
    let id: Int
    let number: Int?
    let start: UInt64
    let length: UInt64
    let hint: String
    let name: String
    let size: UInt64
    let synthesized: Bool
    let filesystem: String
    let volumeName: String

    var displayType: String {
        if let mapped = Self.guidNames[hint.uppercased()] { return mapped }
        if hint.hasPrefix("0x"),
           let byte = UInt8(hint.dropFirst(2), radix: 16),
           let mapped = Self.mbrNames[byte] { return mapped }
        return hint
    }

    var subtitle: String {
        var parts: [String] = []
        if !filesystem.isEmpty {
            var fs = filesystem
            if !volumeName.isEmpty { fs += " \u{2014} \(volumeName)" }
            parts.append(fs)
        }
        if !name.isEmpty && name != volumeName { parts.append(name) }
        return parts.joined(separator: " | ")
    }

    var formattedSize: String {
        if size >= 1_073_741_824 {
            return String(format: "%.1f GB", Double(size) / 1_073_741_824)
        }
        if size >= 1_048_576 {
            return String(format: "%.1f MB", Double(size) / 1_048_576)
        }
        return String(format: "%.1f KB", Double(size) / 1024)
    }

    // MARK: - GPT Partition Type GUIDs

    static let guidNames: [String: String] = [
        // General
        "C12A7328-F81F-11D2-BA4B-00A0C93EC93B": "EFI System",
        "024DEE41-33E7-11D3-9D69-0008C781F39F": "MBR Partition Scheme",
        "21686148-6449-6E6F-744E-656564454649": "BIOS Boot",

        // Windows / Microsoft
        "EBD0A0A2-B9E5-4433-87C0-68B6B72699C7": "Basic Data (FAT/NTFS/exFAT)",
        "E3C9E316-0B5C-4DB8-817D-F92DF00215AE": "Microsoft Reserved",
        "5808C8AA-7E8F-42E0-85D2-E1E90434CFB3": "LDM Metadata",
        "AF9B60A0-1431-4F62-BC68-3311714A69AD": "LDM Data",
        "DE94BBA4-06D1-4D40-A16A-BFD50179D6AC": "Windows Recovery",
        "E75CAF8F-F680-4CEF-AA6E-40C6A8B02EC8": "Storage Spaces",
        "558D43C5-A1AC-43C0-AAC8-D1472B2923D1": "Storage Replica",
        "37AFFC90-EF7D-4E96-91C3-2D7AE055B174": "IBM GPFS",

        // Linux
        "0FC63DAF-8483-4772-8E79-3D69D8477DE4": "Linux Filesystem",
        "0657FD6D-A4AB-43C4-84E5-0933C84B4F4F": "Linux Swap",
        "E6D6D379-F507-44C2-A23C-238F2A3DF928": "Linux LVM",
        "A19D880F-05FC-4D3B-A006-743F0F84911E": "Linux RAID",
        "933AC7E1-2EB4-4F13-B844-0E14E2AEF915": "Linux /home",
        "3B421B51-1EB1-4120-8FCE-A7CD5FCE4CAE": "Linux /srv",
        "BC13C2FF-59E6-4262-A352-B275FD6F7172": "Linux Extended Boot",
        "0394EF8B-237E-45E1-B093-8B3E03F6E670": "Linux /usr (x86-64)",
        "B921B045-1DF0-41C3-AF44-4C6F280D3FAE": "Linux Root (PPC64 LE)",
        "C038FF9D-7332-4B36-BAEE-01F048F6FE97": "Linux /usr (PPC64 LE)",
        "1DE3F1EF-FA98-47B5-8DCD-4A860A654D78": "Linux Root (PPC64 BE)",
        "F4019732-066E-4E12-8273-346C5641494F": "Linux Root (PPC32)",
        "4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709": "Linux Root (x86-64)",
        "44479540-F297-41B2-9AF7-D131D5F0458A": "Linux Root (x86)",
        "69DAD710-2CE4-4E3C-B16C-21A1D49ABED3": "Linux Root (ARM64)",
        "6523F8AE-3EB1-4E2A-A05A-18B695AE656F": "Linux Root (ARM32)",
        "993D8D3D-F80E-4225-855A-9DAF8ED7EA97": "Linux Root (IA-64)",
        "77055800-792C-4F94-B39A-98C91B762BB6": "Linux Root (LoongArch 64)",
        "72EC70A6-CF74-40E6-BD49-4BDA08E8F224": "Linux Root (RISC-V 64)",
        "08A7ACEA-624C-4A20-91E8-6E0FA67D23F9": "Linux Root (RISC-V 32)",
        "60D5A7FE-8E7D-435C-B714-3DD8162144E1": "Linux Root (MIPS32 LE)",
        "4D21B016-B534-45C2-A9FB-5C16E091FD2D": "Linux Root (MIPS64 LE)",
        "B0E01050-EE5F-4390-949A-9101B17104E9": "Linux Root (s390)",
        "5EEAD480-CF09-4B15-B4F8-86D1F5BB57D3": "Linux Root (s390x)",
        "2A4F893A-F382-4D33-8F58-5B029A2F2CC2": "Linux /usr Verity (x86-64)",
        "7D0359A3-02B3-4F0A-89A2-EABB3A0E3BBB": "Linux /var",
        "CA7D7CCB-63ED-4C53-861C-1742536059CC": "LUKS Encrypted",

        // Apple
        "48465300-0000-11AA-AA11-00306543ECAC": "Apple HFS/HFS+",
        "7C3457EF-0000-11AA-AA11-00306543ECAC": "Apple APFS",
        "55465300-0000-11AA-AA11-00306543ECAC": "Apple UFS",
        "426F6F74-0000-11AA-AA11-00306543ECAC": "Apple Boot",
        "52414944-0000-11AA-AA11-00306543ECAC": "Apple RAID",
        "52414944-5F4F-11AA-AA11-00306543ECAC": "Apple RAID (Offline)",
        "53746F72-6167-11AA-AA11-00306543ECAC": "Apple Core Storage",
        "4C616265-6C00-11AA-AA11-00306543ECAC": "Apple Label",
        "5265636F-7665-11AA-AA11-00306543ECAC": "Apple TV Recovery",
        "69646961-6700-11AA-AA11-00306543ECAC": "Apple Silicon Boot",
        "B6FA30DA-92D2-4A9A-96F1-871EC6486200": "SoftRAID Status",
        "2E313465-19B9-463F-8126-8A7993773801": "SoftRAID Scratch",
        "FA709C7E-65B1-4593-BFD5-E71D61DE9B02": "SoftRAID Volume",
        "BBBA6DF5-F46F-4A89-8F59-8765B2727503": "SoftRAID Cache",

        // FreeBSD
        "83BD6B9D-7F41-11DC-BE0B-001560B84F0F": "FreeBSD Boot",
        "516E7CB4-6ECF-11D6-8FF8-00022D09712B": "FreeBSD Data",
        "516E7CB5-6ECF-11D6-8FF8-00022D09712B": "FreeBSD Swap",
        "516E7CB6-6ECF-11D6-8FF8-00022D09712B": "FreeBSD UFS",
        "516E7CB8-6ECF-11D6-8FF8-00022D09712B": "FreeBSD ZFS",
        "516E7CBA-6ECF-11D6-8FF8-00022D09712B": "FreeBSD Vinum/RAID",

        // NetBSD
        "49F48D32-B10E-11DC-B99B-0019D1879648": "NetBSD RAID",
        "49F48D5A-B10E-11DC-B99B-0019D1879648": "NetBSD Swap",
        "49F48D82-B10E-11DC-B99B-0019D1879648": "NetBSD FFS",
        "49F48DAA-B10E-11DC-B99B-0019D1879648": "NetBSD LFS",
        "2DB519C4-B10F-11DC-B99B-0019D1879648": "NetBSD CCD",
        "49F48DB2-B10E-11DC-B99B-0019D1879648": "NetBSD CGD",

        // OpenBSD
        "824CC7A0-36A8-11E3-890A-952519AD3F61": "OpenBSD Data",

        // Solaris / illumos
        "6A82CB45-1DD2-11B2-99A6-080020736631": "Solaris Boot",
        "6A85CF4D-1DD2-11B2-99A6-080020736631": "Solaris Root",
        "6A87C46F-1DD2-11B2-99A6-080020736631": "Solaris Swap",
        "6A8B642B-1DD2-11B2-99A6-080020736631": "Solaris Backup",
        "6A898CC3-1DD2-11B2-99A6-080020736631": "Solaris /usr / ZFS",
        "6A8EF2E9-1DD2-11B2-99A6-080020736631": "Solaris /var",
        "6A90BA39-1DD2-11B2-99A6-080020736631": "Solaris /home",
        "6A9283A5-1DD2-11B2-99A6-080020736631": "Solaris Alternate Sector",
        "6A945A3B-1DD2-11B2-99A6-080020736631": "Solaris Reserved",
        "6A9630D1-1DD2-11B2-99A6-080020736631": "Solaris Reserved 2",
        "6A980767-1DD2-11B2-99A6-080020736631": "Solaris Reserved 3",
        "6A96237F-1DD2-11B2-99A6-080020736631": "Solaris Reserved 4",
        "6A9A0F67-1DD2-11B2-99A6-080020736631": "Solaris Reserved 5",

        // ChromeOS
        "FE3A2A5D-4F32-41A7-B725-ACCC3285A309": "ChromeOS Kernel",
        "3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC": "ChromeOS Root",
        "CAB6E88E-ABF3-4102-A07A-D4BB9BE3C1D3": "ChromeOS Reserved",
        "2E0A753D-9E48-43B0-8337-B15192CB1B5E": "ChromeOS Firmware",
        "09845860-705F-4BB5-B16C-8A8A099CAF52": "ChromeOS MiniOS",
        "3F0F8318-F146-4E6B-8222-C28C8F02E0D5": "ChromeOS Hibernate",

        // Haiku
        "42465331-3BA3-10F1-802A-4861696B7521": "Haiku BFS",

        // Plan 9
        "C91818F9-8025-47AF-89D2-F030D7000C2C": "Plan 9",

        // QNX
        "CEF5A9AD-73BC-4601-89F3-CDEEEEE321A1": "QNX6 Power-Safe",

        // U-Boot
        "3DE21764-95BD-54BD-A5C3-4ABE786F38A8": "U-Boot Environment",

        // VMware
        "AA31E02A-400F-11DB-9590-000C2911D1B8": "VMware VMFS",
        "9198EFFC-31C0-11DB-8F78-000C2911D1B8": "VMware Reserved",
        "9D275380-40AD-11DB-BF97-000C2911D1B8": "VMware kcore Crash",

        // Ceph
        "45B0969E-9B03-4F30-B4C6-B4B80CEFF106": "Ceph Journal",
        "45B0969E-9B03-4F30-B4C6-5EC00CEFF106": "Ceph dm-crypt Journal",
        "4FBD7E29-9D25-41B8-AFD0-062C0CEFF05D": "Ceph OSD",
        "4FBD7E29-9D25-41B8-AFD0-5EC00CEFF05D": "Ceph dm-crypt OSD",
        "CAFECAFE-9B03-4F30-B4C6-B4B80CEFF106": "Ceph Block",
        "30CD0809-C2B2-499C-8879-2D6B78529876": "Ceph Block DB",
        "5CE17FCE-4087-4169-B7FF-056CC58473F9": "Ceph Block WAL",
        "FB3AABF9-D25F-47CC-BF5E-721D1816496B": "Ceph Lockbox",

        // Fuchsia
        "FE8A2634-5E2E-46BA-99E3-3A192091A350": "Fuchsia Bootloader",
        "D9FD4535-106C-4CEC-8D37-DFC020CA87CB": "Fuchsia Encrypted System",
        "A409E16B-78AA-4ACC-995C-302352621A41": "Fuchsia Bootloader Data",
        "F95D940E-CABA-4578-9B93-BB6C90F29D3E": "Fuchsia Factory RO System",
        "10B8DBAA-D2BF-42A9-98C6-A7C5DB3701E7": "Fuchsia Factory RO Boot",
        "49FD7CB8-DF15-4E73-B9D9-992070127F0F": "Fuchsia Volume Manager",
        "421A8BFC-85D9-4D85-ACDA-B64EEC0133E9": "Fuchsia Verified Boot Meta",
        "9B37FFF6-2E58-466A-983A-F7926D0B04E0": "Fuchsia Zircon Boot",

        // Atari TOS
        "734E5AFE-F61A-11E6-BC64-92361F002671": "Atari TOS Basic Data",

        // MidnightBSD
        "85D5E45E-237C-11E1-B4B3-E89A8F7FC3A7": "MidnightBSD Boot",
        "85D5E45A-237C-11E1-B4B3-E89A8F7FC3A7": "MidnightBSD Data",
        "85D5E45B-237C-11E1-B4B3-E89A8F7FC3A7": "MidnightBSD Swap",
        "0394EF8B-237C-11E1-B4B3-E89A8F7FC3A7": "MidnightBSD UFS",
        "85D5E45D-237C-11E1-B4B3-E89A8F7FC3A7": "MidnightBSD ZFS",
        "85D5E45C-237C-11E1-B4B3-E89A8F7FC3A7": "MidnightBSD Vinum",

        // HP-UX
        "75894C1E-3AEB-11D3-B7C1-7B03A0000000": "HP-UX Data",
        "E2A1E728-32E3-11D6-A682-7B03A0000000": "HP-UX Service",

        // Sony PlayStation
        "9A1A2D76-01F0-4B9A-B978-1DA99E9B01DE": "PS4 GameOS",
        "B1E6D7B8-1647-4E81-82F9-89B9B8C0B55E": "PS4 App/tmp",
        "5B27C04B-8A56-40EA-9B66-0C0F4AEE7E79": "PS4 Swap",
        "42A90000-0000-1040-A400-0000EA410000": "PS4 Update",

        // MINIX
        "481B2A38-0A1A-4B10-A4B2-AE4C3770C5CF": "MINIX",
    ]

    // MARK: - MBR Partition Type Bytes

    static let mbrNames: [UInt8: String] = [
        0x01: "FAT12",
        0x02: "XENIX Root",
        0x03: "XENIX /usr",
        0x04: "FAT16 (<32M)",
        0x05: "Extended",
        0x06: "FAT16",
        0x07: "NTFS/HPFS/exFAT",
        0x08: "AIX",
        0x09: "AIX Bootable",
        0x0A: "OS/2 Boot Manager",
        0x0B: "FAT32",
        0x0C: "FAT32 LBA",
        0x0E: "FAT16 LBA",
        0x0F: "Extended LBA",
        0x10: "OPUS",
        0x11: "Hidden FAT12",
        0x12: "Compaq Diagnostics",
        0x14: "Hidden FAT16 (<32M)",
        0x16: "Hidden FAT16",
        0x17: "Hidden NTFS/HPFS",
        0x18: "AST SmartSleep",
        0x1B: "Hidden FAT32",
        0x1C: "Hidden FAT32 LBA",
        0x1E: "Hidden FAT16 LBA",
        0x24: "NEC DOS",
        0x27: "Windows Recovery",
        0x39: "Plan 9",
        0x3C: "PartitionMagic Recovery",
        0x40: "Venix 80286",
        0x41: "PPC PReP Boot",
        0x42: "SFS / Dynamic Disk",
        0x4D: "QNX4.x",
        0x4E: "QNX4.x 2nd",
        0x4F: "QNX4.x 3rd",
        0x50: "OnTrack DM",
        0x51: "OnTrack DM6 Aux1",
        0x52: "CP/M",
        0x53: "OnTrack DM6 Aux3",
        0x54: "OnTrack DDO",
        0x55: "EZ-Drive",
        0x56: "Golden Bow",
        0x5C: "Priam Edisk",
        0x61: "SpeedStor",
        0x63: "GNU HURD / SysV",
        0x64: "Novell NetWare 286",
        0x65: "Novell NetWare 386",
        0x70: "DiskSecure Multi-Boot",
        0x75: "PC/IX",
        0x80: "Old Minix",
        0x81: "Minix / Old Linux",
        0x82: "Linux Swap / Solaris",
        0x83: "Linux",
        0x84: "OS/2 Hidden C:",
        0x85: "Linux Extended",
        0x86: "NTFS Volume Set",
        0x87: "NTFS Volume Set 2",
        0x88: "Linux Plaintext",
        0x8E: "Linux LVM",
        0x93: "Amoeba",
        0x94: "Amoeba BBT",
        0x9F: "BSD/OS",
        0xA0: "Hibernation",
        0xA5: "FreeBSD",
        0xA6: "OpenBSD",
        0xA7: "NeXTSTEP",
        0xA8: "Darwin UFS",
        0xA9: "NetBSD",
        0xAB: "Darwin Boot",
        0xAF: "HFS/HFS+",
        0xB7: "BSDI",
        0xB8: "BSDI Swap",
        0xBB: "Boot Wizard Hidden",
        0xBC: "Acronis Secure Zone",
        0xBE: "Solaris Boot",
        0xBF: "Solaris",
        0xC1: "DRDOS FAT12",
        0xC4: "DRDOS FAT16 (<32M)",
        0xC6: "DRDOS FAT16",
        0xC7: "Syrinx",
        0xDA: "Non-FS Data",
        0xDB: "CP/M / CTOS",
        0xDE: "Dell Utility",
        0xDF: "BootIt",
        0xE1: "DOS Access",
        0xE3: "DOS R/O",
        0xE4: "SpeedStor",
        0xEB: "BeOS",
        0xEE: "GPT Protective",
        0xEF: "EFI System",
        0xF0: "Linux/PA-RISC Boot",
        0xF1: "SpeedStor 2",
        0xF2: "DOS Secondary",
        0xF4: "SpeedStor Large",
        0xFB: "VMware VMFS",
        0xFC: "VMware Swap",
        0xFD: "Linux RAID",
        0xFE: "LANstep",
        0xFF: "Xenix BBT",
    ]
}

struct MountInfo {
    let baseDev: String
    let sliceDev: String
    let mountPoint: String?
}

struct RunResult {
    let status: Int32
    let stdout: Data
    let stderr: String
}

class PartitionManager: ObservableObject {
    @Published var partitions: [PartitionInfo] = []
    @Published var mounted: [Int: MountInfo] = [:]
    var blockSize: UInt64 = 512
    var attachedBaseDev: String?

    func load(url: URL, completion: @escaping (String) -> Void) {
        let oldDev = attachedBaseDev
        attachedBaseDev = nil
        partitions = []
        mounted = [:]
        blockSize = 512
        DispatchQueue.global(qos: .userInitiated).async {
            if let dev = oldDev {
                _ = Self.run("/usr/bin/hdiutil", ["detach", dev])
            }
            let (bs, parts, err) = Self.parsePartitions(url: url)
            DispatchQueue.main.async {
                self.blockSize = bs
                self.partitions = parts
                if let err {
                    completion("Error: \(err)")
                } else if parts.isEmpty {
                    completion("No partitions found")
                } else {
                    completion("Found \(parts.count) partition\(parts.count == 1 ? "" : "s")")
                }
            }
        }
    }

    static func parsePartitions(url: URL) -> (UInt64, [PartitionInfo], String?) {
        let r = run("/usr/bin/hdiutil", ["imageinfo", "-plist", url.path])
        guard r.status == 0 else { return (512, [], r.stderr) }
        guard let plist = try? PropertyListSerialization.propertyList(from: r.stdout, format: nil) as? [String: Any],
              let partDict = plist["partitions"] as? [String: Any],
              let bs = (partDict["block-size"] as? NSNumber)?.uint64Value,
              let parts = partDict["partitions"] as? [[String: Any]] else {
            return (512, [], "failed to parse partition table")
        }
        var result: [PartitionInfo] = []
        for (idx, part) in parts.enumerated() {
            let synth = part["partition-synthesized"] as? Bool ?? false
            let num = part["partition-number"] as? Int
            let start = (part["partition-start"] as? NSNumber)?.uint64Value ?? 0
            let length = (part["partition-length"] as? NSNumber)?.uint64Value ?? 0
            let hint = part["partition-hint"] as? String ?? "Unknown"
            let name = part["partition-name"] as? String ?? ""
            let fsDict = part["partition-filesystems"] as? [String: Any] ?? [:]
            let filesystem = fsDict.keys.first ?? ""
            let volName = fsDict.values.first as? String ?? ""
            result.append(PartitionInfo(
                id: idx, number: num, start: start, length: length,
                hint: hint, name: name, size: length * bs,
                synthesized: synth, filesystem: filesystem, volumeName: volName
            ))
        }
        return (bs, result, nil)
    }

    func performMount(partition: PartitionInfo, imageURL: URL, readOnly: Bool = false) -> (String, MountInfo?) {
        guard let partNum = partition.number else {
            return ("Cannot mount this partition", nil)
        }
        if attachedBaseDev == nil {
            let r = Self.run("/usr/bin/hdiutil", ["attach", "-nomount", "-plist", imageURL.path])
            guard r.status == 0 else { return ("Attach failed: \(r.stderr)", nil) }
            guard let plist = try? PropertyListSerialization.propertyList(from: r.stdout, format: nil) as? [String: Any],
                  let entities = plist["system-entities"] as? [[String: Any]] else {
                return ("Failed to parse attach output", nil)
            }
            guard let baseDev = entities.first(where: {
                ($0["content-hint"] as? String)?.contains("partition_scheme") == true
            })?["dev-entry"] as? String else {
                return ("No partition scheme found", nil)
            }
            attachedBaseDev = baseDev
        }
        let sliceDev = "\(attachedBaseDev!)s\(partNum)"
        var mountArgs = ["mount"]
        if readOnly { mountArgs.append("readOnly") }
        mountArgs.append(sliceDev)
        let mr = Self.run("/usr/sbin/diskutil", mountArgs)
        guard mr.status == 0 else { return ("Mount failed: \(mr.stderr)", nil) }

        var mountPoint: String?
        let ir = Self.run("/usr/sbin/diskutil", ["info", "-plist", sliceDev])
        if ir.status == 0,
           let plist = try? PropertyListSerialization.propertyList(from: ir.stdout, format: nil) as? [String: Any],
           let mp = plist["MountPoint"] as? String, !mp.isEmpty {
            mountPoint = mp
        }

        let info = MountInfo(baseDev: attachedBaseDev!, sliceDev: sliceDev, mountPoint: mountPoint)
        let label = "#\(partNum)"
        if let mp = mountPoint {
            return ("Mounted \(label) at \(mp)", info)
        }
        return ("Mounted \(label) on \(sliceDev)", info)
    }

    func performUnmount(info: MountInfo, isLast: Bool) -> (String, Bool) {
        let r = Self.run("/usr/sbin/diskutil", ["unmount", info.sliceDev])
        guard r.status == 0 else { return ("Unmount failed: \(r.stderr)", false) }
        if isLast {
            _ = Self.run("/usr/bin/hdiutil", ["detach", info.baseDev])
            attachedBaseDev = nil
        }
        return ("Unmounted", true)
    }

    static func run(_ path: String, _ args: [String]) -> RunResult {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: path)
        proc.arguments = args
        let out = Pipe()
        let err = Pipe()
        proc.standardOutput = out
        proc.standardError = err
        do { try proc.run() } catch {
            return RunResult(status: -1, stdout: Data(), stderr: "failed to run \(path)")
        }
        let outData = out.fileHandleForReading.readDataToEndOfFile()
        let errData = err.fileHandleForReading.readDataToEndOfFile()
        proc.waitUntilExit()
        let errStr = String(data: errData, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return RunResult(status: proc.terminationStatus, stdout: outData, stderr: errStr)
    }
}
