package abm.agents;

import abm.helpers.Constants;

public class Bandit extends NonFarmer{
	
	private int vote ;
	private int status = -1 ; 
	
	public Bandit(double income) {
	    super(income) ;
	}
	
	public Bandit(double income, Farmer target) {
	    super(income) ;
	    this.target = target ;
	}

	public void steal(double rate) {
		target.loseIncome(rate);
		this.income = receiveIncome(rate,target.getRemainingBeta());
	}
	
	public double receiveIncome(double rate, double beta) {
		 this.income = rate*beta ;
		 return this.income ;
	}
	
	public int getVote() {
		return this.vote ;
	}
	
	public int getStatus() {
		return this.status ;
	}
	
	public void switchStatus() {
		this.status = Constants.Status.STATIONARY_BANDIT ;
	}
	
	public void vote(double expBeta, double proposedRate) {
		
		double eIncome = expBeta*proposedRate ;
		
		if(eIncome > this.income) {
			this.vote = Constants.Vote.HIERARCHY ;
		} else {
			this.vote = Constants.Vote.ANARCHY ;
		}
	}
	
}
