package abm.helpers;

public final class Constants {
	
	private Constants() {}
	
	public static final class Paths { 
		
		private static final String inputs = "/home/talithafs/Dropbox/Dissertação/Modelo/abm/input/" ;
		public static final String PARAMS_FILE = inputs + "parameters.csv";
	}

	public static final class Status { 
		
		public static final int BANDIT = 3 ;
		public static final int FORAGER = 0 ;
		public static final int FARMER = 2 ;
		public static final int STATIONARY_BANDIT = 1 ;

	}
	
	public static final class Vote { 
		
		public static final int HIERARCHY = 1 ;
		public static final int ANARCHY = 0 ;

	}
	
	public static final class IncomeType {
		
		public static final int RANDOM = -1 ;
		public static final int PRESET = 0 ;
	}
	

}
