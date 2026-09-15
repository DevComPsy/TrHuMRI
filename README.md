# Task
The TreasureHunt training can be found in the 'Practice' folder. To run the practice, run the file: **information_gathering_prac.m.** 
There are two practices, one without long and short horizons across trials (type '1' when prompted in 'Practice Num') and one with the different hotrizons ('2').
There is a PDF file in the Practice folder which outlines instructions to provide to participants.


The main task is located in the main folder and can be started by running the **information_gathering.m** file. 
The first input is the subject number, the second one is the run. The task is coded for 4 runs but can be easily adapted for more.

# Analysis Code

1) Behavioural

behave_regression: conduct behavioural regression (use behaviour.csv) 
behave_plots: create plots and do behvioural analysis on horizon length influencing draws (horizon_data_all_subjects.csv)

2) Main MRI analysis

TrHu_1stL_DCS: 1st level analysis for decision-commitment signal, controlling for response (1 script)
TrHu_1stL_bigModel: 1st level analysis for ESD(d-1), delta-ES, urgency, controlling for total current evidence (this one is for the PPI)
TrHu_1stL_bigModel_withHorizon: model above but controlling for horizon length
TrHu_1stL_bigModel_withNewHorizon: big model but controlling for collapsing bounds (inverse of trial number)
TrHu_2ndL: general function for running 2nd level (also for PPI). Need to take analysis name from 1st levels above and include in function, e.g., 
TrHU_2ndL('bigModel').

3) Bar plots accompanying MRI analysis

TrHU_1stL_single_trial1.m: conducts analysis on trial-by-trial cue presentation, so we can see brain activity at each time point.
DCS_plot_trial_betas.m: for plotting figure 2B
Totevminus_plot_perTrial_betas.m: for plotting figure 3B
deltaEV_plot_per_trial_betas.m: for plotting Figure 
urgency_plot_trial_betas.m: for plotting figure 4B

4) PPI

TrHu_1stL_bigModel: 1st level analysis for ESD(d-1), delta-ES, urgency, including total current evidence (from Main MRI analysis)
RUN_extractVOI: obtain volume of interest from total ev- to be used in PPI analysis
TrHu_1stL_ppi: Conducts PPI analysis 
