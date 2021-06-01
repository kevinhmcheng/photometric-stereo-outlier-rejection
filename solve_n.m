function [n_opt] = solve_n(I1,I2,L, param, option1, NumOfEqu, iteration)
    %% Observations Selection
    switch option1
        case 1 %IRF(RGB)
            f = irf(I2); %I2 is better than I1
            [~, Idx] = sort(f);
            Remaining_Idx = Idx(1:param);
        case 2 %IRF(Gray)
            f = irf(I1); %I2 is better than I1
            [~, Idx] = sort(f);
            Remaining_Idx = Idx(1:param);
        case 3 %Position T
            [~, Idx] = sort(I1);
            Remaining_Idx = Idx(round((size(I1,1)+1-param+1)/2):round((size(I1,1)+1-param+1)/2)+param-1);
        case 4 %Darkest
            [~, Idx] = sort(I1);
            Remaining_Idx = Idx(1:param);
        case 5 %Brightest
            [~, Idx] = sort(I1);
            Remaining_Idx = Idx(size(I1,1)-param+1:size(I1,1));
        case 6 %Nearest(RGB)
            f = nearest_arith(I2);%I2
            [~, Idx] = sort(f);
            Remaining_Idx = Idx(1:param);
        case 7 %Nearest (Gray)
            f = nearest_arith(I1);%I2
            [~, Idx] = sort(f);
            Remaining_Idx = Idx(1:param);
        case 8 %All images
            Remaining_Idx = 1:size(I1,1);
    end
    
    %% Normal Estimation
    I_in = I1(Remaining_Idx);
    L_in = L(:,Remaining_Idx);
    C = nchoosek(1:param,2);
    A = zeros(size(C,1),2);
    B = zeros(size(C,1),1);
    for i = 1:size(C,1)
        A(i,:) = [I_in(C(i,1))'*L_in(1,C(i,2))-I_in(C(i,2))'*L_in(1,C(i,1)) I_in(C(i,1))'*L_in(2,C(i,2))-I_in(C(i,2))'*L_in(2,C(i,1))];
        B(i) = -(I_in(C(i,1))'*L_in(3,C(i,2))-I_in(C(i,2))'*L_in(3,C(i,1)));
    end
    n_tilt = A\B;
    n_tilt(3) = 1;
    len = norm([n_tilt(1) n_tilt(2) n_tilt(3)]);
    n = n_tilt/len;

    %% Equation Optimization
    this_A = A;
    this_B = B;
    n_opt = zeros(3,iteration);
    for iteration_i = 1:iteration
        if(iteration_i==1)
            n_opt(:,iteration_i) = n;
        else
            Equ6 = [this_A -this_B];
            values = abs(Equ6*n);
            [~, Idx_pair] = sort(values);

            Remaining_Idx_pair = Idx_pair(1:size(this_A,1)-NumOfEqu);
            if(length(Remaining_Idx_pair)<3)
                break;
            end

            A2 = this_A(Remaining_Idx_pair,:);
            B2 = this_B(Remaining_Idx_pair);
            n_tilt = A2\B2;
            n_tilt(3) = 1;
            len = norm([n_tilt(1) n_tilt(2) n_tilt(3)]);
            n = n_tilt/len;
            n_opt(:,iteration_i) = n;

            this_A = A2;
            this_B = B2;
        end
    end
end