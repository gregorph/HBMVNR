function [deepcerebelarfire,golgi_cellfire,purkinjefire,granulefire,interneuronfire,cerebellum_lp] = hbm_vnr(infolive_firing,pontine_firing,golgi_cellfire,mod_inhibition,mod_excitation,neuron_firing)
% HBM VNR model described in xx
%   The following code implements the equations that were used to model the
%   cerebellum without including the option to simulate the synaptic
%   changes observed in the literature. The GABA and Glutamate synaptic
%   strenght can be changed collectively by changing mod_inhibition and
%   mod_excitation respectively


if(~exist("neuron_firing")) %Define the baseline DT for all neurons in CmC
    neuron_firing = 0.8;
end

pontinefire = rand > (1-pontine_firing); %Simalate individual pontine nucleus firing to match the expected frequency (muscle proprioception)

infolivefire = rand > (1-infolive_firing); %Simalate individual pontine nucleus firing to match the expected frequency (intened position)


pontine_granule_mod = rand*(1+mod_excitation)*pontinefire;
golgi_granule_mod = rand*(1+mod_inhibition)*golgi_cellfire;
granulefire = (pontine_granule_mod-golgi_granule_mod)>(1-neuron_firing); %Corresponds to eq 6


granule_golgi_mod = rand *(1+mod_excitation)*granulefire;
golgi_cellfire = granule_golgi_mod > (1-neuron_firing); %Corresponds to eq 7


granule_ii_mod = rand *(1+mod_excitation)*granulefire;
interneuronfire = granule_ii_mod > (1-neuron_firing); %Corresponds to eq 8

infolivemodulation = rand * (1+mod_excitation) * infolivefire;
granulemodulation = rand * (1+mod_excitation) * granulefire;
ii_purkinje_mod = rand*(1+mod_inhibition)*interneuronfire;
purkinjetmp = infolivemodulation + granulemodulation - ii_purkinje_mod;
purkinjefire = purkinjetmp > (1-neuron_firing); %Corresponds to eq 9


purkinjedcnmodulation = rand*purkinjefire*(1+mod_inhibition);
infolivedcnmodulation = rand*infolivefire*(1+mod_excitation);
pontinedcnmodulation = rand*pontinefire*(1+mod_excitation);
deepcerebelarfire = (-purkinjedcnmodulation + infolivedcnmodulation + pontinedcnmodulation) > (1-neuron_firing); %Corresponds to eq 10


end