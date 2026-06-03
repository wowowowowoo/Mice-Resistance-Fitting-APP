% calculate_Z_magnitude.m
function Z_mag = calculate_Z_magnitude(Rs_a, Rs_b, Rct_a, Rct_b, Q_a, Q_b, n_a, n_b, m, f)
    % Calculate age-dependent parameters
    Rs_val = Rs_a .* m + Rs_b;
    Rct_val = Rct_a .* m + Rct_b;
    Q_val = Q_a .* m + Q_b;
    n_val = n_a .* m + n_b;

    % Ensure n_val is within a reasonable range (e.g., 0 to 1) for stability
    % You might want to add bounds to n_val in the fitoptions as well.
    n_val(n_val < 0) = 0.001; % Prevent n from being negative
    n_val(n_val > 1) = 0.999; % Prevent n from being greater than 1

    % Calculate CPE term: Q(j*omega)^n = Q*omega^n * (cos(n*pi/2) + j*sin(n*pi/2))
    % Handle f=0 or n=0 cases if they occur, f^n could be problematic.
    % Given your frequencies are >= 20, this is less of a concern.
    omega_n = f.^n_val; % omega = 2*pi*f, but here f is already frequency
    CPE_real = Q_val .* omega_n .* cos(n_val .* pi/2);
    CPE_imag = Q_val .* omega_n .* sin(n_val .* pi/2);

    % Calculate the denominator of the 1/(1/Rct + CPE) term
    denom_real = 1./Rct_val + CPE_real;
    denom_imag = CPE_imag;

    % Calculate the inverse term: 1 / (denom_real + j*denom_imag)
    % = (denom_real - j*denom_imag) / (denom_real^2 + denom_imag^2)
    denom_abs_sq = denom_real.^2 + denom_imag.^2;
    
    % Avoid division by zero if denom_abs_sq is very small
    denom_abs_sq(denom_abs_sq == 0) = eps; 

    inv_term_real = denom_real ./ denom_abs_sq;
    inv_term_imag = -denom_imag ./ denom_abs_sq;

    % Total Impedance Z = Rs + inv_term_real + j*inv_term_imag
    Z_real = Rs_val + inv_term_real;
    Z_imag = inv_term_imag;

    % Return the magnitude |Z|
    Z_mag = sqrt(Z_real.^2 + Z_imag.^2);
end