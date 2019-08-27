**************************************************************************************
************************** Power calculations presentation ***************************
**************************************************************************************

*                             1. Monte Carlo Simulation 

** Programer: Sachet Bangia
** Date created: 05/07/2019
display "$S_DATE"

macro drop _all
clear all
set more off
set type double
set matsize 500

/* 
This do file:
(1) Creates the plots that are in the presentation
(2) Runs a Monte Carlo simulation to calculate power for a simple clustered RCT design
See PPT for details.
*/

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                              Plots on slides
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//Code below copied from The Stata Blog entry on MC simulations, read blog for details
capture program drop simttest
program simttest, rclass
    version 15.1
    syntax, n(integer)          ///  Sample size
          [ alpha(real 0.05)    ///  Alpha level
            m0(real 0)          ///  Mean under the null
            ma(real 1)          ///  Mean under the alternative
            sd(real 1) ]        //   Standard deviation
			
	//normal distribution
    drawnorm y, n(`n') means(`ma') sds(`sd') clear 
    ttest y = `m0'
    return scalar reject = (r(p)<=`alpha') 
end

capture program drop power_cmd_simttest
program power_cmd_simttest, rclass
    version 15.1
         
    // DEFINE THE INPUT PARAMETERS AND THEIR DEFAULT VALUES
    syntax, n(integer)          ///  Sample size
          [ alpha(real 0.05)    ///  Alpha level
            m0(real 0)          ///  Mean under the null
            ma(real 1)          ///  Mean under the alternative
            sd(real 1)          ///  Standard deviation
            reps(integer 100)]  //   Number of repetitions
                           
    // GENERATE THE RANDOM DATA AND TEST THE NULL HYPOTHESIS
    quietly simulate reject=r(reject), reps(`reps'):    ///
                     simttest, n(`n') m0(`m0') ma(`ma') sd(`sd') alpha(`alpha')
    quietly summarize reject
         
    // RETURN RESULTS
    return scalar power = r(mean)
    return scalar N = `n'
    return scalar alpha = `alpha'
    return scalar m0 = `m0'
    return scalar ma = `ma'
    return scalar sd = `sd'
	return scalar reps = `reps'
end

// initializer
program power_cmd_simttest_init, sclass

    sreturn local pss_colnames "m0 ma sd reps"
    sreturn local pss_numopts  "m0 ma sd reps"
end

**********  What is the right S?
*Graph 1 //These take a while to run
//power simttest, n(100) m0(0) ma(0.25) sd(1) reps(200(200)20000) graph
*Graph 2
//power simttest, n(50(10)100) m0(0) ma(0.25) sd(1) reps(100 2000) graph

**********  What distribution to assume? Uniform vs Normal results are the same
//This is really ratchet, I just wanted to get the lines on the same graph quickly
capture program drop simttest
program simttest, rclass
    version 15.1
    syntax, n(integer)          ///  Sample size
          [ alpha(real 0.05)    ///  Alpha level
            m0(real 0)          ///  Mean under the null
            ma(real 1)          ///  Mean under the alternative
            sd(real 1) ]        //   Standard deviation
	
	if `ma' == 0.1 {
		//normal distribution
		drawnorm y, n(`n') means(`ma') sds(`sd') clear 
		ttest y = `m0'
		return scalar reject = (r(p)<=`alpha') 
	}
	if `ma' == 0.2501{
		//uniform distribution
		preserve
			set obs `n'
			gen y = runiform(0, `=sqrt(12)*`sd'')
			replace y = y - `=sqrt(12)/2 +0.1'
			ttest y = `m0'
			return scalar reject = (r(p)<=`alpha') 
		restore
	}
end
//Something is wrong with the code above, if n < reps then error returned, not sure why. Not worth the trouble fixing here. 
//Graph 3
//power simttest, n(1000(100)2000) m0(0) ma(0.1 0.2501) sd(1) reps(1000) graph

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                         SIMULATION FOR CLUSTERED RCT DESIGN
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//Simulation for example in slides: R^2 explained is 0.49, icc 0.2
capture program drop simttest
program simttest, rclass
    version 15.1
    syntax, n(integer)          ///  Sample size
          [ alpha(real 0.05)    ///  Alpha level
            m0(real 0)          ///  Mean under the null
            ma(real 1)          ///  Mean under the alternative
            sd(real 1) ]        //   Standard deviation
			
	preserve
		cap drop * 
		set obs 20

		//Generate N_k random numbers normally, for N_c communities
		forval i= 1/`n'{
			gen e_`i' = rnormal(0, `=sqrt((1-0.2)*0.51)')
		}
		
		//Transpose data to get N_c rows and N_k columns
		xpose, clear
		gen X_j = rnormal(0,`=sqrt(0.2*0.51)' )

		//Treatment assignment at cluster level
		gen treatment = runiform()
		qui summ treatment, d
		replace treatment = treatment<`r(p50)'

		//Gen Y(i, j) = X(j) + e(i, j)
		forval i = 1/20{
			gen Y_`i' = X_j + v`i'
			replace Y_`i' = Y_`i' + 0.25 if treatment
		}

		drop v*
		gen id = _n
		egen clusterid = group(X_j) 
		reshape long Y_, i(id) j(pid)
		drop id
		rename Y_ Y
		order clusterid pid X_j Y
		sort clusterid pid

		qui reg Y treatment, cluster(clusterid)
		test treatment 
		return scalar reject = (r(p)<=`alpha') 
	restore
end

capture program drop power_cmd_simttest
program power_cmd_simttest, rclass
    version 15.1
         
    // DEFINE THE INPUT PARAMETERS AND THEIR DEFAULT VALUES
    syntax, n(integer)          ///  Sample size
          [ alpha(real 0.05)    ///  Alpha level
            m0(real 0)          ///  Mean under the null
            ma(real 1)          ///  Mean under the alternative
            sd(real 1)          ///  Standard deviation
            reps(integer 100)]  //   Number of repetitions
                           
    // GENERATE THE RANDOM DATA AND TEST THE NULL HYPOTHESIS
    quietly simulate reject=r(reject), reps(`reps'):    ///
                     simttest, n(`n') m0(`m0') ma(`ma') sd(`sd') alpha(`alpha')
    quietly summarize reject
         
    // RETURN RESULTS
    return scalar power = r(mean)
    return scalar N = `n'
    return scalar alpha = `alpha'
    return scalar m0 = `m0'
    return scalar ma = `ma'
    return scalar sd = `sd'
	return scalar reps = `reps'
end

// initializer
capture program drop power_cmd_simttest_init
program power_cmd_simttest_init, sclass

    sreturn local pss_colnames "m0 ma sd reps"
    sreturn local pss_numopts  "m0 ma sd reps"
end

//Simulation
power simttest, n(10(10)150) m0(0) ma(0.25) sd(1) reps(2000) table graph


*+++++++++++++++++++++++++++++++++++
*  				END
*+++++++++++++++++++++++++++++++++++
