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

local function vis_viva {
    parameter _r, _a.
    return sqrt(body:mu * (2 / _r - 1 / _a)).
}

local function semi_major_axis {
    parameter ap, pe.
    local r_a is ap + body:radius.
    local r_p is pe + body:radius.
    return (r_a + r_p) / 2.
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
        if memory:step = "circularize" {
            wait until altitude >= body:atm:height.
            local current_sma is semi_major_axis(apoapsis, periapsis).
            local target_sma is semi_major_axis(apoapsis, 71_000).
            local burn_dv is vis_viva(apoapsis, target_sma) - vis_viva(apoapsis, current_sma).
            local burn_time is approx_node_burn_time(burn_dv).

            wait until eta:apoapsis <= burn_time / 2.
            lock throttle to 1.
            wait until periapsis >= 71_000.

            unlock throttle.
            set memory:step to "idle".
        }
        if memory:step = "ascent" {
            lock throttle to desired_twr / thrust_to_weight().
            lock steering to heading(90, pitch_profile()).

            wait until availablethrust = 0.
            stage.
            set desired_twr to 1.5.
            lock steering to prograde.

            wait until apoapsis >= 75_000.
            unlock throttle.
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