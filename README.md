# Distributed Inertial Navigation Toolbox

This MATLAB toolbox generates distributed inertial sensor observations from a sampled attitude and position trajectory, reconstructs three-axis inertial quantities, and performs strapdown inertial navigation with one to six subsamples per update.

The implementation uses local east-north-up navigation coordinates, 321 Euler angles, analytic cubic-spline derivatives, covariance-weighted sensor reconstruction, and explicit lever-arm compensation.

[FUNCTIONS.md](FUNCTIONS.md) describes the functions in the directory order used below.

## 1. Toolbox organization

```text
Toolbox/
  configuration/       Sensor parameters, algorithm settings, and SI conversion
  attitude/            Euler angles, quaternions, and rotation matrices
  trajectory/          Splines, analytic motion, ideal IMU data, and system references
  earth/               Geodetic/ECEF coordinates, gravity, and navigation frame rates
  measurement/         Single-axis gyro and accelerometer observations
  reconstruction/      Weighted reconstruction and lever-arm compensation
  navigation/          Initialization, incremental updates, and trajectory navigation
  error/               Attitude, velocity, and position error evaluation

data/                  MAT files containing standard AVP matrices

distri_simu/
  common/              Shared experiment settings, case runners, plotting, and export
  figureXX/            Experiment script, configuration, plotting, and generated results

examples/
  demo_config.m        Synthetic trajectory and demonstration settings
  demo_main.m          End-to-end demonstration script
  demo_navigation.xlsx Generated demonstration workbook

```

### 1.1. configuration

`config.m` defines Earth constants, sampling parameters, the navigation subsample count, the sensor layout, and raw sensor error parameters. Sensor parameters are entered in the engineering units documented beside their definitions.

`config_2.m` converts those raw parameters to SI, constructs actual sensing directions, assigns sensor indices to each system, and adds origin offsets to internal accelerometer lever arms.

The returned configuration is shared by motion generation, measurement generation, reconstruction, and navigation. Experiment-specific overrides are applied before unit conversion.

### 1.2. attitude

This module provides 321 Euler-angle conversion, scalar-first Hamilton quaternion conversion, rotation-vector increments, and cross-product matrices.

`Cbn` denotes the body-to-navigation matrix. Attitude derivatives and navigation updates use the same matrix direction.

### 1.3. trajectory

This module constructs six Not-a-Knot cubic splines for attitude and geodetic position. Roll and yaw are unwrapped before interpolation. Spline coefficients supply analytic first and second derivatives.

`avp_to_imu` combines these derivatives with Earth rotation, transport rate, gravity, and rigid-body kinematics. Its outputs include ideal angular velocity, angular acceleration, specific force, navigation references, and optional sensor observations.

`refere_sys` translates the main trajectory to configured subsystem origins. Each origin has its own local ENU frame.

### 1.4. earth

This module converts geodetic coordinates to and from ECEF coordinates, calculates ECEF-to-ENU matrices, and evaluates curvature radii, Earth rotation, transport rate, and WGS-84 normal gravity.

Earth parameters are supplied explicitly through `cfg.earth`.

### 1.5. measurement

`gyro_meas` projects ideal body angular rates onto the actual gyro sensing axes and applies gains, biases, white noise, and bias random walks.

`acc_meas` adds centripetal and tangential lever-arm accelerations to origin specific force, projects onto the actual accelerometer axes, and applies the sensor error model.

`split_system_measurements` groups the resulting observation columns according to `cfg.system`.

### 1.6. reconstruction

The reconstruction sequence is weighted least-squares angular-rate estimation, backward-difference angular acceleration, accelerometer lever-arm correction, and weighted least-squares specific-force estimation.

The module supports a complete array through `array_reconstruct` and separate systems through `reconstruct_systems`. The chosen reference point determines which lever arms are compensated.

### 1.7. navigation

`ins_init` creates the navigation state. `ins_step` updates a single measurement block, and `ins_run` traverses an entire observation sequence.

`ins_cnscl` supports one to six angular/velocity subsamples. The navigation update includes trapezoidal integration, coning and sculling compensation, navigation-frame rotation, and midpoint Earth terms. The last block uses the number of intervals actually available.

Height aiding is supplied explicitly through the optional `refh` argument.

### 1.8. error

`state_err` evaluates one navigation epoch. `nav_err_eval` aligns navigation output with reference epochs and calculates error sequences and summary statistics.

Attitude misalignment uses ENU components. `attitude_error321` additionally provides heading, pitch, and roll differences.

## 2. Experiment organization

### 2.1. Shared experiment support

`distri_simu/common` contains the following groups.

| Group | Functions | Responsibility |
| --- | --- | --- |
| Experiment settings | `experiment_config`, `experiment_defaults`, `imu3_parameters`, `imu2_error_config` | Residual cases, initial misalignment, noise seed, output settings, and selected sensor arrangements |
| Case execution | `calibration_cases`, `navigation_cases`, `experiment_navigation_cases` | Construct compensation parameters, run each system and case, and prepare display/export arrays |
| Presentation | `plot_cases`, `export_cases` | Plot component errors and construct Excel tables |
| Script execution | `run_all_experiments`, `run_experiment` | Run selected experiment scripts |

Sensor defaults and their SI conversion are defined in `Toolbox/configuration`. Residual fractions, initial misalignment, random seed, export spacing, duration, and height aiding are defined by the experiment configuration.

### 2.2. Per-experiment folders

Each `figureXX` folder contains a runnable `figureXX_main.m` script and its configuration or plotting functions. Generated Excel and MAT files are written beside the script.

Set `sourceFile` directly in the main script to select an input MAT file. Input MAT files are stored in the root-level `data/` directory. Each main script calls `load` directly and selects the requested duration. All input files use the same matrix format and processing interfaces.

| Experiment identifiers | Content |
| --- | --- |
| 00 | Longitude/latitude trajectory |
| 01, 12 | Attitude samples and angle unwrapping |
| 02, 13 | Source nodes and interpolated heading/position |
| 03 | Ideal angular velocity and angular acceleration |
| 04, 06 | Gyro and accelerometer observations |
| 05, 14 | Origin force and centripetal/tangential lever-arm terms |
| 07, 08 | Angular-rate and specific-force reconstruction errors |
| 09, 15 | Navigation attitude, velocity, and position errors |
| 16 | Subsystem positions and local-navigation attitudes |
| 17, 18 | Ideal subsystem motion and lever-arm acceleration terms |
| 19 | Navigation with two distributed three-axis IMUs |
| 20 | Navigation with one distributed three-axis IMU |

Experiment 08 reads the reconstruction MAT file produced by experiment 07. The default batch sequence runs those scripts in that order.

Common navigation-error plots and tables use time in s and position errors in m. Individual scripts label the units used for their trajectory or motion plots.

## 3. Examples

Open `examples/demo_main.m` and run it. The script adds the required paths, obtains its settings and synthetic trajectory from `demo_config`, generates one sensor observation realization, and runs the configured calibration cases.

The workspace retains `cfg`, `avp`, `truth`, and `result`. Figure windows show error norms. `demo_navigation.xlsx` contains one sheet per system and case.

## 4. Input data and conventions

### 4.1. AVP matrix

Each input MAT file contains a numeric variable named `avp` with at least four rows.

| Column | Quantity | Unit |
| --- | --- | --- |
| 1 | Pitch `theta` | rad |
| 2 | Roll `phi` | rad |
| 3 | Yaw `psi` | rad |
| 4 | Geodetic latitude `B` | rad |
| 5 | Longitude `L` | rad |
| 6 | Ellipsoidal height `H` | m |
| 7 | Time `t` | s |

Time must be strictly increasing. The stored attitude angles use the 321 convention.

`avp_to_imu` receives this matrix directly. Query times can be supplied through `options.t`. Without that field, the output grid uses `cfg.dt` from the first input epoch to the last in-range grid point.

### 4.2. Frames and representations

- `n` is the local ENU frame, with velocity ordered east, north, up.
- `b` is the rigid body frame shared by sensor axes and lever arms.
- `e` is the Earth-centered, Earth-fixed frame.
- `Cbn` satisfies `v_n=Cbn*v_b`.
- The 321 attitude matrix is `Rz(psi)*Ry(theta)*Rx(phi)`.
- Quaternions are scalar-first Hamilton unit quaternions, ordered `[q0;q1;q2;q3]`.
- Geodetic position arrays are ordered `[B L H]`.

### 4.3. Sensor and reference-point conventions

Measurement configuration uses relative scale error, giving the gain `1+scale`. Reconstruction arrays store direct gain in their `scale` field.

Sensor observations are `N-by-M`, with one column per single-axis element. Actual sensing axes are `M-by-3`. The measurement configuration stores accelerometer locations as `3-by-M`, while reconstruction arrays store lever arms as `M-by-3`.

`cfg.layout` rows are `[id gyroCount accCount x_mm y_mm z_mm]`. `config_2` creates the corresponding `cfg.system` entries and SI origin offsets.

- `common_origin` uses total lever arms to reconstruct at the main origin.
- `system_origin` uses internal lever arms to reconstruct at each subsystem origin.

Motion generation uses a shared gravitational-field approximation across the configured rigid-body offsets. `gn` is local normal gravity including the centrifugal effect. `g_grav_n` is gravitational attraction used in inertial-acceleration relations.

### 4.4. Sampling and valid epochs

Sensor observations use the configured uniform interval `cfg.dt`. Reconstruction angular acceleration uses backward differences, so the first `alpha_b` and `fb` rows are NaN and `valid(1)` is false.

The experiment navigation runner starts at the second observation epoch. All remaining intervals are processed, including a shorter final navigation block.

## 5. Running the toolbox

Run the following commands from the project root to load a selected dataset and evaluate its first 120 s.

```matlab
rootDir=pwd;
addpath(genpath(rootDir));

sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+120,:);

cfg=experiment_config();
truth=avp_to_imu(avp,cfg,true);
result=navigation_cases(truth.measurement,truth.reference,cfg);
```

For ideal motion at selected times, call `avp_to_imu(avp,cfg,false,struct('t',queryTime))`.

To run all available experiment scripts for a selected duration, use the batch entry.

```matlab
summary=run_all_experiments(120);
```

The optional second argument selects experiment identifiers, for example `run_all_experiments(120,[7,8,19])`. Passing `Inf` as the duration selects the complete input trajectory.

## License

Distributed under the MIT License. See [LICENSE](LICENSE).
