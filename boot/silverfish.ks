wait until ship:unpacked.
// steps: prelaunch, ascent, circularize, idle, deorbit, descent, done
//TODO: See if virtual kOS drive is persistent across craft reuse

local function thrust_to_weight {
    local _thrust is max(availablethrust, 0.01).
    local weight is (ship:mass * body:mu) / (body:radius ^ 2).
    return _thrust / weight.
}

local function pitch_profile {
    local gain is 12.
    local _alt is max(0, altitude - 250) / 1000.
    local sqrt_alt is sqrt(_alt) * gain.
    return max(0, 90 - sqrt_alt).
}

local function approx_node_burn_time {
    parameter dv.
    local accel is availablethrust / ship:mass.
    return dv / accel.
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

    local desired_twr is 2.

    until memory:done {
        if memory:step = "ascent" {
            lock throttle to desired_twr / thrust_to_weight().
            lock steering to heading(90, pitch_profile()).

            wait until availablethrust = 0.
            stage.

            lock throttle to 1.
            lock steering to prograde.

            wait until apoapsis >= 75_000.
            set memory:step to "circularize".
        }
        if memory:step = "prelaunch" {
            wait until availablethrust > 0.
            set memory:step to "ascent".
        }
        wait 0.
    }
}
main().