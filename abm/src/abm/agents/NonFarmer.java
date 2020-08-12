package abm.agents;


import abm.helpers.Constants;
import repast.simphony.random.RandomHelper;
import repast.simphony.util.collections.IndexedIterable;

public class NonFarmer extends Agent {
	
	protected Farmer target = null ;
	
	public NonFarmer(double income) {
		super(income,false);
	}
	
	public void chooseTarget(IndexedIterable<Agent> farmers) {
		
		int limit = farmers.size() ;
		int index = RandomHelper.nextIntFromTo(0, limit-1);
		
		this.target = (Farmer) farmers.get(index);
	}

	public int chooseAction(double rate, double meanIncome, double prodAdvantage) {
		
		double eIncome = rate*(target.getBeta()) ;
		
		if(eIncome > meanIncome) {
			return Constants.Status.BANDIT ;
		} else {
			return Constants.Status.FORAGER ;
		}
	}
	
	public Farmer getTarget() {
		return this.target ;
	}
}
