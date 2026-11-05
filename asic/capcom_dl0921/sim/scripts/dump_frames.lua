-- CPS1 frame-state dump for the gate-level simulation.
-- At each target frame: GFX RAM 0x900000-0x92FFFF, the CPS-A and CPS-B register shares (big-endian 16-bit
-- words) and a snapshot of that frame. Output folder and frame list come from environment variables
-- CPS1DUMP_OUT and CPS1DUMP_FRAMES (comma separated); the machine exits after the last one.
local out = os.getenv("CPS1DUMP_OUT") or "."
local targets = {}
local last = 0
for f in string.gmatch(os.getenv("CPS1DUMP_FRAMES") or "600", "%d+") do
    targets[tonumber(f)] = true
    if tonumber(f) > last then last = tonumber(f) end
end

local function dump_words(path, readfn, count)
    local fh = io.open(path, "wb")
    local parts = {}
    for i = 0, count - 1 do
        parts[#parts + 1] = string.pack(">I2", readfn(i))
        if #parts == 4096 then fh:write(table.concat(parts)); parts = {} end
    end
    fh:write(table.concat(parts))
    fh:close()
end

local game = manager.machine.system.name
local screen = manager.machine.screens[":screen"]
local space = manager.machine.devices[":maincpu"].spaces["program"]
local shares = manager.machine.memory.shares

emu.register_frame_done(function()
    local f = screen:frame_number()
    if targets[f] then
        local base = string.format("%s/%s_f%05d", out, game, f)
        dump_words(base .. "_gfxram.bin", function(i) return space:read_u16(0x900000 + 2 * i) end, 0x18000)
        local a = shares[":cps_a_regs"]
        local b = shares[":cps_b_regs"]
        dump_words(base .. "_cpsa.bin", function(i) return a:read_u16(2 * i) end, a.size // 2)
        dump_words(base .. "_cpsb.bin", function(i) return b:read_u16(2 * i) end, b.size // 2)
        manager.machine.video:snapshot()
        print(string.format("dumped %s frame %d", game, f))
        targets[f] = nil
    end
    if f >= last then manager.machine:exit() end
end)
