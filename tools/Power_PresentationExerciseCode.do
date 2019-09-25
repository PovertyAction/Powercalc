***********************************************************
** Title: 5/9 Power Calcs Research Meeting Exercises
** Date Created: 5/8/19
** Author: Sachet Bangia & Vincent Armentano
** Contact: vincent.armentano@northwestern.edu
** Last Modified: 5/9/19 to include PPT name
***********************************************************

** Purpose:
	{
/*	

This dofile runs through the examples from slides 23-30 of
	the accompanying powerpoint, "SB_presentation_anim.pptx"

Only works with Stata 15 to take advantage of the "power suite"
	of commands.
	
For comparison with Optimal Design.

Please note that the inclusion of the R^2's impact on Standard Deviation
	is presumed to impact control & treatment evenly.

** Please note "m1" is repeated in the helpfile as mean and cluster size, annoying
	help power twomeans cluster
	
*/
	}
*****

** Preferences & prep
	sca drop _all
	set autotabgraphs on

	
** Ex 1: Slides 23 & 24
	{
	/* Relevant Information;
		Power	= .8
		R^2 	= .64
		Effect	= .25 SD
	*/
	
	** Calculating Sample Size w/o R^2 info
		power twomeans 0 .25, p(.2(.02).98) sd(1)	///
			table graph(horiz yline(.8) name(ex1_noR2, replace))
		
		*@Power==80%, we need 506 obs in total, 253 in each group
	
	
	** Collecting SD from R^2
		di `=sqrt(1-.64)'
		
	** Calculating Sample Size w/R^2 information included
		power twomeans 0 .25, p(.2(.02).98) sd(`=sqrt(1-.64)') ///
			table graph(horiz yline(.8) name(ex1_wR2, replace))
			
		*@Power==80%, we need 184 obs in total, 92 in each group
	}
*****


** Ex 2: Slides 25 & 26
	{
	/* Relevant Information;
		Power 		= .8
		R^2			= .64
		Control N	= 100
		Treatment N	= 100
	*/
	
	** Calculating MDES w/o R^2 info
		power twomeans 0, p(.2(.02).98) n1(100) n2(100) sd1(1) sd2(1)	///
			table graph(horiz yline(.8) name(ex2_noR2, replace))
	
		*@Power==80%, we can observe an MDES of .3981
	
	
	** Collecting SD from R^2
		di `=sqrt(1-.64)'
	
	** Calculating MDES w/R^2 information included
		power twomeans 0, p(.2(.02).98) n1(100) n2(100)	///
			sd1(`=sqrt(1-.64)') sd2(`=sqrt(1-.64)')	///
			table graph(horiz yline(.8) name(ex2_wR2, replace))
	
		*@Power==80%, we can observe an MDES of .2389
	}
*****


** Ex 3: Slides	27 & 28
	{
	/* Relevant Information;
		Power 		= .8
		R^2			= .49
		ICC			= .2
		Effect		= .25
		Cluster Size= 20
	*/
	
	** Calculating Number of Clusters Required w/o R^2 info
		power twomeans 0 .25, cluster power(.2(.02).98)	///
			rho(.2) sd(1) m1(20) m2(20)	///
			table graph(horiz yline(.8) name(ex3_noR2, replace))
	
		*@Power==80%, we need 122 Clusters in total, 61 for each group
	
	
	** Collecting SD from R^2
		di `=sqrt(1-.49)'
	
	** Calculating Number of Clusters Required w/R^2 information included
		power twomeans 0 .25, cluster power(.2(.02).98) rho(.2)	///
			sd(`=sqrt(1-.49)') m1(20) m2(20)	///
			table graph(horiz yline(.8) name(ex3_wR2, replace))
		
		*@Power==80%, we need 62 Clusters in total, 31 for each group
	}
*****


** Ex 4: Slides 29 & 30
	{
	/* Relevant Information;
		Power 		= .8
		R^2			= .49
		ICC			= .2
		N Ctrl Clust= 30
		N Trt Clust	= 30
	*/
	
	** Calculating MDES w/R^2 information included
		power twomeans 0, cluster power(.2(.02).98)	///
			k1(30) k2(30) m1(20) m2(20) rho(.2) sd(1)	///
			table graph(horiz yline(.8) name(ex4_noR2, replace))
	
		*@Power==80%, we can observe an MDES of .3544
		
	
	** Collecting SD from R^2
		di `=sqrt(1-.49)'
	
	** Calculating MDES w/R^2 information included
		power twomeans 0, cluster power(.2(.02).98)	///
			k1(30) k2(30) m1(20) m2(20)		///
			rho(.2) sd(`=sqrt(1-.49)')		///
			table graph(horiz yline(.8) name(ex4_wR2, replace))
	
		*@Power==80%, we can observe an MDES of .2531
	}
*****
	
	*******
	* END *
	*******
