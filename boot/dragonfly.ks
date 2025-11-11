wait until ship:unpacked.

local function thrust_to_weight {
    local thrust is max(availablethrust, 0.01).
    local weight is (ship:mass * body:mu) / (body:radius ^ 2).
    return thrust / weight.
}

local function ascent_pitch_function {
    local gain is 11.7.
    local alt_km is max(0, altitude - 250) / 1000.
    local sqrt_alt is sqrt(alt_km) * gain.
    return max(0, 90 - sqrt_alt).
}

local desired_twr is 2.

local state is "prelaunch".
local done is false.

if altitude >= 1000 {
    set state to "ascent".
}

if apoapsis > 70_000 and periapsis < 70_000 {
    set state to "circularize".
}

if periapsis > 70_000 {
    set state to "".
    set done to true.
}

local function main {
    if done {
        return.
    }

    until done {
        if state = "circularize" {
            wait until eta:apoapsis <= 15.
            lock throttle to 1.

            wait until periapsis >= 70_000.

            set state to "".
            set done to true.
        }
        if state = "ascent" {
            if availablethrust = 0 {
                stage.
            }

            set steeringmanager:maxstoppingtime to 0.1.
            lock throttle to desired_twr / thrust_to_weight().
            lock steering to heading(90, ascent_pitch_function()).

            wait until availablethrust = 0.
            lock steering to prograde.
            lock throttle to 1.
            stage.

            wait until apoapsis >= 75_000.
            unlock throttle.
            set state to "circularize".
        }
        if state = "prelaunch" {
            wait until sas.
            sas off.
            set state to "ascent".
        }
        wait 0.01.
    }
}

main().