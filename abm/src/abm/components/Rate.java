package abm.components;

import abm.helpers.Constants;

public final class Rate {
	
	private static double RATE = -1;
	private static double MINIMUM_RATE = 0.1;
	
	public static final double calculate(MetaParameters params) {

		RATE = function(params.getPercBandits());
		
		if(RATE < MINIMUM_RATE) {
			RATE = MINIMUM_RATE ;
		}

		return RATE ;
	}
	
	public static final double calculate(double percBandits) {
		
		RATE = function(percBandits);
		
		if(RATE < MINIMUM_RATE) {
			RATE = MINIMUM_RATE ;
		}

		return RATE ;
	}
	
	private static double function(double percBandits) {
		
		if(percBandits != 0) {
			return Math.log10(percBandits*10);
		} else {
			return 0;
		}
		
	}
	
	public static final double getRate() {
		return RATE ;
	}


}
