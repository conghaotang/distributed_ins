# Function reference

Functions are listed in the same directory order as [README.md](README.md). Signatures show the callable interfaces. Argument shapes describe one epoch or a batch, and units refer to SI unless an engineering-unit input is explicitly identified.

## 1. Toolbox modules

### 1.1. Toolbox/configuration

#### config

`cfg=config(configOverride)`

[Source](Toolbox/configuration/config.m)

Construct the Earth model, numerical tolerances, sampling settings, sensor layout, and raw sensor error parameters. The optional `configOverride` function receives the raw configuration and returns its edited version. `config` then calls `config_2` and returns the SI configuration.

| Field group | Meaning |
| --- | --- |
| `earth` | Ellipsoid dimensions, eccentricity, rotation rate, and normal-gravity constants |
| `tol.dcm` | Tolerance used for Euler-angle extraction near singular attitudes |
| `fs`, `dt` | IMU rate in Hz and interval in s |
| `ins.subsampleCount` | Number of IMU intervals per navigation update, from 1 to 6 |
| `layout` | System identifiers, sensor counts, and body-frame origin offsets in mm |
| `err.gyro`, `err.acc` | Nominal sensing axes and per-sensor error parameters |

The default configuration uses 100 Hz sampling, four subsamples, four gyros, and four accelerometers. Set `fs` and `dt` consistently when overriding sampling.

Raw sensor parameter units are as follows.

| Parameter | Gyroscopes | Accelerometers |
| --- | --- | --- |
| `bias` | deg/h | ug |
| `scale` | ppm | ppm |
| `directionErrorArcsec` | arcsec | arcsec |
| `directionErrorBearingDeg` | deg | deg |
| `noise` | Sample standard deviation in deg/h | Sample standard deviation in ug |
| `randomWalk` | (deg/h)/sqrt(h) | ug/sqrt(h) |
| `location` | — | Internal lever arms in mm, stored as 3-by-M |

#### config_2

`cfg=config_2(cfg)`

[Source](Toolbox/configuration/config_2.m)

Convert a raw configuration into the representation consumed by the algorithms. This function is called once by `config` after the override has run.

Its main operations are conversion of engineering units, construction of actual unit sensing axes from nominal axes and installation errors, indexing of sensors by system, and construction of total accelerometer lever arms.

| Output field | Shape and meaning |
| --- | --- |
| `system(s).id` | System identifier |
| `system(s).gyroIndex` | Global gyro observation columns belonging to the system |
| `system(s).accIndex` | Global accelerometer observation columns belonging to the system |
| `system(s).lever_b` | 3-by-1 origin offset in m, expressed in b |
| `err.gyro.axes`, `err.acc.axes` | M-by-3 actual sensitive-axis directions |
| `err.acc.internalLocation` | 3-by-M internal offsets in m |
| `err.acc.location` | 3-by-M total offsets from the main origin in m |
| `err.gyro.Q`, `err.acc.Q` | Observation covariance matrices |
| `unit` | Unit conversion factors |

White-noise sample standard deviations are converted to densities. The measurement functions recover the configured sample deviation by dividing the density by `sqrt(dt)`.

`layout` retains its engineering-unit offsets. The SI origin offsets are stored in `system(s).lever_b`. Call this function with raw engineering-unit parameters.

### 1.2. Toolbox/attitude

#### elur2dcm

`Cbn=elur2dcm(theta,phi,psi)`

[Source](Toolbox/attitude/elur2dcm.m)

Construct the body-to-navigation direction cosine matrix using 321 Euler angles. Inputs are pitch `theta`, roll `phi`, and yaw `psi` in rad, each a scalar or equal-length vector.

The output is 3-by-3-by-N and satisfies `v_n=Cbn*v_b`. The rotation sequence is `Rz(psi)*Ry(theta)*Rx(phi)`, with right-handed elementary rotations.

This function supplies attitude matrices to trajectory generation and can initialize navigation directly.

#### dcm2elur

`[theta,phi,psi]=dcm2elur(Cbn,singularTol)`

[Source](Toolbox/attitude/dcm2elur.m)

Extract 321 Euler angles from one body-to-navigation matrix or a 3-by-3-by-N sequence. Each output is N-by-1 in rad.

The optional `singularTol` defaults to `1e-10`. At a singular attitude, the implementation sets roll to zero and recovers the observable yaw combination. The returned angles reconstruct the input matrix under that convention.

#### q2dcm

`C=q2dcm(q)`

[Source](Toolbox/attitude/q2dcm.m)

Convert one scalar-first Hamilton quaternion `[q0;q1;q2;q3]` to a 3-by-3 direction cosine matrix. The quaternion is normalized before conversion.

For a body-to-navigation quaternion, the result is `Cbn`.

#### dcm2q

`q=dcm2q(C)`

[Source](Toolbox/attitude/dcm2q.m)

Convert a 3-by-3 matrix or a 3-by-3-by-N sequence to a 4-by-N scalar-first quaternion array.

The implementation selects a trace or dominant-diagonal branch, normalizes each quaternion, and chooses the sign with `q0>=0`. Its matrix convention matches `q2dcm`.

#### rv2dcm

`C=rv2dcm(rv)`

[Source](Toolbox/attitude/rv2dcm.m)

Convert a three-element rotation vector in rad to a 3-by-3 finite rotation matrix. The vector direction is the rotation axis, and its magnitude is the rotation angle.

Rodrigues' expression is used with a series expansion below the small-angle threshold. Navigation uses this function for body and navigation-frame increments.

#### skew

`K=skew(v)`

[Source](Toolbox/attitude/skew.m)

Construct the matrix representation of a cross product.

A three-element input returns one 3-by-3 matrix. An N-by-3 sequence returns 3-by-3-by-N matrices satisfying `K(:,:,k)*u=cross(v(k,:),u)`.

### 1.3. Toolbox/trajectory

#### avp_to_imu

`truth=avp_to_imu(avp,cfg,applyErrors,options)`

[Source](Toolbox/trajectory/avp_to_imu.m)

Generate continuous trajectory values, analytic derivatives, ideal inertial quantities, and optional distributed observations.

`avp` is a numeric N-by-7 matrix `[theta phi psi B L H t]` with at least four finite nodes and strictly increasing time. Attitude uses 321 angles in rad, latitude/longitude use rad, height uses m, and time uses s. `cfg` is the SI sensor and algorithm configuration.

`applyErrors` defaults to true. `options` defaults to an empty structure. An explicit `options.t` supplies query times inside the source time range. Otherwise the function builds a uniform grid at `cfg.dt`. Observation generation requires query times spaced at `cfg.dt`.

The computation follows this sequence.

1. Construct six shared-node cubic splines.
2. Evaluate attitude, position, and their first two derivatives.
3. Calculate navigation velocity, curvature radii, and Earth/transport rates.
4. Calculate body angular velocity and angular acceleration analytically.
5. Calculate origin specific force from navigation-frame dynamics and normal gravity.
6. Generate subsystem reference states.
7. Generate accelerometer and gyro observations when enabled.

| Output | Shape and meaning |
| --- | --- |
| `t` | Nq-by-1 query time in s |
| `avp` | Input matrix |
| `att`, `pos` | Nq-by-3 attitude and geodetic position |
| `att_d1`, `att_d2` | Euler-angle derivatives in rad/s and rad/s² |
| `pos_d1`, `pos_d2` | Geodetic derivatives in the corresponding angular/height units |
| `Cbn`, `dCbn`, `ddCbn` | 3-by-3-by-Nq attitude matrices and time derivatives |
| `wib_b` | Nq-by-3 inertial body angular velocity in rad/s |
| `alpha_b` | Nq-by-3 body angular acceleration in rad/s² |
| `fb` | Nq-by-3 origin specific force in m/s² |
| `v_eb_n`, `v_eb_dot_n` | ENU ground velocity and its component derivative |
| `r_eb_e`, `v_eb_e` | ECEF position and ground velocity |
| `a_ib_b` | Inertial acceleration in body coordinates |
| `RN`, `RM`, `RN_dot`, `RM_dot` | Curvature radii and their derivatives |
| `omega_ie_n`, `omega_en_n` | Earth and transport rates in n |
| `omega_in_dot_n` | Time derivative of the combined navigation-frame angular-rate components |
| `omega_nb_b`, `omega_nb_dot_b` | Body motion relative to n and its component derivative |
| `gn`, `g_grav_n` | Normal gravity and gravitational attraction in n |
| `pp`, `cfg` | Interpolation and configuration structures |
| `reference` | Main-origin and subsystem reference states |
| `measurement` | Generated `t`, `gyro`, and `acc` arrays when enabled |
| `system(s)` | Per-system observations when enabled |

The generation path uses analytic derivatives. `alpha_b` is available at the first query epoch because it is obtained from the continuous model.

#### data_interp

`pp=data_interp(avp)`

[Source](Toolbox/trajectory/data_interp.m)

Build scalar Not-a-Knot cubic splines for `theta`, `phi`, `psi`, `B`, `L`, and `H`. Roll and yaw are unwrapped before the joint spline solve.

The output contains one MATLAB piecewise polynomial under each field name, together with `tBase` and the preprocessed six-channel `raw` array. `raw` follows the input channel order.

#### splineLeftBound

`ppCell=splineLeftBound(t,Y)`

[Source](Toolbox/trajectory/splineLeftBound.m)

Construct Not-a-Knot cubic splines on nonuniform nodes. `t` is an increasing N-by-1 vector with at least four elements. `Y` is N-by-K.

The function solves for node second derivatives using one sparse coefficient matrix and K right-hand sides. The result is a K-by-1 cell array of MATLAB piecewise polynomials. Node interpolation and continuity of the first two derivatives are enforced by the construction.

#### EvalSplineAll

`[val,d1,d2]=EvalSplineAll(pp,tEval)`

[Source](Toolbox/trajectory/EvalSplineAll.m)

Evaluate one scalar cubic spline and its analytic first and second derivatives. `pp` is a MATLAB piecewise polynomial, and `tEval` is a scalar, row vector, or column vector in the spline's time unit.

The output shapes match `tEval`. If the channel unit is U and time is in s, the units are U, U/s, and U/s². Derivative piecewise polynomials are constructed directly from the coefficients.

#### attitude_inter

`[Cbn,dCbn,ddCbn,wnb_b,alpha_nb_b]=attitude_inter(pp,t)`

[Source](Toolbox/trajectory/attitude_inter.m)

Evaluate 321 attitude and its derivatives from the `theta`, `phi`, and `psi` splines.

`Cbn`, `dCbn`, and `ddCbn` are 3-by-3-by-N. `wnb_b` is N-by-3 angular velocity of b relative to n, expressed in b. `alpha_nb_b` is its component derivative. Their units are rad/s and rad/s².

The function evaluates Euler-angle derivatives, maps them to angular motion, and constructs matrix derivatives consistent with that motion.

#### refere_sys

`reference=refere_sys(truth,cfg)`

[Source](Toolbox/trajectory/refere_sys.m)

Translate the main-origin trajectory to every configured subsystem origin using a constant b-frame lever arm.

`truth` supplies attitude, position, ECEF velocity, ideal angular motion, and origin force. `cfg.system` supplies each origin offset and sensor indices.

The top-level output contains the main-origin `t`, `pos`, `vn`, `Cbn`, `att`, `r_eb_e`, `v_eb_e`, `wib_b`, `alpha_b`, and `fb`. Each `reference.system(s)` contains the corresponding subsystem quantities and layout metadata.

Position is translated in ECEF. Ground velocity uses the body rotation relative to Earth. Local ENU frames are recomputed at the translated origins, and specific force includes the rigid-body centripetal and tangential terms under the shared-gravitational-field approximation.

#### unwrap2pi

`alphaUnw=unwrap2pi(alpha)`

[Source](Toolbox/trajectory/unwrap2pi.m)

Unwrap an angular row or column vector in rad by accumulating principal-value adjacent changes.

The output has the input shape and first value. The intended sampling condition is an adjacent true angle change below pi.

#### unwrapEuler

`eulerUnw=unwrapEuler(eulerRaw)`

[Source](Toolbox/trajectory/unwrapEuler.m)

Unwrap roll and yaw in an N-by-3 array ordered `[phi theta psi]`. Pitch is retained.

AVP attitude columns are ordered `[theta phi psi]`, so scripts reorder them with `(:,[2 1 3])` before and after this call.


### 1.4. Toolbox/earth

#### Cen

`C=Cen(llh)`

[Source](Toolbox/earth/Cen.m)

Construct the ECEF-to-local-ENU matrix `C_e^n`. `llh` contains geodetic `[B L H]`, with angles in rad and height in m.

The function accepts one three-element vector, N-by-3 rows, or a 3-by-N array. The output is 3-by-3-by-N. Each row is the east, north, or up unit vector expressed in ECEF coordinates.

#### llh2xyz

`reb_e=llh2xyz(B,L,H,earth)`

[Source](Toolbox/earth/llh2xyz.m)

Convert geodetic latitude, longitude, and ellipsoidal height to ECEF Cartesian position.

`B` and `L` use rad, `H` uses m, and `earth` supplies `a` and `e2`. Scalar coordinates are expanded to the batch length. Nonscalar coordinate arrays must have equal lengths. The output is N-by-3 `[X Y Z]` in m.

#### xyz2llh

`llh=xyz2llh(reb_e,earth)`

[Source](Toolbox/earth/xyz2llh.m)

Convert ECEF Cartesian positions in m to N-by-3 geodetic `[B L H]` in rad, rad, and m.

`reb_e` accepts a three-element vector, N-by-3 rows, or a 3-by-N array. `earth` supplies the reference ellipsoid. The implementation uses a Bowring latitude estimate and computes height from the corresponding curvature radius. A polar expression handles positions close to the rotation axis.

#### normal_g

`g=normal_g(B,H,earth)`

[Source](Toolbox/earth/normal_g.m)

Evaluate normal-gravity magnitude at geodetic latitude `B` in rad and ellipsoidal height `H` in m.

`earth` supplies `a`, `e2`, `ge`, and `k`. Compatible scalar or array inputs produce gravity values in m/s². The ENU gravity vector used in navigation is `[0;0;-g]`.

#### nav_rate

`eth=nav_rate(B,H,vn,earth)`

[Source](Toolbox/earth/nav_rate.m)

Evaluate Earth terms for one navigation state. `B` and `H` identify the local position, and `vn` is a three-element ENU ground velocity in m/s.

| Output field | Meaning and unit |
| --- | --- |
| `RN` | Prime-vertical curvature radius in m |
| `RM` | Meridian curvature radius in m |
| `wieN` | 3-by-1 Earth rotation rate in n, rad/s |
| `wenN` | 3-by-1 transport rate in n, rad/s |
| `g` | Normal-gravity magnitude in m/s² |

Navigation calls this function at intermediate states to update frame rates and curvature.

### 1.5. Toolbox/measurement

#### gyro_meas

`[imu,rw]=gyro_meas(imu,cfg)`

[Source](Toolbox/measurement/gyro_meas.m)

Generate M single-axis gyro observations from ideal N-by-3 body angular rates.

Input `imu.t` contains uniformly sampled time in s, and `imu.w` contains rates in rad/s. `cfg.err.gyro` supplies actual sensing axes, relative scale errors, biases, noise densities, and random-walk densities.

The output `imu.w` is N-by-M in rad/s. `rw` is the M-by-1 accumulated bias random walk at the final epoch. Other input fields are carried through.

The per-sensor gain is `1+scale`. White noise is sampled with standard deviation `noise/sqrt(dt)`, and bias-walk increments use `randomWalk*sqrt(dt)`.

#### acc_meas

`[imu,rw]=acc_meas(imu,cfg)`

[Source](Toolbox/measurement/acc_meas.m)

Generate M single-axis accelerometer observations at the configured sensing points.

| Input field | Shape and meaning |
| --- | --- |
| `imu.t` | N-by-1 uniformly sampled time in s |
| `imu.f` | N-by-3 ideal origin specific force in m/s² |
| `imu.w` | N-by-3 ideal inertial body angular velocity in rad/s |
| `imu.wa` | N-by-3 angular acceleration in rad/s² |
| `cfg.err.acc.axes` | M-by-3 actual sensing directions |
| `cfg.err.acc.location` | 3-by-M total lever arms in m |

The sensing-point acceleration is origin specific force plus `w x (w x r)` and `wa x r`. These terms are projected onto each actual axis before applying relative scale error, bias, white noise, and random walk.

Output `imu.f` is N-by-M in m/s². `rw` is the M-by-1 final bias random walk. Measurement generation uses ideal angular motion. The integrated generation entry calls this function before adding gyro measurement errors.

#### split_system_measurements

`system=split_system_measurements(measurement,cfg)`

[Source](Toolbox/measurement/split_system_measurements.m)

Split global sensor arrays into per-system observation structures.

`measurement` contains N-by-1 `t`, N-by-Mg `gyro`, and N-by-Ma `acc`. `cfg.system(s)` supplies the corresponding gyro and accelerometer column indices.

The output retains system metadata and adds `t`, `gyro`, and `acc` for each system. Gyro and accelerometer indices are selected independently.

### 1.6. Toolbox/reconstruction

#### array_calibration

`[B,b,Q]=array_calibration(sensor)`

[Source](Toolbox/reconstruction/array_calibration.m)

Assemble the observation matrix and offsets for one sensor type.

`sensor.axes` is M-by-3, `sensor.scale` is an M-by-1 direct gain vector, `sensor.bias` is M-by-1, and `sensor.Q` is an M-by-M observation covariance.

The output `B` multiplies each sensing-axis row by its gain and satisfies `y=B*x+b`. Output `b` and `Q` are the configured bias and covariance. Gyro biases use rad/s, and accelerometer biases use m/s².

#### array_solve

`X=array_solve(Y,B,Q)`

[Source](Toolbox/reconstruction/array_solve.m)

Recover three-axis motion from multichannel observations using covariance-weighted least squares.

`Y` is N-by-M, `B` is M-by-3 with full column rank, and `Q` is a symmetric positive-definite M-by-M covariance. The output `X` is N-by-3 in the units of `Y`.

The implementation applies Cholesky whitening to `B` and `Y`, then solves the whitened least-squares system with matrix left division. `Q=eye(M)` gives equal weighting.

#### array_reconstruct

`rec=array_reconstruct(meas,array)`

[Source](Toolbox/reconstruction/array_reconstruct.m)

Reconstruct three-axis angular rates, angular accelerations, and specific forces for one array.

| Input | Contents |
| --- | --- |
| `meas` | `t` in s, `gyro` in rad/s, and `acc` in m/s² |
| `array.gyro` | Actual axes, direct gains, biases, and covariance for gyros |
| `array.acc` | Actual axes, direct gains, biases, covariance, and `lever` for accelerometers |
| `array.acc.lever` | Ma-by-3 sensing-point offsets from the selected reference origin in m |

The function first removes gyro biases and solves angular rate. It differentiates those estimates backward using the actual time intervals, forms the centripetal and tangential lever-arm projections, removes those contributions and accelerometer biases, and solves specific force.

| Output | Shape and meaning |
| --- | --- |
| `t` | N-by-1 input times |
| `wib_b` | N-by-3 angular rate in rad/s |
| `alpha_b` | N-by-3 angular acceleration in rad/s² |
| `fb` | N-by-3 specific force in m/s² |
| `valid` | N-by-1 reconstruction-validity flag |

The first angular-acceleration and force rows are NaN, and `valid(1)` is false. Angular rate is available at the first epoch.

#### select_system_array

`selected=select_system_array(array,system,referencePoint)`

[Source](Toolbox/reconstruction/select_system_array.m)

Select calibration rows, covariance submatrices, and lever arms for one subsystem.

`array` contains all sensor calibration parameters. `system` contains `gyroIndex`, `accIndex`, and `lever_b`.

With `referencePoint='common_origin'`, the selected accelerometer lever arms are total offsets from the main origin. With `referencePoint='system_origin'`, the system origin offset is subtracted to obtain internal lever arms.

The resulting structure matches the input interface of `array_reconstruct`.

#### reconstruct_systems

`rec=reconstruct_systems(measurement,array,cfg)`

[Source](Toolbox/reconstruction/reconstruct_systems.m)

Reconstruct all configured systems from one global observation set.

The function splits measurements, selects each system's calibration and reference-point lever arms, and calls `array_reconstruct`. The reference mode comes from `cfg.sim.reconstruction.referencePoint`.

Output `rec` contains `t`, `referencePoint`, and `system(s)`. Each system entry contains the reconstructed quantities, validity flags, identifier, and origin offset.

### 1.7. Toolbox/navigation

#### ins_init

`ins=ins_init(initial,cfg)`

[Source](Toolbox/navigation/ins_init.m)

Create one INS state from `initial.Cbn`, `initial.vn`, and `initial.pos`. Attitude is body-to-navigation, velocity is ENU in m/s, and position is `[B L H]` in rad, rad, and m.

The function stores `cfg.earth` and the configured integer subsample count from 1 to 6. Velocity and position are arranged as column vectors.

#### ins_cnscl

`[phim,dvbm]=ins_cnscl(imuInc)`

[Source](Toolbox/navigation/ins_cnscl.m)

Combine one to six IMU subsamples into equivalent rotation and specific-force velocity increments.

`imuInc` is Ns-by-6, with the first three columns containing angular increments in rad and the last three containing velocity increments in m/s. Ns is between 1 and 6.

`phim` is a 3-by-1 compensated rotation vector in rad. `dvbm` is a 3-by-1 compensated velocity increment in m/s.

The single-subsample case applies the half-rotation projection. Multiple subsamples use the configured coning/sculling coefficient row and include the second-order rotation term.

#### ins_step

`ins=ins_step(ins,imu,refh)`

[Source](Toolbox/navigation/ins_step.m)

Update attitude, velocity, and position across one measurement block.

For Ns subsamples, `imu` contains Ns+1 uniformly spaced endpoint observations. `imu.t` is the block time vector, `imu.w` contains angular rates in rad/s, and `imu.f` contains specific forces in m/s².

Adjacent observations are integrated trapezoidally to form Ns increments. The function applies coning/sculling compensation, updates Earth terms at intermediate states, compensates navigation-frame rotation during force projection, and updates the position using average velocity.

The optional scalar `refh` is the reference height at the block end. A finite value sets the final height and obtains vertical velocity from the height change over the block. Omission supplies NaN and integrates the vertical channel.

#### ins_run

`nav=ins_run(ins,imu,refh)`

[Source](Toolbox/navigation/ins_run.m)

Process a uniformly sampled sequence of at least two IMU observation epochs.

`imu.t` is N-by-1, and `imu.w`/`imu.f` are N-by-3 instantaneous rates and forces. `ins.subs` selects the usual number of intervals per update. A shorter final block uses its actual interval count.

The optional `refh` vector is aligned with `imu.t`. The value at each block-end index is passed to `ins_step`. Finite entries supply height aiding. Omitted input supplies an all-NaN vector.

| Output | Shape and meaning |
| --- | --- |
| `nav.t` | Update epochs, including the initial and final input epochs |
| `nav.Cbn` | 3-by-3-by-Nout attitude matrices |
| `nav.vn` | Nout-by-3 ENU velocity in m/s |
| `nav.pos` | Nout-by-3 geodetic position in rad, rad, and m |

The final input observation participates as an endpoint in the last trapezoidal interval.

### 1.8. Toolbox/error

#### state_err

`[attErr,velErr,posErr]=state_err(Cbn,vn,pos,CbnRef,vnRef,BRef,LRef,HRef,earth)`

[Source](Toolbox/error/state_err.m)

Calculate errors at one epoch using the supplied reference state and ellipsoid.

`attErr` is a 1-by-3 ENU misalignment vector in rad, extracted from the antisymmetric part of the attitude-error matrix. This is a small-angle misalignment representation.

`velErr` is estimated minus reference ENU velocity in m/s. `posErr` is east, north, up position error in m, obtained from longitude/latitude differences and reference curvature radii. Longitude differences are wrapped to their principal value.

#### attitude_error321

`error=attitude_error321(Cbn,CbnRef)`

[Source](Toolbox/error/attitude_error321.m)

Calculate auxiliary Euler-angle differences from two body-to-navigation matrix sequences.

The output is N-by-3 in `[Heading Pitch Roll]` order and uses rad. Heading and roll differences are wrapped. Pitch differences are subtracted directly.

#### nav_err_eval

`err=nav_err_eval(nav,ref,earth)`

[Source](Toolbox/error/nav_err_eval.m)

Evaluate a navigation sequence against reference states at matching timestamps. `nav` and `ref` contain `t`, `Cbn`, `vn`, and `pos`. Every `nav.t` value must occur in `ref.t`.

The function calls `state_err` at each matched epoch and calculates Euler-angle and geodetic-position differences.

| Output group | Fields |
| --- | --- |
| Error sequences | `t`, `attErr`, `velErr`, `posErr` |
| Auxiliary differences | `eulerErr` in heading/pitch/roll order and `geodeticPosErr` in latitude/longitude/height order |
| Maximum absolute errors | `maxAtt`, `maxVel`, `maxPos` |
| Root-mean-square errors | `rmsAtt`, `rmsVel`, `rmsPos` |
| Attitude metadata | `attitudeMode` and `attitudeComponents` |

Attitude errors use rad, velocity errors use m/s, and ENU position errors use m. Geodetic differences retain rad, rad, and m.


## 2. Experiments

### 2.1. distri_simu/common

#### experiment_config

`cfg=experiment_config(configOverride)`

[Source](distri_simu/common/experiment_config.m)

Combine shared experiment settings with optional per-experiment raw-parameter overrides.

The function passes experiment defaults and the optional override through `config` before sensor unit conversion. It then converts the experiment's initial misalignment angles from deg to rad.

| Setting | Meaning and default |
| --- | --- |
| `sim.experiment.reconstructionHz` | Interpolation frequency, initially `cfg.fs` |
| `sim.experiment.exportStride` | 1000 IMU intervals between target export epochs |
| `sim.experiment.noiseSeed` | Stored random seed, 20261021 |
| `sim.experiment.duration_s` | Input duration, Inf for the complete trajectory |
| `sim.reconstruction.referencePoint` | `common_origin` |
| `sim.calibration.residualFractions` | `[0 0.05 0.30]` |
| `sim.calibration.names` | `Exact`, `Small`, `Large` |
| `sim.navigation.heightAiding` | true |
| `err.initialAlign` | Three zero initial misalignment angles, converted to rad |

Scripts apply the stored random seed when generating observations. Input filenames are assigned directly in the main scripts.

#### experiment_defaults

`cfg=experiment_defaults(cfg)`

[Source](distri_simu/common/experiment_defaults.m)

Populate the raw configuration with shared experiment defaults before SI conversion. Called by `experiment_config`.

Input `cfg` contains raw sensor and algorithm settings. Output `cfg` also contains residual fractions, reference-point selection, duration, export spacing, noise seed, height aiding, and initial misalignment in deg.

#### calibration_cases

`cases=calibration_cases(cfg,systemIndex)`

[Source](distri_simu/common/calibration_cases.m)

Construct the sensor compensation parameters for each configured residual fraction r.

The estimated installation angle, relative scale correction, and constant bias use the factor `1-r`. Direct reconstruction gains are constructed as `1+(1-r)*relativeScaleError`. The configured covariance matrices are carried into each case.

The output is a structure array containing `name`, `residualFraction`, and `array`. Each array matches `array_reconstruct` and contains direct gains, actual-axis estimates, biases, covariance, and accelerometer lever arms.

The optional `systemIndex` selects one subsystem. Its lever arms follow the configured reconstruction origin. Omission constructs the all-sensor calibration array with total lever arms.

#### navigation_cases

`result=navigation_cases(measurement,reference,cfg)`

[Source](distri_simu/common/navigation_cases.m)

Run every residual case and subsystem on the same full-rate observations.

`measurement` contains `t`, `gyro`, and `acc`. `reference` is the structure returned by `refere_sys` or `truth.reference`. `cfg` contains sensor, layout, and experiment settings.

The runner reconstructs all systems for each case, initializes each origin at the second observation epoch, applies the configured initial misalignment, and calls `ins_run` on all remaining observations.

Finite reference heights are supplied when height aiding is enabled. An all-NaN reference-height vector selects pure INS.

| Output field | Meaning |
| --- | --- |
| `inputRows` | Input rows used for navigation, starting at row 2 |
| `omittedTailSamples` | 0, because the final block is processed |
| `system(s).id` | System identifier |
| `system(s).cases(c).name` | Calibration case name |
| `system(s).cases(c).residualFraction` | Case residual fraction |
| `system(s).cases(c).nav` | Complete navigation output |
| `system(s).cases(c).error` | Error sequences and statistics |

For `common_origin`, initialization and error evaluation use the top-level reference. For `system_origin`, they use `reference.system(s)`.

#### experiment_navigation_cases

`result=experiment_navigation_cases(measurement,reference,cfg)`

[Source](distri_simu/common/experiment_navigation_cases.m)

Run `navigation_cases` and select states for plotting and export.

Target output epochs are separated by `cfg.sim.experiment.exportStride*cfg.dt`. The nearest available navigation state is selected, and the final state is included.

Each `result.system(s)` contains `id`, `caseNames`, `residualFractions`, `t`, and Nout-by-3-by-C arrays named `attitudeError`, `velocityError`, and `positionError`. Angular errors use rad, velocity errors use m/s, and position errors use ENU m.

#### imu3_parameters

`cfg=imu3_parameters(cfg)`

[Source](distri_simu/common/imu3_parameters.m)

Build raw orthogonal three-axis sensor parameters for every system in `cfg.layout`.

The function sets nominal gyro and accelerometer axes to repeated identity matrices. Per-axis error parameters and internal accelerometer positions are repeated from the first three elements of the supplied raw configuration.

Input and output use engineering units. Actual-axis construction, SI conversion, and total lever-arm assembly are performed by `config_2` afterward.

#### imu2_error_config

`cfg=imu2_error_config(cfg)`

[Source](distri_simu/common/imu2_error_config.m)

Apply the configured second-system installation errors, biases, scales, noise magnitudes, and internal accelerometer positions.

The function selects parameter indices from the first two `layout` rows and supplies the dual-IMU experiment's distinct system 2 parameters. Input/output values use engineering units and are subsequently converted by `config_2`.

#### export_cases

`T=export_cases(result,quantity,excelFile)`

[Source](distri_simu/common/export_cases.m)

Construct a table for one system and all its calibration cases. The first column is `Time_s`. Remaining columns carry component, case, and unit information in their names.

| quantity | Required fields | Exported quantity |
| --- | --- | --- |
| `gyro` | `wTruth`, `wEstimate` | Ideal and estimated rate in rad/s |
| `gyro_error` | `wTruth`, `wEstimate` | Rate error in deg/h |
| `force` | `fTruth`, `fEstimate` | Ideal and estimated force in m/s² |
| `force_error` | `fTruth`, `fEstimate` | Force error in m/s² |
| `attitude` | `attitudeError` | ENU misalignment in deg |
| `attitude_arcsec` | `attitudeError` | ENU misalignment in arcsec |
| `velocity` | `velocityError` | ENU velocity error in m/s |
| `position` | `positionError` | North/east/up distances in m, labeled latitude/longitude/height |

Case names come from `result.caseNames`. Supplying `excelFile` writes the table to the `Comparison` sheet using file replacement. Omitting it returns the table for custom sheet assembly.

#### plot_cases

`fig=plot_cases(result,quantity,figureNumber)`

[Source](distri_simu/common/plot_cases.m)

Plot one system's three components across the configured calibration cases. `figureNumber` labels the figure window. The return value is the figure handle.

The function accepts the quantities listed for `export_cases`. It also accepts `euler` using `eulerError` and `geodetic` using `geodeticPositionError`. Euler errors are displayed in deg. Geodetic latitude/longitude errors are displayed in deg and height errors in m.

Time is displayed in s. Ideal quantities are plotted when present, and residual-case curves are labeled using `residualFractions`.

#### run_all_experiments

`summary=run_all_experiments(duration_s,figures)`

[Source](distri_simu/common/run_all_experiments.m)

Run selected experiment scripts in sequence.

`duration_s` supplies an explicit batch duration and overrides the run duration inside each script. The optional `figures` vector selects identifiers. Its default is `[0:9 12:20]`.

The result is a table with `Figure` and `Elapsed_s` columns. Each script writes its normal result files. Figure windows created by that script are closed after its batch execution.

The sequence places reconstruction generation before its dependent force-error visualization. A custom selection can include `[7 8]` to generate and display that pair.

#### run_experiment

`run_experiment(script,duration_s)`

[Source](distri_simu/common/run_experiment.m)

Run one experiment script in an isolated function workspace and close the figure windows it creates. Called by `run_all_experiments`.

Input `script` is the full main-script path. Input `duration_s` is the duration override in seconds. The function has no output arguments. Experiment scripts write their normal result files.

### 2.2. distri_simu/figureXX

#### Main scripts

Each `figureXX_main.m` is a script. Its workflow is input-path selection, path loading, experiment configuration, trajectory or sensor computation, and result export/plotting.

The selected input path is defined by `sourceFile` at the top of the script and points to the root-level `data/` directory. Each entry script includes all project subdirectories, loads `avp` directly with `load`, and selects the requested duration. Generated files are written to the same folder as the main script.

| Script | Main calculation and saved content |
| --- | --- |
| [figure00_main](distri_simu/figure00/figure00_main.m) | Geodetic trajectory and sampled longitude/latitude/height table |
| [figure01_main](distri_simu/figure01/figure01_main.m) | Raw and unwrapped attitude samples |
| [figure02_main](distri_simu/figure02/figure02_main.m) | Heading and position interpolation at configured query frequency |
| [figure03_main](distri_simu/figure03/figure03_main.m) | Ideal body angular velocity and angular acceleration |
| [figure04_main](distri_simu/figure04/figure04_main.m) | Four gyro observation channels with configured errors |
| [figure05_main](distri_simu/figure05/figure05_main.m) | Origin force and two lever-arm acceleration cases |
| [figure06_main](distri_simu/figure06/figure06_main.m) | Four accelerometer observation channels |
| [figure07_main](distri_simu/figure07/figure07_main.m) | Angular-rate reconstruction errors and reconstruction MAT data |
| [figure08_main](distri_simu/figure08/figure08_main.m) | Specific-force reconstruction errors from the saved reconstruction data |
| [figure09_main](distri_simu/figure09/figure09_main.m) | Three calibration cases of attitude, velocity, and position errors |
| [figure12_main](distri_simu/figure12/figure12_main.m) | Raw and unwrapped attitude sequences |
| [figure13_main](distri_simu/figure13/figure13_main.m) | Configured heading and position interpolation |
| [figure14_main](distri_simu/figure14/figure14_main.m) | Origin force and lever-arm acceleration terms |
| [figure15_main](distri_simu/figure15/figure15_main.m) | Attitude, velocity, and position errors for configured residuals |
| [figure16_main](distri_simu/figure16/figure16_main.m) | Subsystem source/interpolated positions, local attitudes, and relative attitude angles |
| [figure17_main](distri_simu/figure17/figure17_main.m) | Ideal angular rates and origin specific forces for two systems |
| [figure18_main](distri_simu/figure18/figure18_main.m) | Each system's origin x force and internal lever-arm acceleration components |
| [figure19_main](distri_simu/figure19/figure19_main.m) | Two-system navigation-error tables and MAT results |
| [figure20_main](distri_simu/figure20/figure20_main.m) | Single-system distributed IMU navigation-error tables and MAT results |

#### Experiment configuration functions

Each `figureXX_config(cfg)` receives the raw configuration and returns its overridden version. `experiment_config` arranges for the override to run before sensor unit conversion.

| Function | Main settings |
| --- | --- |
| [figure00_config](distri_simu/figure00/figure00_config.m) | Pass-through hook using the shared experiment settings |
| [figure01_config](distri_simu/figure01/figure01_config.m) | Attitude display duration and source export spacing |
| [figure02_config](distri_simu/figure02/figure02_config.m) | Display interval, reconstruction rate, and source-node export spacing |
| [figure03_config](distri_simu/figure03/figure03_config.m) | Angular-motion reconstruction rate and export spacing |
| [figure04_config](distri_simu/figure04/figure04_config.m) | Gyro observation export spacing and random seed |
| [figure05_config](distri_simu/figure05/figure05_config.m) | Two representative lever arms and export spacing |
| [figure06_config](distri_simu/figure06/figure06_config.m) | Accelerometer observation export spacing and random seed |
| [figure07_config](distri_simu/figure07/figure07_config.m) | Pass-through hook using the shared reconstruction settings |
| [figure09_config](distri_simu/figure09/figure09_config.m) | Pass-through hook using the shared navigation settings |
| [figure12_config](distri_simu/figure12/figure12_config.m) | Pass-through hook using the shared attitude settings |
| [figure13_config](distri_simu/figure13/figure13_config.m) | Interpolation interval, rate, and source-node spacing |
| [figure14_config](distri_simu/figure14/figure14_config.m) | Representative lever arms and export spacing |
| [figure15_config](distri_simu/figure15/figure15_config.m) | Pass-through hook using the shared navigation settings |
| [figure16_config](distri_simu/figure16/figure16_config.m) | Two orthogonal IMUs, origin offsets, display interval, and source-node spacing |
| [figure17_config](distri_simu/figure17/figure17_config.m) | Dual orthogonal IMUs, system-origin reconstruction, and export spacing |
| [figure18_config](distri_simu/figure18/figure18_config.m) | Dual-IMU setup and distinct second-system errors |
| [figure19_config](distri_simu/figure19/figure19_config.m) | Dual-system navigation setup |
| [figure20_config](distri_simu/figure20/figure20_config.m) | Single orthogonal IMU and system-origin reconstruction |

#### Dedicated plotting functions

| Function signature | Inputs and displayed quantities |
| --- | --- |
| `fig=plot_figure00(longitude_deg,latitude_deg)` | Position angles in deg, with approximate horizontal aspect scaling |
| `fig=plot_figure01(avp,attRawDeg,attUnwrappedDeg)` | AVP timestamps in s and attitude arrays already in deg, displayed against time in h |
| `fig=plot_figure02(avp,truth)` | Source AVP and interpolated `truth.t/yaw/latitude/longitude`, displayed in s and deg |
| `fig=plot_figure03(truth)` | `truth.t/wib_b/alpha_b`, with time in h and angular motion in deg/s and deg/s² |
| `fig=plot_figure04(t,gyroObservation)` | Time in s and rates in rad/s, displayed in h and deg/s |
| `fig=plot_figure05(t,originForce,centripetal,tangential,leverLengthsMm,timeUnit)` | N-by-3 origin force and N-by-3-by-2 lever-arm terms in m/s², with `timeUnit` defaulting to h |
| `fig=plot_figure06(t,accObservation)` | Time in s and accelerometer observations in m/s², displayed against time in h |
| `fig=plot_figure12(avp,attRaw,attUnwrapped)` | Attitudes supplied in rad, displayed in deg against time in s |
| `fig=plot_figure13(avp,truth)` | Source/interpolated heading and positions in s and deg |
| `fig=plot_figure16(result)` | Source/query times, subsystem positions, and attitudes, returning two figure handles |
| `fig=plot_figure17(result)` | Per-system `gyroTruth` and `forceTruth`, displayed in deg/s and m/s² |
| `fig=plot_figure18(result)` | Per-system `originForceX`, `tangentialX`, and `centripetalX` in m/s² |

For `plot_figure16`, `result.system(s)` supplies `sourcePosition`, `position`, `sourceAttitude`, and `attitude`. Position arrays use rad, rad, and m. Attitude arrays use 321 angles in rad. The plot converts angular positions/attitudes to deg and relative attitude differences to arcsec.

For `plot_figure17` and `plot_figure18`, `result.t` is the relative time in s, and each system structure contains its identifier and the named ideal quantities.

The dedicated plotting files are located beside their corresponding experiment scripts. The shared `plot_cases` handles reconstruction and navigation-error plots for the remaining scripts.

## 3. Examples

### demo_config

`[cfg,avp]=demo_config()`

[Source](examples/demo_config.m)

Construct the demonstration configuration and a 120 s synthetic standard AVP matrix with one-second source nodes.

The synthetic attitude and position components are smooth functions of time. The function selects pure INS by disabling height aiding after obtaining the shared configuration. Sensor parameters and residual cases come from the common configuration.

### demo_main

[Source](examples/demo_main.m)

Run the end-to-end demonstration script. It includes all project subdirectories, loads `demo_config`, selects the random seed, and calls `avp_to_imu` followed by `navigation_cases`.

The script plots attitude, velocity, and position error norms. It writes one sheet per system/case to `demo_navigation.xlsx` beside the script. Export epochs follow the configured IMU interval spacing, with the final navigation state included.
