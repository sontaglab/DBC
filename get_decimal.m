function [nb_decimal] = get_decimal(bin_nb)
    %% Getting the decimal representation as a 4-input BF
    if length(bin_nb) == 4
        fprintf('Converting for a 2-input BF. \n')
        bin_nb = [bin_nb bin_nb bin_nb bin_nb];
    elseif length(bin_nb) == 8
        fprintf('Converting for a 3-input BF. \n')
        bin_nb = [bin_nb bin_nb];
    elseif length(bin_nb) == 16
        fprintf('Converting for a 4-input BF. \n')
    else
        fprintf('Wrong input length for the binary representation.\n')
    end
    
    nb_decimal = bin2dec(bin_nb);
end