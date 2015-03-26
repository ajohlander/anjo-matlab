% Version 0.00 25-Mar-2015
%
% Files
%   afigure             - Quick way to call irf_plot
%   align_y_labels      - Fixes the x-position of the y-labels
%   car2sph             - Transforms coordinates from cartesian to spherical
%   compress_field      - Compresses 3D E- or B-field 
%   e_jxb               - Calculates E = jxB/ne. 
%   e_vxb               - Calculates E = jxB/ne. 
%   fast_date           - Returns a date string
%   find_closest_index  - Finds relevant index of a vector
%   get_3d_b_field      - Returns 3D FGM data in GSE.
%   get_3d_e_field      - Returns 3D EFW data in ISR2.
%   get_c_pos           - Returns the position of all Cluster satellites
%   get_cluster_colors  - Get line colors for the Cluster satellites
%   get_comb_spin       - Combines ion data from two spins
%   get_hia_data        - Returns data from HIA in phase space density [s^3km^-6].
%   get_hia_values      - Returns instrument parameters for HIA
%   get_one_hia_spin    - Get ion data for one full spin of CIS-HIA.
%   get_part_spin       - Get a partial spin
%   import_c_data       - Downloads data from CSA, stores it in ~/Data/caalocal.
%   intersect_line_data - Finds intersection between a line and data points
%   is_new_matlab       - Checks if new plot system is to be used
%   lorentz_1d          - Performs a 1D test patrticle simulation
%   plot_3d_b_field     - Plot 3D FGM data in GSE.
%   plot_3d_e_field     - Plot 3D EFW data in ISR2.
%   plot_hia_subspin    - Plots data from HIA in phase space density [s^3km^-6].
%   plot_ion_polar_isr2 - Plot CIS-HIA data in velocity space.
%   plot_sim_vel        - Plots final velocity vs initial velocity
%   print_fig           - Exports figure to file.
%   progress_pie        - Pie chart showing progress of a calculation
%   reflect_vector      - Mirrors a velocity vector on a moving plane.
%   sph2car             - Transforms coordinates from spherical to cartesian
%   transform_e_field   - Transforms electric field to another inertial frame
