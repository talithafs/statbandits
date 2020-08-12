package abm.components;

import abm.helpers.Constants;
import repast.simphony.engine.environment.RunEnvironment;
import repast.simphony.parameter.Parameters;

public class MetaParameters {
	

	private int populationSize = 1000 ;
	private double prodAdvantage = 0.5 ;
	private double foragersIncome = -1 ;
	private double propBandits = 0.5 ;
	private double percNonFarmers = 0.02 ;
	
	private int nBandits ;
	private int nForagers ;
	private int nFarmers ;
	private int incomeType ;
	
	
	public int getIncomeType() {
		return incomeType;
	}

	public void init() {
		
		Parameters params = RunEnvironment.getInstance().getParameters();
		
		prodAdvantage = params.getDouble("prod_advantage");
		foragersIncome = params.getDouble("foragers_income");
		populationSize = params.getInteger("population_size");
		propBandits = params.getDouble("perc_bandits");
		percNonFarmers = params.getDouble("perc_non_farmers");
		
		int nNonFarmers = (int) Math.round(populationSize*percNonFarmers);
		nBandits = (int) Math.round(propBandits*nNonFarmers) ;
		nForagers = (int) Math.round((1-propBandits)*nNonFarmers);
		nFarmers = populationSize - nNonFarmers ;
		
		if(foragersIncome == -1) {
			incomeType = Constants.IncomeType.RANDOM ;
		} else {
			incomeType = Constants.IncomeType.PRESET ;
		}
	}
	

	public double getProdAdvantage() {
		return prodAdvantage;
	}


	public double getForagersIncome() {
		return foragersIncome;
	}
	
	public void setForagersIncome(double foragersIncome) {
		this.foragersIncome = foragersIncome ;
	}
	
	public int getPopulationSize() {
		return populationSize ;
	}

	public double getPercBandits() {
		return propBandits*percNonFarmers;
	}
	
	public double getPercNonFarmers() {
		return percNonFarmers;
	}
	
	public int getNBandits() {
		return nBandits;
	}


	public int getNForagers() {
		return nForagers;
	}


	public int getNFarmers() {
		return nFarmers;
	}

	
}
