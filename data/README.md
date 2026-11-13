# AVP input data

Each MAT file contains one variable named avp with columns [theta phi psi B L H t].

- theta, phi, and psi are 321 pitch, roll, and yaw angles in rad.
- B and L are geodetic latitude and longitude in rad.
- H is ellipsoidal height in m.
- t is time in s.

All bundled input matrices use this format. Select the file directly through sourceFile in an experiment script. Each experiment script calls load directly to read avp and selects the requested duration. This data directory is beside Toolbox at the project root.
