package abm.creators;

import java.util.ArrayList;

import abm.agents.*;
import abm.components.MetaParameters;
import abm.helpers.Constants;
import cern.jet.random.Uniform;
import repast.simphony.random.RandomHelper;

public class NonFarmersCreator implements AgentsCreator<NonFarmer> {
	
	private final MetaParameters params ;
	private final double rate ;
	
	public NonFarmersCreator(MetaParameters params, double rate){
		this.params = params ;
		this.rate = rate ;
	}

	public ArrayList<NonFarmer> create(){
		
		ArrayList<NonFarmer> nonFarmers = new ArrayList<NonFarmer>();
		
	    Uniform runif = RandomHelper.createUniform(0, 1);
		int nBandits = params.getNBandits() ;
		int nForagers = params.getNForagers() ;
		
		for(int i = 0; i < nBandits; i++) {
			
			Bandit bandit = new Bandit(rate*runif.nextDouble());
			nonFarmers.add(bandit);
		}
		
		double sumIncomes = 0 ;
		
		for(int i = 0; i < nForagers; i++) {
			
			Forager forager = null ;
			
			if(params.getIncomeType() == Constants.IncomeType.RANDOM) {
				double income = rate*runif.nextDouble();
				forager = new Forager(income);
				sumIncomes += income ;
			} else {
				forager = new Forager(params.getForagersIncome());
			}
			
			nonFarmers.add(forager);
		}
		
		if(params.getIncomeType() == Constants.IncomeType.RANDOM) {
			params.setForagersIncome(sumIncomes/nForagers);
		}
		
		return nonFarmers ;
	}


}
