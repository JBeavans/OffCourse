extends Node
# courtesy of chatGPT XD (with tweaking and debugging)

# ---------- Physical constants ----------
const R := 0.02135                      # m (golf ball radius)
const A := PI * R * R                   # m^2 (cross-sectional area)
const M := 0.04593                       # kg (golf ball mass)
const RHO := 1.225                      # kg/m^3 (air density)
const G := 9.81                         # m/s^2

# ---------- Launch and environment ----------
var v0 := 85.0                          # m/s launch speed
var theta0 := deg_to_rad(10.6)          # launch angle in radians #10.6 for longest pga driver
var spin_rpm0 := 2350.0                 # initial backspin (rpm)
var omega := 2.0 * PI * spin_rpm0 / 60.0 # rad/s
var wind_speed := 0.0                   # m/s, positive = tailwind

# Aerodynamic coefficients
var CD := 0.25                          # drag coefficient
var spin_decay_rate := 0.05             # s^-1, exponential decay of spin

# Ground interaction
var bounce_coeff := 0.13#0.26
var rolling_friction := 1.6#0.45

# Numerical integration
var dt := 0.001
var max_sim_time := 15.0

# Visualization (meters -> pixels)
var scale_px_per_m := 4.0
var origin_screen := Vector2(50, 420)

# ---------- State ----------
var vx := v0 * cos(theta0)
var vy := v0 * sin(theta0)
var x := 0.0
var y := 0.0
var t := 0.0
var positions := []

# Diagnostics
var max_Cl := 0.0
var max_lift_acc := 0.0

# ---------- Phase timing ----------
var t_first_air := 0.0        # first flight segment
var t_bounces := []            # list of times for each bounce flight
var t_roll := 0.0              # rolling time
var current_air_time := 0.0    # timer for current airborne segment
var first_landing_occurred := false
var time_total := 0.0 #total time of motion
var distance := 0.0 #total distance travelled

# ---------- Lift model ----------
func lift_coefficient(v: float, omega_val: float) -> float:
	if v < 1.0:
		return 0.0
	var S = (R * omega_val) / v
	var Cl = 1.6 * S / (0.75 + 1.05 * S) # attempted to tune to simulate longest driver on the PGA tour's average carry distance (315 yds) and hang time (7.6 s) using his spin and ball speed as inputs. Closest fit resulted in 309.5 m and 7.6s of hang time. Peak height should be 38.6m
	return clamp(Cl, 0.0, 0.40)

# ---------- Acceleration ----------
func acceleration(vx_val: float, vy_val: float, omega_val: float) -> Vector2:
	var v_relx = vx_val - wind_speed
	var v_rely = vy_val
	var v = sqrt(v_relx * v_relx + v_rely * v_rely)
	if v < 1e-6:
		return Vector2(0.0, -G)

	var Cl = lift_coefficient(v, omega_val)
	if Cl > max_Cl:
		max_Cl = Cl

	var c_drag = 0.5 * RHO * CD * A
	var c_lift = 0.5 * RHO * Cl * A

	var ux = v_relx / v
	var uy = v_rely / v
	var lx = -uy
	var ly = ux

	var a_drag_x = -(c_drag / M) * v * v_relx
	var a_drag_y = -(c_drag / M) * v * v_rely

	var a_lift_x = (c_lift / M) * v * v * lx
	var a_lift_y = (c_lift / M) * v * v * ly

	var lift_acc_mag = sqrt(a_lift_x * a_lift_x + a_lift_y * a_lift_y)
	if lift_acc_mag > max_lift_acc:
		max_lift_acc = lift_acc_mag

	var ax = a_drag_x + a_lift_x
	var ay = a_drag_y + a_lift_y - G
	return Vector2(ax, ay)

# ---------- Main simulation ----------
func solve():
	positions.clear()
	positions.append(Vector2(x, y))
	max_Cl = 0.0
	max_lift_acc = 0.0

	var initial_v_relx = vx - wind_speed
	var initial_v_rely = vy
	var initial_v = sqrt(initial_v_relx * initial_v_relx + initial_v_rely * initial_v_rely)
	var initial_Cl = lift_coefficient(initial_v, omega)
	print("Initial airspeed (m/s): ", initial_v)
	print("Initial Cl (estimated): ", initial_Cl)

	var in_air := true
	var rolling := false
	var vx_roll := 0.0

	while t < max_sim_time:
		if in_air:
			# Euler update
			var a = acceleration(vx, vy, omega)
			vx += a.x * dt
			vy += a.y * dt
			x += vx * dt
			y += vy * dt

			omega *= exp(-spin_decay_rate * dt)

			t += dt
			current_air_time += dt
			positions.append(Vector2(x, y))

			# Ground contact
			if y < 0.0:
				y = 0.0
				if abs(vy) > 1.0:
					# Bounce
					vy = -vy * bounce_coeff
					vx *= 0.85

					if not first_landing_occurred:
						t_first_air = current_air_time
						first_landing_occurred = true
					else:
						t_bounces.append(current_air_time)

					current_air_time = 0.0
				else:
					# Enter rolling
					in_air = false
					rolling = true
					vx_roll = vx

					if not first_landing_occurred:
						t_first_air = current_air_time
						first_landing_occurred = true
					current_air_time = 0.0
		elif rolling:
			var a_roll = -rolling_friction * G * sign(vx_roll)
			vx_roll += a_roll * dt
			if abs(vx_roll) < 0.1:
				break
			x += vx_roll * dt
			t += dt
			t_roll += dt
			positions.append(Vector2(x, 0.0))
		else:
			break

	# Account for any remaining air time if simulation ends while airborne
	if current_air_time > 0.0:
		if not first_landing_occurred:
			t_first_air = current_air_time
		else:
			t_bounces.append(current_air_time)

	# Peak height
	var max_y := 0.0
	for p in positions:
		if p.y > max_y:
			max_y = p.y

	# ---------- Diagnostics ----------
	print("=== Simulation diagnostics ===")
	print("Initial Cl:", initial_Cl)
	print("Max lift coefficient (Cl): ", max_Cl)
	print("Max lift accel (m/s^2): ", max_lift_acc)
	print("Total simulated time (s): ", t)
	print("Flight+Roll range (m): ", x)
	distance = x * 1.0936133 #convert to yds
	print("Flight+Roll range (yds): ", distance)
	print("Peak height (m): ", max_y)

	print("=== Phase times ===")
	print("First flight segment (s): ", t_first_air)
	var totalBounceTime = 0.0
	for i in range(t_bounces.size()):
		print("Airborne after bounce ", i+1, " (s): ", t_bounces[i])
		totalBounceTime += t_bounces[i]
	print("Rolling time (s): ", t_roll)
	time_total = t_first_air + totalBounceTime + t_roll
	print("Total time (s): ", time_total)

	#update()  # redraw
#
## ---------- Draw trajectory ----------
#func _draw():
	#if positions.size() < 2:
		#return
	#for i in range(positions.size() - 1):
		#var p0 = positions[i]
		#var p1 = positions[i + 1]
		#var screen_p0 = Vector2(p0.x * scale_px_per_m, -p0.y * scale_px_per_m) + origin_screen
		#var screen_p1 = Vector2(p1.x * scale_px_per_m, -p1.y * scale_px_per_m) + origin_screen
		#draw_line(screen_p0, screen_p1, Color(0.95, 0.85, 0.1), 2)
	#draw_line(Vector2(0, origin_screen.y), Vector2(20000, origin_screen.y), Color(0.2, 0.6, 0.2), 2)
