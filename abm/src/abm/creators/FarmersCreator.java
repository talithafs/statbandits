package abm.creators;

import java.util.ArrayList;

import abm.agents.*;
import abm.components.MetaParameters;
import cern.jet.random.Uniform;
import repast.simphony.random.RandomHelper;

public class FarmersCreator implements AgentsCreator<Farmer> {
	
	private final MetaParameters params ;
	private final double rate ;
	private double meanIncome = 0 ;
	
	public FarmersCreator(MetaParameters params, double rate){
		this.params = params ;
		this.rate = rate ;
	}

	public ArrayList<Farmer> create(){
		
		ArrayList<Farmer> farmers = new ArrayList<Farmer>();
		Uniform runif = RandomHelper.createUniform(0, 1);
		int nFarmers = params.getNFarmers() ;
		double totalIncome = 0 ;
		
		for(int i = 0; i < nFarmers; i++) {
			
			Farmer farmer = new Farmer();
			
			double beta = runif.nextDouble();
			farmer.setBeta(beta) ;
			double income = farmer.receiveIncome(rate,params.getProdAdvantage(),0);
			
			totalIncome += income ;
			farmers.add(farmer);
		}
		
		meanIncome = totalIncome / nFarmers ;
		
		return farmers ;
	}
	
	public double getMeanIncome() {
		return meanIncome ;
	}


}
