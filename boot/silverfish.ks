wait until ship:unpacked.
// steps: prelaunch, ascent, circularize, idle, deorbit, descent, done
//TODO: See if virtual kOS drive is persistent across craft reuse

local function thrust_to_weight {
    local _thrust is max(availablethrust, 0.01).
    local weight is (ship:mass * body:mu) / (body:radius ^ 2).
    return _thrust / weight.
}

local function pitch_profile {
    local gain is 10.
    local _alt is max(0, altitude - 250) / 1000.
    local sqrt_alt is sqrt(_alt) * gain.
    return max(0, 90 - sqrt_alt).
}

local function main {
    local memory is lexicon(
        "step", "prelaunch",
        "done", false
    ).

    local memory_path is "/memory.json".

    if exists(memory_path) {
        set memory to readjson(memory_path).
    }

    until memory:done {
        if memory:step = "prelaunch" {
            wait until brakes.
            brakes off.
            set memory:step to "ascent".
        }
        wait 0.
    }
}
main().