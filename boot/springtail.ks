wait until ship:unpacked.

local function thrust_to_weight {
    local available_thrust is max(availablethrust, 0.01).
    local weight is (ship:mass * body:mu) / (body:radius ^ 2).
    return available_thrust / weight.
}

local target_twr is 2.

wait until sas.

sas off.
lock steering to lookdirup(up:forevector, heading(180, 0):forevector).

lock throttle to target_twr / thrust_to_weight().
stage.

wait until apoapsis >= 70_000.

wait 1.
unlock throttle.

wait 1.
stage.
sas on.