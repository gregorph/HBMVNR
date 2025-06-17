    neuron_fire = 0.85; %Define the default neuron excitability. In this case neuron has 85% chance firing given a single default excitatory release

    centre = 0.3; %Define centre of sine wave movement to follow

    repetitions = 1000; %Define number of timeslices run

    amplitude = 0.2; %Define amplitude of sine wave movement to follow

    cycle = 40; %Define cycle length of sine wave movement to follow

    golgi_cellfire = 0; %Set original value of golgi cells

    circuits = 10000; %Number of circuits to run in parallel

    gravity_anti = 0; %Define external forces acting on joint. See eq. 20

    extensor_excitability = 1; %Change strength of extensor muscle
    flexor_excitability = 1; %Change strength of extensor muscle

    resistance = gravity_anti;

    avwindow = 5; %window for moving average

    mod_inhibition = 0.6; %Set strength of GABA synapses
    mod_excitation = 0.3; %Set strength of Glutamate synapses
    
    muscleposition(1) = centre+sin(1/(cycle/(2*pi)))*amplitude;
    gain = 10; %Define Strength of muscle
    gain = gain/circuits;
    for i = 1:repetitions
        desiredposition(i) = centre+sin(i/(cycle/(2*pi)))*amplitude;
        for y = 1:circuits
            [cerebellar_correctiontmp(y),golgi_cellfire,~] = hbm_vnr(desiredposition(i),muscleposition(i),golgi_cellfire,mod_inhibition,mod_excitation,neuron_fire);
            cortexfire(y) = rand > 1-desiredposition(i);

            pyramidal1(y) = (rand*cerebellar_correctiontmp(y) - rand*cortexfire(y)) > (1-neuron_fire); %See Eq. 14
            pyramidal2(y) = (rand*cortexfire(y) - rand*cerebellar_correctiontmp(y)) > (1-neuron_fire); %See Eq. 15
            pyramidalcollective(y) = (rand*pyramidal1(y) + rand*pyramidal2(y)) > (1-neuron_fire); %See Eq. 16


            flexorpower(y) = (rand*pyramidalcollective(y)-rand*cerebellar_correctiontmp(y))*flexor_excitability > (1-neuron_fire); %See Eq. 17
            % flexor_excitability = flexor_excitability + gain/100*(flexorpower(y)-rand*~flexorpower(y));

            extensorinterneuron(y) = (rand*pyramidalcollective(y)-rand*cerebellar_correctiontmp(y)) > (1-neuron_fire); %See Eq. 18
            extensorpower(y) = (rand*pyramidalcollective(y)-rand*extensorinterneuron(y))*extensor_excitability > (1-neuron_fire); %See Eq. 19

        end
        cer_signal(i) = mean(cerebellar_correctiontmp);
        cortexdefault(i) = mean(cortexfire);

        output(i) = sum(flexorpower*gain)-sum(extensorpower*gain); %See Eq. 20

        muscleposition(i+1) = muscleposition(i) + output(i)-resistance; %See Eq. 21

        %Define boundaries of joint range of motion
        if(muscleposition(i)<0)
            muscleposition(i) = 0;
        elseif(muscleposition(i)>1)
            muscleposition(i) = 1;
        end

    end
    
    %% Figure generation
    figure
    
    %Plots Muscle power over time
    subplot(3,1,1)
    plot(output,'LineWidth',2)
    hold on
    plot([0 size(muscleposition,2)],[0 0],'LineStyle','--','LineWidth',2,'Color','k')
    grid on
    title(["Number of cerebellar circuits = " num2str(circuits)])
    xlabel("Time samples")
    ylim([-0.4 0.4])
    xlim([0 100])

    %Plots Achieved position over desired position
    subplot(3,1,2)
    plot(muscleposition,"LineWidth",3)
    hold on
    % plot(movmean(muscleposition,avwindow),'Color','b','LineStyle','--','LineWidth',3);
    plot(desiredposition,'Color','k','LineWidth',2);
    xlabel("Time samples")
    grid on
    % title("Muscle position")
    ylim([centre-amplitude-0.1 centre+amplitude+0.1])
    xlim([0 100])

    %Plots intention error over time
    subplot(3,1,3)
    % subplot(3,3,j+6)
    % plot(movmean(abs(muscleposition(1:size(desiredposition,2))-desiredposition),avwindow),'Color','b','LineStyle','--');
    hold on
    plot(log10(movvar(abs(muscleposition-movmean(muscleposition,avwindow)),avwindow)),'LineWidth',2);
    hold on
    xlabel("Time samples")
    grid on
    % title("Error variance")
    % ylim([0 0.004])
    % linkaxes([a b c],'x')
    xlim([0 100])
