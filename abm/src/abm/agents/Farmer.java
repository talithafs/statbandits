package abm.agents;

import abm.helpers.Constants;
import abm.helpers.Utils;
import cern.jet.random.Uniform;
import repast.simphony.random.RandomHelper;

public class Farmer extends Agent {
	
	private double beta ;
	private double stolen = 0 ;
	private int vote ;
	private boolean isTaxPayer = false ; 
	private double remainingBeta ;
	
	public int chooseAction(double rate, double prodAdvantage, double secTax) {
		
		this.beta = chooseBeta(rate, prodAdvantage, secTax);
		this.remainingBeta = this.beta ;
		return Constants.Status.FARMER ;
	}
	
	private double chooseBeta(double rate, double prodAdvantage, double secTax) {
		
		Uniform runif = RandomHelper.createUniform(0, 0.7);
		double u = runif.nextDouble() ;
		double upperB = this.beta ;
		double lowerB = this.beta ;
		
		if(upperB + u < 1) {
			upperB += u ;
		} 
		
		if(lowerB - u > 0) {
			lowerB -= u ;
		}
		
		double uI = calculateIncome(rate, prodAdvantage, upperB, secTax) ;
		double lI = calculateIncome(rate, prodAdvantage, lowerB, secTax) ;
		
		if(this.income < uI || this.income < lI) {
			if(uI >= lI) {
				return uI ;
			} 
			return lI ;	
		}
		
		return this.beta ;
	}
	
	public void vote(double rate, double prodAdvantage, double secTax) {
		
		double simulBeta = chooseBeta(rate, prodAdvantage, secTax);
		 
		 if(simulBeta == this.beta) {
			 this.vote = Constants.Vote.ANARCHY ;
		 } else {
			 this.vote = Constants.Vote.HIERARCHY ;
		 }
	}
	
	public double receiveIncome(double rate, double prodAdvantage, double secTax) {
		
		this.income =  calculateIncome(rate, prodAdvantage, this.beta, secTax);
		return this.income ;
	}
	
	public void loseIncome(double rate) {
		this.remainingBeta = (1-rate)*this.remainingBeta ;
		stolen++ ;
	}
	
	public int getVote() {
		return this.vote ;
	}
	
	private double calculateIncome(double rate, double prodAdvantage, double beta, double secTax) {
		
		double totalRate = Math.pow(1-rate, this.stolen) ;
		return totalRate*beta + (1-prodAdvantage)*(1-beta) - secTax ;
	}
	
	public void resetStolen() {
		this.stolen = 0 ;
	}
	
	public boolean isTaxPayer() {
		return this.isTaxPayer;
	}

	public void setTaxPayer() {
		this.stolen = 1 ;
		this.isTaxPayer = true ;
	}

	public double getBeta() {
		return beta;
	}

	public void setBeta(double beta) {
		this.beta = beta;
	}
	
	public double getRemainingBeta() {
		return this.remainingBeta ;
	}
	
	@Override
	public String toString() {
		
		String strAgent = super.toString() ;
		
		Double beta = this.beta;

		String[][] fields = {{"Beta", beta.toString()}} ;
		
	    return strAgent + Utils.getAgentDescriptor(fields, false) ;
	}

}
